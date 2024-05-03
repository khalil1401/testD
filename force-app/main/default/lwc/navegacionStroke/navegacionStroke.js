import { api, LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import logoSR from '@salesforce/resourceUrl/LogoNutriciaBagoBlanco';
import { CurrentPageReference } from 'lightning/navigation';

export default class NavegacionStroke extends NavigationMixin(LightningElement) {

    @api navFooter = false;
    @api malnutricion = false;
    @api menuStyle;
    logo = logoSR;
    dropdown = false;
    items = [
        {'dataId':'Stroke__c', 'label':'Inicio', 'classFooter':'vl'},
        {'dataId':'custom_que_es_la_disfagia__c', 'label':'¿Qué es la Disfagia?', 'classFooter':'vl'},
        {'dataId':'Tratamientos_Disfagia__c', 'label':'Tratamientos', 'classFooter':'vl'},
        {'dataId':'Recetas_Disfagia__c', 'label':'Recetas y Tips', 'classFooter':'vl'},
        {'dataId':'custom_dimension_psicologica_de_la_disfa__c', 'label':'Dimensión Psicológica de la Disfagia', 'classFooter':''}
    ];
    itemsMalnutricion = [
        {'dataId':'malnutricion_home__c', 'label':'Inicio', 'classFooter':'vl'},
        {'dataId':'malnutricion_adulto_mayor__c', 'label':'Malnutrición', 'classFooter':'vl'},
        {'dataId':'trastornos_deglutorios_malnutricion__c', 'label':'Trastornos Deglutorios', 'classFooter':'vl'},
        {'dataId':'sarcopenia_fragilidad__c', 'label':'Sarcopenia y Fragilidad', 'classFooter':'vl'},
        {'dataId':'falta_apetito__c', 'label':'Falta de Apetito', 'classFooter':'vl'},
        {'dataId':'vida_saludable__c', 'label':'Vida Saludable', 'classFooter':'vl'},
        {'dataId':'recomendaciones_nutricionales__c', 'label':'Recomendaciones Nutricionales', 'classFooter':''},
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
        let div = this.template.querySelector('[data-id='+ this.currentDataId +']');
        if(div){
            if(!this.navFooter && !this.menuStyle){
                div.className = 'text-selected-item-nav-int-nsj slds-align_absolute-center';
            }
        }

        if(this.malnutricion){
            this.items = this.itemsMalnutricion;
            var divblockDesktop = this.template.querySelector('[data-id="containerNav"]');
            if(divblockDesktop){
                this.template.querySelector('[data-id="containerNav"]').className='slds-grid slds-wrap slds-grid_vertical-align-center container-nav-malnutricion';
            }
            var divblockMobile = this.template.querySelector('[data-id="containerNavMobile"]');
            if(divblockMobile){
                this.template.querySelector('[data-id="containerNavMobile"]').className='slds-grid slds-wrap slds-grid_vertical-align-center container-nav-malnutricion';
            }
        }
    }

    redireccionar(event){
        let apiName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: apiName
            }
        });
    }

    actionDropdown(){
        this.dropdown = !this.dropdown;
        var divblock = this.template.querySelector('[data-id="containerNavDropdown"]');
        if(this.dropdown){
            if(divblock){
                if(this.malnutricion){
                    this.template.querySelector('[data-id="containerNavDropdown"]').className='display-initial container-nav-malnutricion';
                }
                else{
                    this.template.querySelector('[data-id="containerNavDropdown"]').className='display-initial containerNavStroke';
                }   
            }
        }
        else{
            if(divblock){
                this.template.querySelector('[data-id="containerNavDropdown"]').className='display-none';
            }
        }
    }
}