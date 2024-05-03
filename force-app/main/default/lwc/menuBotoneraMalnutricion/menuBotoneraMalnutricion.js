import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class MenuBotoneraMalnutricion extends NavigationMixin(LightningElement) {

    @api malnutriconMayores;

    redireccionar(event){
        let apiName = event.target.dataset.id;
        if(apiName == 'recomendaciones_nutricionales__c'){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: apiName
                },
                state: {
                    seccion : "suplementos"
                }
            });
        }
        else{
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: apiName
                },
                state: {
                    seccion : "suplementos"
                }
            });    
        }
    }

}