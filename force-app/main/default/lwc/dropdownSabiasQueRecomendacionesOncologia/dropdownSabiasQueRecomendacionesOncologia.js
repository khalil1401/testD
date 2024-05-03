import { LightningElement, api } from 'lwc';

export default class DropdownSabiasQueRecomendacionesOncologia extends LightningElement {

    @api tituloDropdownSQR;
    @api textoPrincipalDropdownSQR;
    verDetalles = false;
    
    dropdown(){
        this.verDetalles = !this.verDetalles;
    }
}