import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class DesignsService {
  // URLs para llamar a los procedimientos almacenados a través de la API REST de Supabase
  private urlListar = 'https://vciukjsjsynqfiocokfg.supabase.co/rest/v1/rpc/lista_diseno_producto'; 
  private urlEliminar = 'https://vciukjsjsynqfiocokfg.supabase.co/rest/v1/rpc/eliminar_diseno_producto'; 
  
  private supabaseKey = 'sb_publishable_mfSdsbSFtBEtf6z-xsRQVw_zFBFI5CS';

  constructor(private http: HttpClient) {}

  // Cabeceras reutilizables para las peticiones a Supabase
  private getHeaders(): HttpHeaders {
    return new HttpHeaders({
      'apikey': this.supabaseKey,
      'Authorization': `Bearer ${this.supabaseKey}`,
      'Content-Type': 'application/json'
    });
  }

  getDisenos(): Observable<any[]> {
    return this.http.post<any[]>(this.urlListar, null, { headers: this.getHeaders() }).pipe(
      tap(data => console.log('--- DATOS RECIBIDOS DESDE SUPABASE ---', data)),
      tap({
        error: (err) => console.error('--- ERROR AL RECIBIR DATOS ---', err)
      })
    );
  }

  eliminarDiseno(id: number): Observable<any> {
    const body = { p_id_diseno: id };
    return this.http.post<any>(this.urlEliminar, body, { headers: this.getHeaders() }).pipe(
      tap(res => console.log('--- DISEÑO ELIMINADO EN SUPABASE ---', res)),
      tap({
        error: (err) => console.error('--- ERROR AL ELIMINAR DISEÑO ---', err)
      })
    );
  }
}