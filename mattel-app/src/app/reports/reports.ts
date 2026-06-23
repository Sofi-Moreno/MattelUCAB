import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Supabase } from '../services/supabase';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './reports.html',
  styleUrl: './reports.css',
})
export class Reports implements OnInit {
  isLoading: boolean = false;
  successMsg: string = '';
  errorMsg: string = '';

  dreamhouseId: number = 1;
  mesesRetiro: number = 6;

  constructor(private supabase: Supabase) { }

  ngOnInit(): void { }

  async descargarPDF(tipoReporte: string) {
    this.isLoading = true;
    this.successMsg = '';
    this.errorMsg = '';
    console.log(`Iniciando generación de PDF para: ${tipoReporte}`);

    try {
      let data: any[] = [];
      let doc = new jsPDF();

      if (tipoReporte === 'inventario_estetica') {
        data = await this.supabase.callProcedure('reporte_inventario_por_cabello_piel');
        if (!data || data.length === 0) {
          this.errorMsg = 'No hay datos para este reporte.';
          this.isLoading = false;
          return;
        }

        doc.text('Disponibilidad por Estética', 14, 15);
        autoTable(doc, {
          startY: 20,
          head: [['Color Cabello', 'Tono Piel', 'SKUs Disponibles']],
          body: data.map(item => [item.color_cabello, item.tono_piel, item.skus_disponibles])
        });
        doc.save('reporte_inventario_estetica.pdf');

      } else if (tipoReporte === 'compatibilidad_dreamhouse') {
        data = await this.supabase.callProcedure('reporte_accesorios_compatibles', { p_dreamhouse_id: Number(this.dreamhouseId) });
        if (!data || data.length === 0) {
          this.errorMsg = 'No hay datos para este reporte.';
          this.isLoading = false;
          return;
        }

        doc.text(`Compatibilidad Dreamhouse (ID: ${this.dreamhouseId})`, 14, 15);
        autoTable(doc, {
          startY: 20,
          head: [['ID Accesorio', 'Nombre', 'En Stock', 'Hay Stock?']],
          body: data.map(item => [
            item.accesorio_id,
            item.accesorio,
            item.unidades_en_stock,
            item.hay_stock ? 'Sí' : 'No'
          ])
        });
        doc.save('reporte_compatibilidad_dreamhouse.pdf');

      } else if (tipoReporte === 'retirados_plm') {
        data = await this.supabase.callProcedure('reporte_skus_retirados', { p_meses: Number(this.mesesRetiro) });
        if (!data || data.length === 0) {
          this.errorMsg = 'No hay datos para este reporte.';
          this.isLoading = false;
          return;
        }

        doc.text(`Diseños Retirados con Stock (Hace más de ${this.mesesRetiro} meses)`, 14, 15);
        autoTable(doc, {
          startY: 20,
          head: [['SKU', 'ID Diseño', 'Nombre', 'Fecha Retiro', 'Meses', 'Precio', 'Disp. Desde']],
          body: data.map(item => [
            item.sku,
            item.diseno_id,
            item.diseno,
            item.fecha_retiro ? new Date(item.fecha_retiro).toLocaleDateString() : '',
            item.meses_desde_retiro,
            `$${item.precio_minorista}`,
            item.disponible_desde ? new Date(item.disponible_desde).toLocaleDateString() : ''
          ])
        });
        doc.save('reporte_skus_retirados.pdf');
      }

      this.successMsg = 'Documento PDF generado y descargado exitosamente.';
    } catch (error) {
      console.error('Error generando reporte:', error);
      this.errorMsg = 'Ocurrió un error al generar el reporte.';
    } finally {
      this.isLoading = false;
    }
  }
}