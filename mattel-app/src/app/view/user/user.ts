import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Subject } from 'rxjs';
import { DataTablesModule } from 'angular-datatables';
import { Supabase } from '../../services/supabase';

type TipoPersona = 'empleado' | 'cliente' | 'empresa';
type Vista = 'tabla' | 'crear' | 'editar';

@Component({
  selector: 'app-user',
  imports: [CommonModule, FormsModule, DataTablesModule],
  templateUrl: './user.html',  
  styleUrl: './user.css',      
})
export class User implements OnInit, OnDestroy {  

  usuarios: any[] = [];
  roles: any[] = [];
  dtOptions: any = {};
  dtTrigger: Subject<any> = new Subject<any>();

  vista: Vista = 'tabla';
  isLoading = false;
  errorMsg = '';
  successMsg = '';

  modalEliminar = false;
  usuarioSeleccionado: any = null;
  confirmId = '';
  editandoId: number | null = null;

  form = this.formVacio();

  constructor(private supabase: Supabase) {}

  ngOnInit(): void {
    this.dtOptions = {
      pagingType: 'simple_numbers',
      pageLength: 5,
      lengthChange: false,
      searching: true,
      ordering: true,
      responsive: false,
      language: {
        search: 'Buscar',
        info: 'Mostrando _START_ - _END_ de _TOTAL_ usuarios',
        zeroRecords: 'No se encontraron usuarios',
        paginate: { next: 'Siguiente', previous: 'Anterior' },
      },
    };
    this.cargarDatos();
  }

  ngOnDestroy(): void {
    this.dtTrigger.complete();
  }

  cargarDatos(): void {
    this.isLoading = true;
    Promise.all([
      this.supabase.callProcedure('listar_usuarios'),
      this.supabase.callProcedure('listar_roles'),
    ]).then(([usuarios, roles]) => {
      this.usuarios = usuarios || [];
      this.roles    = roles    || [];
      setTimeout(() => {
        this.isLoading = false;
        setTimeout(() => this.dtTrigger.next(null), 50);
      }, 0);
    }).catch(() => {
      this.errorMsg = 'Error al cargar datos.';
      this.isLoading = false;
    });
  }

  mostrarCrear(): void {
    this.form = this.formVacio();
    this.editandoId = null;
    this.errorMsg = '';
    this.successMsg = '';
    this.vista = 'crear';
  }

  mostrarEditar(usuario: any): void {
  this.form = {
    ...this.formVacio(),
    usar_nombre_usuario: usuario.usar_nombre_usuario || '',
    usar_correo:         usuario.usar_correo         || '',
    fk_r_usar:           usuario.r_id?.toString()    || '',
    tipo_persona: usuario.tipo_vinculo === 'Empleado'    ? 'empleado'
                : usuario.tipo_vinculo === 'Cliente B2C' ? 'cliente'
                : usuario.tipo_vinculo === 'Empresa B2B' ? 'empresa'
                : 'empleado',
  };
  this.editandoId = usuario.usar_id;
  this.errorMsg = '';
  this.successMsg = '';
  this.vista = 'editar';
  }

  volverTabla(): void {
    this.vista = 'tabla';
    this.errorMsg = '';
    this.successMsg = '';
  }

  crearUsuario(): void {
    if (!this.form.usar_nombre_usuario || !this.form.usar_correo ||
        !this.form.usar_contrasena || !this.form.fk_r_usar) {
      this.errorMsg = 'Completa todos los campos obligatorios.';
      return;
    }
    this.isLoading = true;
    this.errorMsg = '';
    this.supabase.callProcedure('crear_usuario', {
      p_nombre_usuario:   this.form.usar_nombre_usuario,
      p_correo:           this.form.usar_correo,
      p_contrasena:       this.form.usar_contrasena,
      p_rol:              parseInt(this.form.fk_r_usar),
      p_tipo:             this.form.tipo_persona,
      p_primer_nombre:    this.form.primer_nombre,
      p_primer_apellido:  this.form.primer_apellido,
      p_cedula:           this.form.cedula,
      p_telefono:         this.form.telefono,
      p_direccion:        this.form.direccion,
      p_razon_social:     this.form.razon_social     || null,
      p_nombre_comercial: this.form.nombre_comercial || null,
      p_rif:              this.form.rif              || null,
      p_limite_credito:   this.form.limite_credito ? parseFloat(this.form.limite_credito) : 0,
    }).then(() => {
      this.successMsg = 'Usuario creado exitosamente.';
      this.isLoading = false;
      setTimeout(() => this.volverTabla(), 1500);
    }).catch((e: any) => {
      this.errorMsg = e?.message || 'Error al crear usuario.';
      this.isLoading = false;
    });
  }

  guardarEdicion(): void {
  if (!this.form.fk_r_usar) { this.errorMsg = 'Selecciona un rol.'; return; }
  this.isLoading = true;
  this.errorMsg = '';
  this.supabase.callProcedure('editar_usuario', {
    p_id_usuario:       this.editandoId,
    p_nombre_usuario:   this.form.usar_nombre_usuario || null,
    p_correo:           this.form.usar_correo         || null,
    p_contrasena:       this.form.usar_contrasena     || null,
    p_id_rol:           parseInt(this.form.fk_r_usar),
    p_primer_nombre:    this.form.primer_nombre       || null,
    p_segundo_nombre:   this.form.segundo_nombre      || null,
    p_primer_apellido:  this.form.primer_apellido     || null,
    p_segundo_apellido: this.form.segundo_apellido    || null,
    p_telefono:         this.form.telefono            || null,
    p_direccion:        this.form.direccion           || null,
    p_razon_social:     null,
    p_nombre_comercial: this.form.nombre_comercial    || null,
    p_limite_credito:   this.form.limite_credito ? parseFloat(this.form.limite_credito) : null,
    p_sueldo_base_us:   this.form.sueldo_base_us ? parseFloat(this.form.sueldo_base_us) : null,
  }).then(() => {
    this.successMsg = 'Usuario actualizado exitosamente.';
    this.isLoading = false;
    setTimeout(() => this.volverTabla(), 1500);
  }).catch((e: any) => {
    this.errorMsg = e?.message || 'Error al actualizar usuario.';
    this.isLoading = false;
  });
  }

  abrirModalEliminar(usuario: any): void {
    this.usuarioSeleccionado = usuario;
    this.confirmId = '';
    this.errorMsg = '';
    this.modalEliminar = true;
  }

  cerrarModal(): void {
    this.modalEliminar = false;
    this.usuarioSeleccionado = null;
  }

  confirmarEliminar(): void {
    if (this.confirmId !== this.usuarioSeleccionado?.usar_id?.toString()) {
      this.errorMsg = 'El ID no coincide.';
      return;
    }
    this.isLoading = true;
    this.supabase.callProcedure('eliminar_usuario', {
      p_id_usuario: this.usuarioSeleccionado.usar_id,
    }).then(() => {
      this.cerrarModal();
      this.isLoading = false;
      this.successMsg = 'Usuario eliminado.';
      setTimeout(() => this.successMsg = '', 2000);
    }).catch((e: any) => {
      this.errorMsg = e?.message || 'Error al eliminar usuario.';
      this.isLoading = false;
    });
  }

  getTipoVinculoClass(tipo: string): string {
    switch (tipo) {
      case 'Empleado':        return 'badge-empleado';
      case 'Cliente B2C':
      case 'Persona Natural': return 'badge-cliente';
      case 'Empresa B2B':     return 'badge-empresa';
      default:                return 'badge-rol';
    }
  }

  private formVacio() {
  return {
    usar_nombre_usuario: '',
    usar_correo:         '',
    usar_contrasena:     '',
    fk_r_usar:           '',
    tipo_persona:        'empleado' as TipoPersona,
    primer_nombre:       '',
    segundo_nombre:      '',
    primer_apellido:     '',
    segundo_apellido:    '',
    cedula:              '',
    telefono:            '',
    direccion:           '',
    razon_social:        '',
    nombre_comercial:    '',
    rif:                 '',
    limite_credito:      '',
    sueldo_base_us:      '',  // ← nuevo
  };
  }
}