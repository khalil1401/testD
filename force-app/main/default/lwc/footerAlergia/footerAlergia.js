import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import iconosRS from '@salesforce/resourceUrl/SocialMediaIcons';
import logonbRS from '@salesforce/resourceUrl/logoNutricaBagoGris';
import FORM_FACTOR from '@salesforce/client/formFactor';
import wspRS from '@salesforce/resourceUrl/wspIcon';

export default class FooterAlergia extends NavigationMixin(LightningElement) {

    rutaFacebok = 'www.facebook.com';
    rutaInstagram = 'https://www.instagram.com/nutriciacomunidad/';
    iconoFb = iconosRS + '/Icono_FB_violeta.svg';
    iconoIg = iconosRS + '/Icono_IG_violeta.svg';
    logonb = logonbRS;
    wsp = wspRS;
    @api contenidoPrivado;
    get isDesktop(){
        return FORM_FACTOR === 'Large';
    }
    get isMobile(){
        return FORM_FACTOR === 'Small';
    }

    navigateToDescripcionReceta(event) {
        let apiName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: apiName
            }
        });
    }

    navigateToRedSocial(event) {
        let apiName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: apiName
            }
        });
    }

}