import { api, LightningElement } from 'lwc';

export default class HeaderMalnutricion extends LightningElement {

    @api imgHeader;
    @api imgPrincipal;
    @api volanta;
    @api titulo;
    @api textoBajada;

    renderedCallback(){
        let div = this.template.querySelector('[data-id="img-header-malnutricion"]');
        div.style.backgroundImage = 'url('+this.imgHeader+')';
        let divMobile = this.template.querySelector('[data-id="img-header-malnutricion-mobile"]');
        divMobile.style.backgroundImage = 'url('+this.imgHeader+')';
    }

}