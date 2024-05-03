import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class NavegacionMetabolicos extends NavigationMixin(LightningElement) {

    itemsMetabolicos = [
        {'dataId':'metabolicos__c', 'label':'Inicio', 'class':'text-item-nav-meta'},
        {'dataId':'errores_congenitos_del_metabolismo__c', 'label':'Errores Congénitos del Metabolismo', 'class':'text-item-nav-meta'},
        {'dataId':'articulos_de_interes__c', 'label':'Artículos de interés', 'class':'text-item-nav-meta'},
        {'dataId':'nutricion_y_ecm__c', 'label':'Nutrición y ECM', 'class':'text-item-nav-meta'}
    ];
    currentPageReference = null;
    currentDataId;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            let apiNameCurrentPage = currentPageReference.attributes.name;
            this.currentDataId = apiNameCurrentPage;
       }
    }

    renderedCallback(){
        let div = this.template.querySelector('[data-id='+ this.currentDataId +']')
        if(div){
            div.className = 'text-selected-item-nav-meta';
        }
    }

    redirect(event){
        let apiName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: apiName
            }
        });
    }

    redirectRS(event){
        let apiName = event.target.dataset.id;
        console.log(apiName);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: apiName
            }
        });
    }

}