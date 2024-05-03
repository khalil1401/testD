import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import iconsRS from '@salesforce/resourceUrl/SocialMediaIcons';
import logonbRS from '@salesforce/resourceUrl/logoNutricaBagoGris';
import wspRS from '@salesforce/resourceUrl/wspIcon';

export default class FooterMetabolicos extends NavigationMixin(LightningElement) {

    items = [
        {'dataId':'errores_congenitos_del_metabolismo__c', 'label':'Errores Congénitos del Metabolismo', 'class':'text-footer-meta'},
        {'dataId':'articulos_de_interes__c', 'label':'Artículos de interés', 'class':'text-footer-meta'},
        {'dataId':'nutricion_y_ecm__c', 'label':'Nutrición y ECM', 'class':'text-footer-meta'}
    ];
    igIcon = iconsRS + '/Icono_IG_violeta.svg';
    logonb = logonbRS;
    wsp = wspRS;

    redirect(event) {
        let apiName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: apiName
            }
        });
    }

    redirectRS(event) {
        let apiName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: apiName
            }
        });
    }

}