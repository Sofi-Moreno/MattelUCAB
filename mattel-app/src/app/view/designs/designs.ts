import { Component, OnInit, ViewChild } from '@angular/core';
import { Subject, forkJoin} from 'rxjs';
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
  vistaActual: 'listado' | 'detalle' = 'listado';
  infoGeneral: any = null;
  categoriasTexto: string = '';
  tablaTaxonomia: any[] = [];
  tablaProfesiones: any[] = [];
  tablaFasesPruebas: any[] = [];

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
    this.isLoading = true;
    
    // Buscamos la info general localmente
    this.infoGeneral = this.disenos.find(d => d.dp_id === id);
    
    if (!this.infoGeneral) {
      console.error('No se encontró el diseño localmente');
      this.isLoading = false;
      return;
    }

    // forkJoin ejecuta todas las llamadas al mismo tiempo y nos devuelve todo junto
    forkJoin({
      catRes: this.service.getDetalleCategoria(id),
      taxRes: this.service.getDetalleTaxonomia(id),
      profRes: this.service.getDetalleProfesiones(id),
      faseRes: this.service.getDetalleFasesPruebas(id)
    }).subscribe({
      next: (resultados) => {
        // Asignamos los resultados a nuestras variables
        this.categoriasTexto = resultados.catRes || 'Sin categorías';
        this.tablaTaxonomia = resultados.taxRes || [];
        this.tablaProfesiones = resultados.profRes || [];
        this.tablaFasesPruebas = resultados.faseRes || [];
        
        // Cambiamos la vista para mostrar el detalle
        this.vistaActual = 'detalle';
        this.isLoading = false;
      },
      error: (error) => {
        console.error('Error cargando el detalle del diseño:', error);
        this.isLoading = false;
      }
    });
  }

  regresarAlListado(): void {
    this.vistaActual = 'listado';
    this.infoGeneral = null;
    this.categoriasTexto = '';
    this.tablaTaxonomia = [];
    this.tablaProfesiones = [];
    this.tablaFasesPruebas = [];
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
