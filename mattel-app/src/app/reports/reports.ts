import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './reports.html',
  styleUrl: './reports.css',
})
export class Reports implements OnInit {
  isLoading: boolean = false;
  successMsg: string = '';
  errorMsg: string = '';

  constructor() {}

  ngOnInit(): void {}

  descargarPDF(tipoReporte: string): void {
    this.isLoading = true;
    console.log(`Iniciando generación de PDF para: ${tipoReporte}`);
    
    this.successMsg = 'Preparando documento ... La descarga iniciará pronto.';
    
    setTimeout(() => {
      this.successMsg = '';
      this.isLoading = false;
    }, 3000);
  }
}