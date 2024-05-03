import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CardRecetaAlergia extends NavigationMixin(LightningElement) {

    @api idReceta;
    @api tituloReceta;
    @api imagenReceta;

    selectReceta(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'descripcion_receta_alergia__c'
            },
            state: {
                receta : this.tituloReceta
            }
        });
    }

}