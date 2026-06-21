import { Component, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { Supabase } from '../../services/supabase';

type TipoPersona = 'empleado' | 'cliente' | 'empresa';

@Component({
  selector: 'app-roles',
  imports: [CommonModule, FormsModule],
  templateUrl: './user.html',
  styleUrl: './user.css',
})
export class User implements OnInit {

  // ── Vista activa ─────────────────────────────────────
  protected vista = signal<'tabla' | 'crear' | 'editar'>('tabla');

  // ── Tabla ─────────────────────────────────────────────
  protected usuarios     = signal<any[]>([]);
  protected roles        = signal<any[]>([]);
  protected busqueda     = signal('');
  protected paginaActual = signal(1);
  protected readonly porPagina = 6;
  protected isLoading    = signal(false);
  protected errorMsg     = signal('');
  protected successMsg   = signal('');

  // ── Modal eliminar ────────────────────────────────────
  protected modalEliminar       = signal(false);
  protected usuarioSeleccionado = signal<any>(null);
  protected confirmId           = signal('');

  // ── Formulario crear/editar ───────────────────────────
  protected form = signal({
    usar_nombre_usuario: '',
    usar_correo:         '',
    usar_contrasena:     '',
    fk_r_usar:           '',
    // Tipo determina qué sección de campos se muestra y qué rama ejecuta el procedure
    tipo_persona: 'empleado' as TipoPersona,
    // Campos persona natural / empleado
    primer_nombre:    '',
    segundo_nombre:   '',
    primer_apellido:  '',
    segundo_apellido: '',
    cedula:           '',
    telefono:         '',
    direccion:        '',
    // Campos exclusivos empresa B2B
    razon_social:     '',
    nombre_comercial: '',
    rif:              '',
    limite_credito:   '',
  });

  protected editandoId = signal<number | null>(null);

  constructor(private supabase: Supabase, private router: Router) {}

  ngOnInit(): void {
    this.cargarDatos();
  }

  // ── Helpers de tipo ───────────────────────────────────
  protected get esEmpresa(): boolean  { return this.form().tipo_persona === 'empresa'; }
  protected get esEmpleado(): boolean { return this.form().tipo_persona === 'empleado'; }
  protected get esCliente(): boolean  { return this.form().tipo_persona === 'cliente'; }

  // ── Carga inicial ─────────────────────────────────────
  protected async cargarDatos(): Promise<void> {
    this.isLoading.set(true);
    try {
      const [usuarios, roles] = await Promise.all([
        this.supabase.callProcedure('listar_usuarios'),
        this.supabase.callProcedure('listar_roles'),
      ]);
      this.usuarios.set(usuarios || []);
      this.roles.set(roles || []);
    } catch {
      this.errorMsg.set('Error al cargar datos.');
    } finally {
      this.isLoading.set(false);
    }
  }

  // ── Filtro y paginación ───────────────────────────────
  protected get usuariosFiltrados(): any[] {
    const q = this.busqueda().toLowerCase();
    return this.usuarios().filter(u =>
      u.usar_nombre_usuario?.toLowerCase().includes(q) ||
      u.usar_correo?.toLowerCase().includes(q)         ||
      u.r_nombre?.toLowerCase().includes(q)            ||
      u.nombre_completo?.toLowerCase().includes(q)     ||
      u.tipo_vinculo?.toLowerCase().includes(q)
    );
  }

  protected get totalPaginas(): number {
    return Math.ceil(this.usuariosFiltrados.length / this.porPagina) || 1;
  }

  protected get usuariosPagina(): any[] {
    const inicio = (this.paginaActual() - 1) * this.porPagina;
    return this.usuariosFiltrados.slice(inicio, inicio + this.porPagina);
  }

  protected paginaAnterior(): void {
    if (this.paginaActual() > 1) this.paginaActual.set(this.paginaActual() - 1);
  }

  protected paginaSiguiente(): void {
    if (this.paginaActual() < this.totalPaginas) this.paginaActual.set(this.paginaActual() + 1);
  }

  protected onBusqueda(valor: string): void {
    this.busqueda.set(valor);
    this.paginaActual.set(1);
  }

  // ── Navegación de vistas ──────────────────────────────
  protected mostrarCrear(): void {
    this.limpiarForm();
    this.editandoId.set(null);
    this.vista.set('crear');
  }

  protected mostrarEditar(usuario: any): void {
    this.form.set({
      ...this.formVacio(),
      usar_nombre_usuario: usuario.usar_nombre_usuario || '',
      usar_correo:         usuario.usar_correo         || '',
      fk_r_usar:           usuario.r_id?.toString()    || '',
    });
    this.editandoId.set(usuario.usar_id);
    this.vista.set('editar');
  }

  protected volverTabla(): void {
    this.vista.set('tabla');
    this.errorMsg.set('');
    this.successMsg.set('');
  }

  // ── Crear usuario ─────────────────────────────────────
  protected async crearUsuario(): Promise<void> {
    const f = this.form();

    // Validación frontend básica
    if (!f.usar_nombre_usuario || !f.usar_correo || !f.usar_contrasena || !f.fk_r_usar) {
      this.errorMsg.set('Completa todos los campos obligatorios.');
      return;
    }
    if (f.tipo_persona === 'empresa' && (!f.razon_social || !f.rif)) {
      this.errorMsg.set('Razón social y RIF son obligatorios para empresas B2B.');
      return;
    }

    this.isLoading.set(true);
    this.errorMsg.set('');
    try {
      await this.supabase.callProcedure('crear_usuario', {
        p_nombre_usuario:   f.usar_nombre_usuario,
        p_correo:           f.usar_correo,
        p_contrasena:       f.usar_contrasena,
        p_rol:              parseInt(f.fk_r_usar),
        p_tipo:             f.tipo_persona,          // 'empleado' | 'cliente' | 'empresa'
        // Campos persona / empleado
        p_primer_nombre:    f.primer_nombre,
        p_primer_apellido:  f.primer_apellido,
        p_cedula:           f.cedula,
        p_telefono:         f.telefono,
        p_direccion:        f.direccion,
        // Campos empresa B2B (el procedure los ignora si p_tipo != 'empresa')
        p_razon_social:     f.razon_social     || null,
        p_nombre_comercial: f.nombre_comercial || null,
        p_rif:              f.rif              || null,
        p_limite_credito:   f.limite_credito ? parseFloat(f.limite_credito) : 0,
      });
      this.successMsg.set('Usuario creado exitosamente.');
      await this.cargarDatos();
      setTimeout(() => { this.volverTabla(); this.successMsg.set(''); }, 1500);
    } catch (e: any) {
      this.errorMsg.set(e?.message || 'Error al crear usuario.');
    } finally {
      this.isLoading.set(false);
    }
  }

  // ── Editar rol ────────────────────────────────────────
  protected async guardarEdicion(): Promise<void> {
    const f = this.form();
    if (!f.fk_r_usar) { this.errorMsg.set('Selecciona un rol.'); return; }
    this.isLoading.set(true);
    try {
      await this.supabase.callProcedure('modificar_rol_usuario', {
        p_id_usuario: this.editandoId(),
        p_id_rol:     parseInt(f.fk_r_usar),
      });
      this.successMsg.set('Rol actualizado exitosamente.');
      await this.cargarDatos();
      setTimeout(() => { this.volverTabla(); this.successMsg.set(''); }, 1500);
    } catch (e: any) {
      this.errorMsg.set(e?.message || 'Error al actualizar rol.');
    } finally {
      this.isLoading.set(false);
    }
  }

  // ── Eliminar usuario ──────────────────────────────────
  protected abrirModalEliminar(usuario: any): void {
    this.usuarioSeleccionado.set(usuario);
    this.confirmId.set('');
    this.modalEliminar.set(true);
  }

  protected cerrarModal(): void {
    this.modalEliminar.set(false);
    this.usuarioSeleccionado.set(null);
  }

  protected async confirmarEliminar(): Promise<void> {
    const u = this.usuarioSeleccionado();
    if (this.confirmId() !== u?.usar_id?.toString()) {
      this.errorMsg.set('El ID no coincide.');
      return;
    }
    this.isLoading.set(true);
    try {
      await this.supabase.callProcedure('eliminar_usuario', { p_id_usuario: u.usar_id });
      this.cerrarModal();
      await this.cargarDatos();
      this.successMsg.set('Usuario eliminado.');
      setTimeout(() => this.successMsg.set(''), 2000);
    } catch (e: any) {
      this.errorMsg.set(e?.message || 'Error al eliminar usuario.');
    } finally {
      this.isLoading.set(false);
    }
  }

  // ── Helpers ───────────────────────────────────────────
  protected updateForm(campo: string, valor: string): void {
    this.form.set({ ...this.form(), [campo]: valor });
  }

  private formVacio() {
    return {
      usar_nombre_usuario: '', usar_correo: '', usar_contrasena: '',
      fk_r_usar: '', tipo_persona: 'empleado' as TipoPersona,
      primer_nombre: '', segundo_nombre: '', primer_apellido: '',
      segundo_apellido: '', cedula: '', telefono: '', direccion: '',
      razon_social: '', nombre_comercial: '', rif: '', limite_credito: '',
    };
  }

  protected limpiarForm(): void {
    this.form.set(this.formVacio());
  }

  // Badge CSS según tipo de vínculo
  protected getTipoVinculoClass(tipo: string): string {
    switch (tipo) {
      case 'Empleado':    return 'badge-empleado';
      case 'Cliente B2C': return 'badge-cliente';
      case 'Empresa B2B': return 'badge-empresa';
      default:            return '';
    }
  }
}