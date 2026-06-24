import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class DesignsService {
  private baseUrl = 'https://vciukjsjsynqfiocokfg.supabase.co/rest/v1/rpc';
  private urlListar = `${this.baseUrl}/lista_diseno_producto`; 
  private urlEliminar = `${this.baseUrl}/eliminar_diseno_producto`; 
    private urlCategoria = `${this.baseUrl}/detalle_categoria`;
  private urlTaxonomia = `${this.baseUrl}/detalle_taxonomia`;
  private urlProfesiones = `${this.baseUrl}/detalle_profesiones`;
  private urlFasesPruebas = `${this.baseUrl}/detalle_fases_pruebas`;
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

  getDetalleCategoria(id: number): Observable<string> {
    return this.http.post<string>(this.urlCategoria, { id_diseno: id }, { headers: this.getHeaders() });
  }

  getDetalleTaxonomia(id: number): Observable<any[]> {
    return this.http.post<any[]>(this.urlTaxonomia, { id_diseno: id }, { headers: this.getHeaders() });
  }

  getDetalleProfesiones(id: number): Observable<any[]> {
    return this.http.post<any[]>(this.urlProfesiones, { id_diseno: id }, { headers: this.getHeaders() });
  }

  getDetalleFasesPruebas(id: number): Observable<any[]> {
    return this.http.post<any[]>(this.urlFasesPruebas, { id_diseno: id }, { headers: this.getHeaders() });
  }
}