import { LightningElement, wire, track, api } from 'lwc';
import getRecetaAlergia from'@salesforce/apex/ArticulosPortalPacientesController.getRecetaAlergia';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class DescripcionRecetaAlergia extends NavigationMixin(LightningElement) {

    urlStateParameters = null;
    @track urlTituloReceta = '';
    @api receta;
    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.urlTituloReceta = this.urlStateParameters.receta || null;
       }
    };

    volverARecetas(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Recetario_Alergia__c'
            },
        });
    }

    @wire (getRecetaAlergia, {tituloReceta: '$urlTituloReceta'})
    wiredReceta ({error, data}) {
        if(data){
            this.receta = data;
        } else if(error){
            console.log(error);
        }
    };

}