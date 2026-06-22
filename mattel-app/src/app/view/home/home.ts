import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, Router } from '@angular/router';

@Component({
  selector: 'app-home',
  imports: [CommonModule, RouterLink],
  templateUrl: './home.html',
  styleUrl: './home.css',
})
export class Home implements OnInit {

  nombreUsuario = '';
  rolNombre = '';

  puedeVerRoles    = false;
  puedeVerUsuarios = false;
  puedeVerDisenos  = false;
  puedeVerReportes = false;

  constructor(private router: Router) {}

  ngOnInit(): void {
    const session = localStorage.getItem('usuario');
    if (!session) {
      this.router.navigate(['/login']);
      return;
    }

    const usuario = JSON.parse(session);
    this.nombreUsuario = usuario.usar_nombre_usuario || '';
    this.rolNombre     = usuario.r_nombre            || '';
    const rolId        = usuario.r_id;

    switch (rolId) {
      case 5: 
        this.puedeVerRoles    = true;
        this.puedeVerUsuarios = true;
        this.puedeVerDisenos  = true;
        this.puedeVerReportes = true;
        break;
      case 1: 
        this.puedeVerDisenos  = true;
        this.puedeVerReportes = true;
        break;
      case 2: 
        this.puedeVerDisenos  = true;
        break;
      case 3: 
      case 4: 
      case 6: 
      default:
        break;
    }
  }
}
