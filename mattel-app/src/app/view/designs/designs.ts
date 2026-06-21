import { Component, OnInit, ViewChild } from '@angular/core';
import { Subject } from 'rxjs';
import { DesignsService } from '../../services/designs-service';
import { DataTablesModule, DataTableDirective } from 'angular-datatables';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-designs',
  imports: [DataTablesModule, CommonModule],
  templateUrl: './designs.html',
  styleUrl: './designs.css',
})
export class Designs implements OnInit {
  @ViewChild(DataTableDirective, { static: false }) dtElement!: DataTableDirective;
  disenos: any[] = [];
  dtOptions: any = {};
  dtTrigger: Subject<any> = new Subject<any>();
  modalEliminar: boolean = false;
  disenoSeleccionado: any = null;
  confirmId: string = '';
  errorModalMsg: string = '';
  successMsg: string = '';
  isLoading: boolean = false;

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

  cargarDatos(): void {
    this.service.getDisenos().subscribe({
      next: (data) => {
        if (this.dtElement && this.dtElement.dtInstance) {
          this.dtElement.dtInstance.then((dtInstance: any) => {
            dtInstance.destroy();

            this.disenos = data;

            setTimeout(() => {
              this.dtTrigger.next(null);
            }, 50);
          });
        } else {

          this.disenos = data;
          setTimeout(() => {
            this.dtTrigger.next(null);
          }, 50);
        }
      },
      error: (err) => {
        console.error('Error al cargar diseños:', err);
      }
    });
  }
  
  verDetalle(id: number): void {
    console.log('Navegando a la vista ampliada del diseño ID:', id);
  }

  editarDiseno(id: number): void {
    console.log('Abriendo formulario de edición para el diseño ID:', id);
  }

  eliminarDiseno(id: number): void {
    const diseno = this.disenos.find(d => d.dp_id === id);
    if (diseno) {
      this.disenoSeleccionado = diseno;
      this.confirmId = '';
      this.errorModalMsg = '';
      this.modalEliminar = true;
    }
  }

  cerrarModal(): void {
    this.modalEliminar = false;
    this.disenoSeleccionado = null;
    this.confirmId = '';
    this.errorModalMsg = '';
  }

  confirmarEliminar(): void {
    const d = this.disenoSeleccionado;
    
    if (!d || this.confirmId !== d.dp_id.toString()) {
      this.errorModalMsg = 'El ID no coincide.';
      return;
    }

    this.isLoading = true;
    this.errorModalMsg = '';

    this.service.eliminarDiseno(d.dp_id).subscribe({
      next: (res) => {
        this.cerrarModal();
        
        this.cargarDatos(); 
        
        this.successMsg = 'Diseño de producto eliminado exitosamente.';
        setTimeout(() => this.successMsg = '', 2000);
        this.isLoading = false;
      },
      error: (e: any) => {
        this.errorModalMsg = e?.error?.message || e?.message || 'Error al eliminar el diseño. Puede que esté en uso en producción.';
        this.isLoading = false;
      }
    });
  }
}
