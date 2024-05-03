import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import logonbRS from '@salesforce/resourceUrl/logoNutricaBagoGris';

export default class FooterDesafiosCrecimiento extends NavigationMixin(LightningElement) {
    logonb = logonbRS;

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
        //set style footer
        let div = this.template.querySelector('[data-iddesktop="telefono"]');
        if(div) {
            if(this.areaTerapeutica == 'Desafíos del crecimiento') {
                div.className = 'contact-text-footer-ddc';
            }
            else if(this.areaTerapeutica == 'Digestivos') {
                div.className = 'contact-text-footer-dig';
            }
        }

        let divMobile = this.template.querySelector('[data-idmobile="telefono"]');
        if(divMobile) {
            if(this.areaTerapeutica == 'Desafíos del crecimiento') {
                divMobile.className = 'contact-text-footer-ddc';
            }
            else if(this.areaTerapeutica == 'Digestivos') {
                divMobile.className = 'contact-text-footer-dig';
            }
        }
    }

    redirect(event) {
        let mode = event.target.dataset.redirect;
        let apiName = event.target.dataset.id;

        if(mode == 'internal') {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: apiName
                }
            });
        }
        else if(mode == 'external') {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: apiName
                }
            });    
        }
    }
}