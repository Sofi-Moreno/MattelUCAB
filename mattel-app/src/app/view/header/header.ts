import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, Router, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';

@Component({
  selector: 'app-header',
  imports: [CommonModule, RouterLink],
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class Header implements OnInit {
  protected isLoggedIn: boolean = true;
  protected isAdmin: boolean = true;
  protected showHeader: boolean = false;

  private hiddenRoutes = ['/', '/login', '/registro', '/recuperar'];

  constructor(private router: Router) {}

  ngOnInit(): void {
    // Verificar ruta actual al iniciar (después de que Angular resuelve la ruta)
    this.checkRoute(this.router.url);

    // Verificar en cada navegación
    this.router.events
      .pipe(filter(event => event instanceof NavigationEnd))
      .subscribe((event: NavigationEnd) => {
        this.checkRoute(event.urlAfterRedirects);
      });
  }

  private checkRoute(url: string): void {
    // Limpiar query params y fragmentos
    const cleanUrl = url.split('?')[0].split('#')[0];
    this.showHeader = !this.hiddenRoutes.includes(cleanUrl);
  }
}