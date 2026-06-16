import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { Supabase } from '../../services/supabase';

@Component({
  selector: 'app-login',
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './login.html',
  styleUrl: './login.css',
})
export class Login {
  protected email = signal('');
  protected password = signal('');
  protected showPassword = signal(false);
  protected isLoading = signal(false);
  protected errorMessage = signal('');

  constructor(
    private supabaseService: Supabase,
    private router: Router
  ) {}

  protected togglePassword(): void {
    this.showPassword.set(!this.showPassword());
  }

  protected async onSubmit(): Promise<void> {
    if (!this.email() || !this.password()) {
      this.errorMessage.set('Por favor completa todos los campos.');
      return;
    }

    this.isLoading.set(true);
    this.errorMessage.set('');

    try {
      const result = await this.supabaseService.callProcedure('login_usuario', {
        p_correo: this.email(),
        p_contrasena: this.password(),
      });

      if (result && result.length > 0) {
        const usuario = result[0];
        localStorage.setItem('usuario', JSON.stringify(usuario));
        this.router.navigate(['/home']);
      } else {
        this.errorMessage.set('Correo o contraseña incorrectos.');
      }
    } catch (error: any) {
      console.error('Error en login:', error);
      this.errorMessage.set('Error al iniciar sesión. Intenta de nuevo.');
    } finally {
      this.isLoading.set(false);
    }
  }
}