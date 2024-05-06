import { api, LightningElement } from 'lwc';

export default class UnitMeasurePicklist extends LightningElement {
    @api value;
    @api options;
    @api contex;
    @api placeholder;

    handlePicklist(event){
        
        console.log('value '+event.target.value);
        
        console.log('contex  '+this.contex);
        
        let producto = {
            unidadMedida: event.target.value,
            productCode: this.contex
        };
        console.log('estoy en handlePicklistChange valores: '+ JSON.stringify(producto));
                
                
         if(producto){
             console.log('estoy en if  '+ JSON.stringify(producto));             
                
                 const editedValuesEvent = new CustomEvent('valueschange', {
                    composed: true,
                    bubbles: true,
                    cancelable: true,
                    detail: producto
                 });
                 this.dispatchEvent(editedValuesEvent);

                 const showButtonEvent = new CustomEvent('showbutton', {
                    composed: true,
                    bubbles: true,
                    cancelable: true,
                    detail: {showButton: true}
                 });
                 this.dispatchEvent(showButtonEvent);
                                 
         } 
         
    }
}