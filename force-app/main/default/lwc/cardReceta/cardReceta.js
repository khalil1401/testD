import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CardReceta extends NavigationMixin(LightningElement) {

    @api tipoReceta;
    @api tituloReceta;
    @api imagenReceta;
    @api descubriReceta;

    renderedCallback(){
        if (this.descubriReceta) {
            var divblock1 = this.template.querySelector('[data-id="cardReceta"]');
            if(divblock1){
                this.template.querySelector('[data-id="cardReceta"]').className='slds-card backgroundGray';
            }
            var divblock2 = this.template.querySelector('[data-id="idContainerImgReceta"]');
            if(divblock2){
                this.template.querySelector('[data-id="idContainerImgReceta"]').className='containerImgReceta backgroundGray';
            }
        }
    }

    navigateToDescripcionReceta() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'custom_receta__c'
            },
            state: {
                tituloReceta : this.tituloReceta
            }
        });
    }

}