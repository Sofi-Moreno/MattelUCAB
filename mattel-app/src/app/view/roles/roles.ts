import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Subject } from 'rxjs';
import { DataTablesModule } from 'angular-datatables';
import { Supabase } from '../../services/supabase';

@Component({
  selector: 'app-roles',
  imports: [CommonModule, FormsModule, DataTablesModule],
  templateUrl: './roles.html',
  styleUrl: './roles.css',
})
export class Roles implements OnInit {

  roles: any[] = [];
  usuarios: any[] = [];

  dtOptions: any = {};
  dtTrigger: Subject<any> = new Subject<any>();

  isLoading = false;
  errorMsg = '';
  successMsg = '';

  // Modals state
  modalUsuarios = false;
  modalPermisos = false;
  modalCrear = false;

  // Create Role state
  nuevoRolNombre = '';
  nuevoRolDesc = '';
  isSaving = false;

  rolSeleccionado: any = null;
  usuariosDelRol: any[] = [];
  permisosSimulados: string[] = [];

  constructor(private supabase: Supabase) { }

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
        info: 'Mostrando _START_ - _END_ de _TOTAL_ roles',
        zeroRecords: 'No se encontraron roles',
        paginate: { next: 'Siguiente', previous: 'Anterior' },
      },
    };
    this.cargarDatos();
  }


  cargarDatos(): void {
    this.isLoading = true;
    Promise.all([
      this.supabase.callProcedure('listar_roles'),
      this.supabase.callProcedure('listar_usuarios')
    ]).then(([roles, usuarios]) => {
      this.roles = roles || [];
      this.usuarios = usuarios || [];
      setTimeout(() => {
        this.isLoading = false;
        setTimeout(() => this.dtTrigger.next(null), 50);
      }, 0);
    }).catch(() => {
      this.errorMsg = 'Error al cargar datos.';
      this.isLoading = false;
    });
  }

  verUsuarios(rol: any): void {
    this.rolSeleccionado = rol;
    this.usuariosDelRol = this.usuarios.filter(u => u.r_id === rol.r_id);
    this.modalUsuarios = true;
  }

  verPermisos(rol: any): void {
    this.rolSeleccionado = rol;
    // Permisos simulados para este rol
    this.permisosSimulados = [
      'Crear usuario',
      'Editar perfil',
      'Visualizar reportes',
      'Aprobar diseños',
      'Acceso al sistema'
    ];
    this.modalPermisos = true;
  }

  abrirModalCrear(): void {
    this.nuevoRolNombre = '';
    this.nuevoRolDesc = '';
    this.modalCrear = true;
  }

  async guardarRol() {
    if (!this.nuevoRolNombre || !this.nuevoRolDesc) return;
    
    this.isSaving = true;
    this.errorMsg = '';
    this.successMsg = '';

    try {
      await this.supabase.callProcedure('crear_rol', {
        p_nombre: this.nuevoRolNombre,
        p_descripcion: this.nuevoRolDesc
      });
      
      this.successMsg = `Rol "${this.nuevoRolNombre}" creado exitosamente.`;
      this.cerrarModales();
      // Recargar la página para refrescar DataTables de forma segura
      setTimeout(() => window.location.reload(), 1500);
      
    } catch (error: any) {
      this.errorMsg = error.message || 'Ocurrió un error al crear el rol.';
      this.isSaving = false;
    }
  }

  cerrarModales(): void {
    this.modalUsuarios = false;
    this.modalPermisos = false;
    this.modalCrear = false;
    this.rolSeleccionado = null;
    this.usuariosDelRol = [];
    this.permisosSimulados = [];
    this.nuevoRolNombre = '';
    this.nuevoRolDesc = '';
    this.isSaving = false;
  }
}
