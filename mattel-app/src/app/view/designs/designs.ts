import { Component } from '@angular/core';
import { Subject } from 'rxjs';
import { DesignsService } from '../../services/designs-service';
import { DataTablesModule } from 'angular-datatables';
import { OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import * as $ from 'jquery';

@Component({
  selector: 'app-designs',
  imports: [DataTablesModule, CommonModule],
  templateUrl: './designs.html',
  styleUrl: './designs.css',
})
export class Designs implements OnInit {
  disenos: any[] = [];
  dtOptions: any = {};
  dtTrigger: Subject<any> = new Subject<any>();

  constructor(private service: DesignsService) {}

  ngOnInit(): void {
    this.dtOptions = {
      pagingType: 'simple_numbers', 
      pageLength: 5,
      lengthChange: false,
      searching: true, 
      ordering: true,  
      responsive: false,
      language: {
      search: "Buscar", 
      info: "Mostrando _START_ - _END_ de _TOTAL_ registros", 
      paginate: {
        next: "Siguiente",
        previous: "Anterior"
      }
    }
    };
    
    this.service.getDisenos().subscribe(data => {
      this.disenos = data;
      
      setTimeout(() => {
        this.dtTrigger.next(null);
      }, 200);
    });
  }

  verDetalle(id: number): void {
    console.log('Navegando a la vista ampliada del diseño ID:', id);
  }

  editarDiseno(id: number): void {
    console.log('Abriendo formulario de edición para el diseño ID:', id);
  }

  eliminarDiseno(id: number): void {
    if (confirm(`¿Estás seguro de que deseas eliminar el diseño #${id}?`)) {
      console.log('Ejecutando llamada a Supabase para eliminar el ID:', id);
    }
  }
}
