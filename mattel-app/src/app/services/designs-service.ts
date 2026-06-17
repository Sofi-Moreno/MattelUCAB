import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { HttpHeaders } from '@angular/common/http';
import { tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class DesignsService {
  private supabaseUrl = 'https://vciukjsjsynqfiocokfg.supabase.co/rest/v1/rpc/lista_diseno_producto'; 
    private supabaseKey = 'sb_publishable_mfSdsbSFtBEtf6z-xsRQVw_zFBFI5CS';

  constructor(private http: HttpClient) {}

  getDisenos(): Observable<any[]> {
    const headers = new HttpHeaders({
      'apikey': this.supabaseKey,
      'Authorization': `Bearer ${this.supabaseKey}`,
      'Content-Type': 'application/json'
    });

    return this.http.post<any[]>(this.supabaseUrl, null, { headers }).pipe(
    tap(data => console.log('--- DATOS RECIBIDOS DESDE SUPABASE ---', data)),
    tap({
      error: (err) => console.error('--- ERROR AL RECIBIR DATOS ---', err)
    })
  );
  }
}
