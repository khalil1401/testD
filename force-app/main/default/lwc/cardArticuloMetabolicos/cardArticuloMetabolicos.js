import { LightningElement, api } from 'lwc';

export default class CardArticuloMetabolicos extends LightningElement {

    @api articuloId;
    @api title;
    @api text;
    @api img;

    renderedCallback(){
        let divImg = this.template.querySelector('[data-id="img-card-articulo-metabolicos"]');
        if(divImg){
            divImg.style.backgroundImage = 'url('+this.img+')';
        }
    }

    handleClickArticulo(){
        const clickEvent = new CustomEvent("clickarticulo",{
            detail: this.articuloId
        });
        this.dispatchEvent(clickEvent);
    }

}