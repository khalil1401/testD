import { LightningElement, wire, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getProducts from '@salesforce/apex/ProductListComponentController.getProductList';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import {refreshApex} from '@salesforce/apex';


const cols=[
    {label:'Código de producto',fieldName:'productCode', type:'text',hideDefaultActions: true, sortable: true},
    {label:'Nombre',fieldName:'name', type:'text',hideDefaultActions: true, sortable: true},
    {label:'Unidad de Medida',fieldName:'unidadMedida', type:'text',hideDefaultActions: true},
    {label:'Factor de redondeo',fieldName:'bulto', type:'number',hideDefaultActions: true},
    {label:'Precio unitario',fieldName:'price', type:'currency',hideDefaultActions: true}
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
    totalProducts;
    productSelections = [];
    valorAnterior;
    @track selection = [''];
    @track prectioTotal;

    connectedCallback() {
        getProducts({recordId: this.recordId})
            .then((result) => {
                this.products = result;
                console.log(this.products);
                //console.log(this.products);
                this.totalProducts = result;
                if(result.length > 0) {
                    this.prectioTotal = result[0].orderPrice;
                    this.valorAnterior =  result[0].orderPrice;
                }
            })
            .catch((error) => {
                console.log(error);
            });
    }

    getSelected(event) {
        let el = this.template.querySelector('lightning-datatable');
        let selected = el.getSelectedRows();
        this.selectedProducts = selected;
        this.calcularTotalPedido()
    }

    calcularTotal(event){
        let producto = this.products.find(prod => prod.productoId === event.detail.productoId);

        producto.cantidad = event.detail.cantidad;
        
        //Si el producto es Trade Unit se debe redondear a cantidades que se puedan entregar por bulto
        if(producto.unidadMedida == "Trade Unit" && producto.cantidad % producto.bulto != 0){
            let dif = producto.cantidad % producto.bulto;
            dif = parseInt(producto.bulto) - parseInt(dif);
            producto.cantidad = parseInt(producto.cantidad) + parseInt(dif);
        }
        if(producto.descuento == null){
            producto.descuento = 0;
        }
        let descuento = (producto.cantidad * producto.price) * (producto.descuento /100);
        //console.log(descuento);
        producto.totalPrice = (producto.cantidad * producto.price) - descuento;
        //console.log(producto.totalPrice);

        this.calcularTotalPedido()
        
        
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
        this.calcularTotalPedido()
    }

    handleSelectProductSearch(event){
        let itemId = event.detail;
        let table = this.template.querySelector('lightning-datatable');
        let selectedids = table.getSelectedRows();
        let idsSeleccionados = [];
        let itemsSeleccionados = table.getSelectedRows();
        
        //Se agrega el item seleccionado a selected items
        let productoAgregado = this.products.find(item => item.productoId === itemId);
        if(productoAgregado){
            itemsSeleccionados.push(productoAgregado);
        }
        this.selectedProducts = itemsSeleccionados;
        
        //para que la dataTable de productos marque el check necesita los Id
        selectedids.forEach(element => {
            idsSeleccionados.push(element.productoId);
        });
        idsSeleccionados.push(itemId);
        this.selection = idsSeleccionados;
    }

    calcularTotalPedido() {
        let precio = 0;
        console.log(this.selectedProducts);
        this.selectedProducts.forEach(element => {
            //console.log(element.totalPrice);
            precio += element.totalPrice;
        });
        //console.log(precio);
        //console.log(this.valorAnterior);
        //console.log(this.prectioTotal);
        
        if(this.prectioTotal > 0) {
            this.prectioTotal = this.valorAnterior;
            if(precio > 0) {
                this.prectioTotal = this.valorAnterior + precio;
            } 
        } else {
            this.prectioTotal = precio;
        }

    }
}