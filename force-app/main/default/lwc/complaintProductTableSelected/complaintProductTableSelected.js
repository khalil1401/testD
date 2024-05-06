import { LightningElement, api, track } from 'lwc';

const colsDevoluciones=[
    {label:'Nombre',fieldName:'Dan360_NombreProducto__c', type:'text',hideDefaultActions: true},
    {label:'Cantidad a devolver',fieldName:'cantidad', type:'number',hideDefaultActions: true,editable : 'true'}
];

const colsDiferencia=[
    {label:'Nombre',fieldName:'Dan360_NombreProducto__c', type:'text',hideDefaultActions: true},
    {label:'Precio informado por el cliente',fieldName:'precio', type:'number',hideDefaultActions: true,editable : 'true'}
];

const colsFaltantes=[
    {label:'Nombre',fieldName:'Dan360_NombreProducto__c', type:'text',hideDefaultActions: true},
    {label:'Cantidad faltante',fieldName:'cantidad', type:'number',hideDefaultActions: true,editable : 'true'}
];

export default class ComplaintProductTableSelected extends LightningElement {
    
    @api productselected;
    @track columns;
    @api complainttypename;
    fieldToComplete;
    @api showdata;

    connectedCallback(){
        switch(this.complainttypename){
            case 'Dan360_Devoluciones':
                this.columns = colsDevoluciones;
                this.fieldToComplete = 'Cantidad a devolver';
                break;
            case 'Dan360_DiferenciaPreciosDescuentos':
                this.columns = colsDiferencia;
                this.fieldToComplete = 'Precio informado por el cliente';
                break;
            case 'Dan360_ReclamoPorFaltantes':
                this.columns = colsFaltantes;
                this.fieldToComplete = 'Cantidad faltante';
                break;
        }
    }

}