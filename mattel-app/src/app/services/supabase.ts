import { Injectable } from '@angular/core';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root',
})
export class Supabase {
  private supabase: SupabaseClient;

  constructor() {
    //inicializacion del cliente de Supabase con la URL y la clave del entorno
    this.supabase = createClient(environment.supabaseUrl, environment.supabaseKey);
  }

  //Metodo para llamar cualquier procedimiento almacenado
  async callProcedure(procedureName: string, params?: any) {
    const { data, error } = await this.supabase.rpc(procedureName, params);
    if (error) {
      console.error('Error calling procedure:', error);
      throw error;
    }
    return data;
  }
}
