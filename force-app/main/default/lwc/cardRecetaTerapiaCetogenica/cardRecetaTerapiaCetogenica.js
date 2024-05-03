import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CardReceta extends NavigationMixin(LightningElement) {

    @api indiceReceta;
    @api tituloReceta;
    @api imagenReceta;

    renderedCallback(){
        let div = this.template.querySelector('[data-id="imagen-receta"]');
        div.style.backgroundImage = 'url('+this.imagenReceta+')';
    }

    selectReceta(){
        this.dispatchEvent(new CustomEvent("selected", {
            detail: this.indiceReceta
        }));
    }

}