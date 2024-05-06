import { LightningElement, wire, api, track } from 'lwc';
import saveProducts from '@salesforce/apex/ProductListComponentController.saveProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const cols=[
    {label:'Código de producto',fieldName:'productCode',initialWidth: 140, type:'text',hideDefaultActions: true},
    {label:'Nombre',fieldName:'name',initialWidth: 306, type:'text',hideDefaultActions: true},
    {label:'Cantidad',fieldName:'cantidad',initialWidth: 80, type:'number',hideDefaultActions: true, editable : 'true'},
    {label:'Unidad de Medida',fieldName:'unidadMedida',initialWidth: 130, type:'text',hideDefaultActions: true},
    {label:'Factor de redondeo',fieldName:'bulto',initialWidth: 140, type:'number',hideDefaultActions: true},
    {label:'Precio Unitario',fieldName:'price', initialWidth: 110, type:'currency',hideDefaultActions: true},
    {label:'Descuento (%)',fieldName:'descuento', initialWidth: 110, type:'number',hideDefaultActions: true},
    {label:'Precio Aproximado',fieldName:'totalPrice', initialWidth: 140, type:'currency',hideDefaultActions: true},
    {type: 'button-icon', typeAttributes:{ iconName: 'utility:delete', name: 'delete', iconClass: 'slds-icon-text-error'}}
];

export default class ProductsSelectedList extends LightningElement {
    @track columns = cols;
    @track isDisabled = false;
    @api products;
    showButton = false;
    stylesLoaded = false;
    
  
    guardarValores(event){
        let producto = event.detail.draftValues;
        this.template.querySelector('lightning-datatable').saveDraftValues;
        //Si lo que se modifico es una cantidad, solicito que se calculen los totales
        //si el valor es un numero negativo se ignora el cambio
        if(producto[0].cantidad && producto[0].cantidad > 0){
            this.template.querySelector('lightning-datatable').saveDraftValues;
            const calcularEvent = new CustomEvent('qantitychange', {
                detail:  producto[0]
            });
            this.dispatchEvent(calcularEvent);
        }else if(producto[0].cantidad && producto[0].cantidad < 0){
            this.template.querySelector('lightning-datatable').draftValues = [];
        }
        //Se re-renderiza la tabla para mostrar las cantidades sin el edit realizado
        this.columns = [...cols];
        this.showButton = true;
    }

    handleSave(event){
        console.log('Save Action');
        let dataa = this.template.querySelector('lightning-datatable').data;
        console.log('dataa', JSON.stringify(dataa));
        this.isDisabled = true;
        this.showButton = false;
        saveProducts({listProducts: JSON.stringify(dataa)})
            .then((result) => {
                console.log('Exito');
                console.log(result);
                
                let toastEvent = new ShowToastEvent({
                    title: "Productos Agregados",
                    message: result,
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);

                let closeQA = new CustomEvent('close');
                    // Dispatches the event.
                    this.dispatchEvent(closeQA);
                    })

            .catch((error) => {
                console.log(error.data);
                this.isDisabled = false;
                this.showButton = true;
                let toastEventError = new ShowToastEvent({
                    title: "Error al agregar Productos",
                    message: error,
                    variant: "error"
                });
                this.dispatchEvent(toastEventError);
            });

            
    }

    handleClose(event){
        let closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleRowAction(event) {
        const unSelect = new CustomEvent('unselect',{
            detail: event.detail.row.productoId
        });
        this.dispatchEvent(unSelect);
    }
    
   
}