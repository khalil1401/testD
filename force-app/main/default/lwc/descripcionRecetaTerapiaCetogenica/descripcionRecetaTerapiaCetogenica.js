import { LightningElement, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class DescripcionRecetaTerapiaCetogenica extends LightningElement {

    @api imagenReceta;
    @api nombreReceta;
    @api ingredientesReceta;
    @api preparacionReceta;
    @api recetaUrlVideo;
    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    renderedCallback(){
        let divImg = this.template.querySelector('[data-id="imagen-receta"]');
        if(divImg){
            divImg.style.backgroundImage = 'url('+this.imagenReceta+')';
        }
    }

    volverARecetas(){
        this.dispatchEvent(new CustomEvent("volver",));
    }

}