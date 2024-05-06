import { LightningElement, api, track } from 'lwc';
import saveProducts from '@salesforce/apex/AddProductsToTemplateController.saveProducts';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const cols=[
    {label:'Código de producto',fieldName:'productCode', type:'text',hideDefaultActions: true},
    {label:'Nombre',fieldName:'name', type:'text',hideDefaultActions: true},
    {label:'Unidad de Medida',fieldName:'unidadMedida', type:'unidadMedidaPicklist', wrapText: true, initialWidth: 150,
        typeAttributes: {
            options: { fieldName: 'picklistOptions' }, // list of all picklist options
            contex: { fieldName: 'productCode' },
            placeholder: 'Seleccionar'
        },
    },
    {label:'Vigencia Desde',fieldName:'vigenciaDesde', type:'date-local',hideDefaultActions: true, editable: true},
    {label:'Vigencia Hasta',fieldName:'vigenciaHasta', type:'date-local',hideDefaultActions: true, editable: true},
    {type: 'button-icon', initialWidth: 30, typeAttributes:{ iconName: 'utility:delete', name: 'delete', iconClass: 'slds-icon-text-error'}}
];

export default class ProductsSelectedList extends LightningElement {
    @track columns = cols;
    @api products = [];
    @api id;
    @track save = false;
    showButton = false;   
   
   
    handleCellChange(event){
        
        let producto = event.detail.draftValues;
        console.log('estoy en handleCellChange valores: '+ JSON.stringify(producto));
        this.template.querySelector('c-custom-types').saveDraftValues;       
               
        if(producto[0]){
            console.log('estoy en if  '+ JSON.stringify(producto[0]));           
                this.template.querySelector('c-custom-types').saveDraftValues;
                const editedValuesEvent = new CustomEvent('valueschange', {
                   detail: producto[0]
                });
                this.dispatchEvent(editedValuesEvent);
                this.showButton = true;
                
        }else {
                this.template.querySelector('c-custom-types').draftValues = [];
                this.showButton = false;
                
        }        
        // Se re-renderiza la tabla para mostrar las cantidades sin el edit realizado
        this.columns = [...cols];
    }

    handleShowButtonFromPicklist(event){
        console.log("onPicklist change");
        this.showButton = event.detail.showButton
    }

    handleSave(event){
        console.log('Save Action');
        this.save = true;
        this.showButton = false;
        
        let products = this.template.querySelector('c-custom-types').data;
        console.log('products', JSON.stringify(products));
        let id = this.id.split('-');
        console.log(`record Id ${id[0]}`);
        saveProducts({listProducts: JSON.stringify(products),
                        recordId: id[0]
            })
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
                this.save = false;
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