import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class NavegacionDesafiosCrecimiento extends NavigationMixin(LightningElement) {

    @api
    hamburgerMenu;
    @api
    areaTerapeutica;
    items = [];
    itemsRS = [];
    itemsDesafiosDelCrecimiento = [
        {'dataId':'desafios_del_crecimiento__c', 'label':'Inicio'},
        {'dataId':'registro_y_solicitud__c', 'label':'Solicitud de Kit de Inicio'},
        {'dataId':'patologias_cronicas__c', 'label':'Patologías crónicas'},
        {'dataId':'patologias_agudas_traumatismos__c', 'label':'Patologías agudas o traumatismos'},
        {'dataId':'tratamiento_nutricional__c', 'label':'Tratamiento nutricional'},
        {'dataId':'bomba_nutricion_enteral__c', 'label':'Bomba de nutrición enteral'},
    ];
    itemsDigestivos = [
        {'dataId':'digestivos__c', 'label':'Inicio'},
        {'dataId':'registro_y_solicitud__c', 'label':'Solicitud de Kit de Inicio'},
        {'dataId':'diagnostico__c', 'label':'Diagnóstico'},
        {'dataId':'tratamiento_nutricional_digestivos__c', 'label':'Tratamiento nutricional'},
        {'dataId':'microbiota_intestinal__c', 'label':'Microbiota intestinal'},
    ];
    itemsDesafiosDelCrecimientoRS = [
        {'id':'ig-ddc', 'dataId':'https://www.instagram.com/nutriciacomunidad/', 'img':'https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_DESAFIOS_CRECIMIENTO/1_HOME/PP-DesafiosDelCrecimiento-Icono-Instagram-2x.png',
            'imgMobile': 'https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCION_DESAFIOS_CRECIMIENTO/6_RESTANTES/PP_DesafiosDelCrecimiento_Icono-Instagram-Blanco.png', 'class':'icon-rs-ddc'},
    ];
    itemsDigestivosRS = [
        {'id':'ig-ddc', 'dataId':'https://www.instagram.com/nutriciacomunidad/', 'img':'https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCI%C3%93N_DIGESTIVOS/2_INICIO/PP-Digestivos-Icono-Instagram%402x.png',
            'imgMobile': 'https://sndigitalassets.s3.sa-east-1.amazonaws.com/PORTAL-PACIENTES/SECCI%C3%93N_DIGESTIVOS/2_INICIO/PP-Digestivos-Icono-Instagram%402x.png', 'class':'icon-rs-ddc'},
    ];
    currentPageReference = null;
    apiNameCurrentPage;
    dropdown;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.apiNameCurrentPage = currentPageReference.attributes.name;
        }
    }

    connectedCallback() {
        if(this.areaTerapeutica == 'Desafíos del crecimiento') {
            this.items = this.itemsDesafiosDelCrecimiento;
            this.itemsRS = this.itemsDesafiosDelCrecimientoRS;
        }
        else if(this.areaTerapeutica == 'Digestivos') {
            this.items = this.itemsDigestivos;
            this.itemsRS = this.itemsDigestivosRS;
        }
    }

    renderedCallback() {
        //set style item nav
        let div = this.template.querySelector('[data-id='+ this.apiNameCurrentPage +']');
        if(div) {
            if(this.hamburgerMenu) {
                div.className = 'hamburger-selected-item-ddc';
            }
            else {
                if(this.areaTerapeutica == 'Desafíos del crecimiento') {
                    div.className = 'span-selected-items-ddc';
                }
                else if(this.areaTerapeutica == 'Digestivos') {
                    div.className = 'span-selected-items-dig';
                }
            }
        }

        //set style hamburguer menu
        let divHamburguer = this.template.querySelector('[data-id="hamburger-nav"]');
        if(divHamburguer) {
            if(this.areaTerapeutica == 'Desafíos del crecimiento') {
                divHamburguer.style.background = '#522582';
            }
            else if(this.areaTerapeutica == 'Digestivos') {
                divHamburguer.style.background = 'transparent linear-gradient(180deg, #6552AC 0%, #7970CEF0 43%, #777BCF 81%, #7583D0 100%)';
            }
        }
    }

    redirect(event){
        let apiName = event.target.dataset.id;

        if(apiName == 'registro_y_solicitud__c') {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: apiName
                },
                state: {
                    area: this.areaTerapeutica
                }
            });
        }
        else{
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: apiName
                }
            });
        }
    }

    redirectRS(event) {
        let urlrs = event.target.dataset.url;
        console.log(urlrs);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: urlrs
            }
        });
    }

    openDropdown() {
        this.dropdown = !this.dropdown;
    }
}