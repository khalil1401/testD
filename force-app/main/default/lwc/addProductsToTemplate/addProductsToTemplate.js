import { LightningElement, wire, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getProducts from '@salesforce/apex/AddProductsToTemplateController.getProducts';
import getPicklistOptions from '@salesforce/apex/AddProductsToTemplateController.getPicklistValues';


const cols=[
    {label:'Código de producto',fieldName:'productCode', type:'text',hideDefaultActions: true, sortable: true},
    {label:'Nombre',fieldName:'name', type:'text',hideDefaultActions: true, sortable: true},
   
];

export default class ProductList extends LightningElement {
    
    @track columns = cols;
    @track selection;
    @track products;
    @track selectedProducts = [];
    @api recordId;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    isLoading = true;
    picklistOptions;
    productSelections = [];   
   

    connectedCallback() {
        console.log(`recordId: ${this.recordId}`);
        getProducts({recordId: this.recordId})
            .then((result) => {
                this.products = result;
                this.isLoading = false;
                console.log('Products: '+ JSON.stringify(this.products));
               
            })
            .catch((error) => {
                console.log(error);
            });
        getPicklistOptions()
            .then((result) => {
                this.picklistOptions = result;
                console.log(result);
                
            })
            .catch((error) => {
                console.log(error);
            });

    }

    getSelected(event) {
        let el = this.template.querySelector('lightning-datatable');
        let selected = el.getSelectedRows();
        console.log('selected '+JSON.stringify(this.selectedProducts));
        this.selectedProducts = selected.map(record => {
            return {
                'picklistOptions': this.picklistOptions, // se agregan las opciones de las picklist a la datatable hijo
                ...record
            }
        });
        console.log('selected Products: '+JSON.stringify(this.selectedProducts));
    }

    valuesChange(event){
        let productSelected = this.selectedProducts.find(prod => prod.productoId === event.detail.productoId);
        let producto = this.products.find(prod => prod.productoId === event.detail.productoId);
        console.log('estoy en el event');
        if (event.detail.unidadMedida) {
            productSelected = this.selectedProducts.find(prod => prod.productCode === event.detail.productCode);
            producto = this.products.find(prod => prod.productCode === event.detail.productCode);
            
            console.log(`IF unidad de medida: ${event.detail.unidadMedida}`);
            producto.unidadMedida = event.detail.unidadMedida;            
            productSelected.unidadMedida = event.detail.unidadMedida;            
        }         
        if (event.detail.vigenciaDesde) {
            console.log(`IF vigencia desde: ${event.detail.vigenciaDesde}`);
            producto.vigenciaDesde = event.detail.vigenciaDesde;            
            productSelected.vigenciaDesde = event.detail.vigenciaDesde;            
        }
        if (event.detail.vigenciaHasta) {
            console.log(`IF vigencia hasta: ${event.detail.vigenciaHasta}`);
            producto.vigenciaHasta = event.detail.vigenciaHasta;            
            productSelected.vigenciaHasta = event.detail.vigenciaHasta;            
        }         
        
    }

    closeQuickAction(event){
        let closeAura = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeAura);
       
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.products];
        
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.products = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    unSelectProduct(event){
        this.selectedProducts = this.selectedProducts.filter(item => item.productoId !== event.detail);
        let idsSeleccionados = [];
        this.selectedProducts.forEach(element => {
            idsSeleccionados.push(element.productoId);
        });
        this.selection = idsSeleccionados;
        // this.calcularTotalPedido()
    }

    handleSelectProductSearch(event){
        let itemId = event.detail;
        let table = this.template.querySelector('lightning-datatable');
        let selectedids = table.getSelectedRows();
        let idsSeleccionados = [];
        let itemsSeleccionados = table.getSelectedRows();
        console.log('selected '+this.selectedProducts);
        //Se agrega el item seleccionado a selected items
        let productoAgregado = this.products.find(item => item.productoId === itemId);
        if(productoAgregado){
            itemsSeleccionados.push(productoAgregado);
        }
        this.selectedProducts = itemsSeleccionados.map(record => {
            return {
                'picklistOptions': this.picklistOptions, // se agregan las opciones de las picklist a la datatable hijo
                ...record,
            }
        });
        
        //para que la dataTable de productos marque el check necesita los Id
        selectedids.forEach(element => {
            idsSeleccionados.push(element.productoId);
        });
        idsSeleccionados.push(itemId);
        this.selection = idsSeleccionados;
    }
   
}