import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { Supabase } from '../../services/supabase';

@Component({
  selector: 'app-profile',
  imports: [CommonModule],
  templateUrl: './profile.html',
  styleUrl: './profile.css',
})
export class Profile implements OnInit {

  perfil: any = null;
  isLoading = true;
  errorMsg = '';

  constructor(private supabase: Supabase, private router: Router) {}

  ngOnInit(): void {
    const session = localStorage.getItem('usuario');
    if (!session) {
      this.router.navigate(['/login']);
      return;
    }
    const usuario = JSON.parse(session);
    this.supabase.callProcedure('obtener_perfil_usuario', {
      p_id_usuario: usuario.usar_id,
    }).then((data: any[]) => {
      this.perfil = data?.[0] || null;
      this.isLoading = false;
    }).catch(() => {
      this.errorMsg = 'Error al cargar el perfil.';
      this.isLoading = false;
    });
  }

  getNombreCompleto(): string {
    if (!this.perfil) return '';
    if (this.perfil.tipo_vinculo === 'empresa') return this.perfil.razon_social || '';
    const partes = [
      this.perfil.primer_nombre,
      this.perfil.segundo_nombre,
      this.perfil.primer_apellido,
      this.perfil.segundo_apellido,
    ].filter(Boolean);
    return partes.join(' ');
  }

  getIniciales(): string {
    if (!this.perfil) return '';
    if (this.perfil.tipo_vinculo === 'empresa') {
      return (this.perfil.razon_social?.[0] || '?').toUpperCase();
    }
    const i1 = this.perfil.primer_nombre?.[0] || '';
    const i2 = this.perfil.primer_apellido?.[0] || '';
    return (i1 + i2).toUpperCase();
  }

  getTipoBadgeClass(): string {
    switch (this.perfil?.tipo_vinculo) {
      case 'empleado': return 'badge-empleado';
      case 'cliente':  return 'badge-cliente';
      case 'empresa':  return 'badge-empresa';
      default:         return 'badge-rol';
    }
  }

  getTipoLabel(): string {
    switch (this.perfil?.tipo_vinculo) {
      case 'empleado': return 'Empleado';
      case 'cliente':  return 'Cliente B2C';
      case 'empresa':  return 'Empresa B2B';
      default:         return '—';
    }
  }

  volver(): void {
    this.router.navigate(['/home']);
  }

  cerrarSesion(): void {
  localStorage.removeItem('usuario');
  this.router.navigate(['/login']);
}
}