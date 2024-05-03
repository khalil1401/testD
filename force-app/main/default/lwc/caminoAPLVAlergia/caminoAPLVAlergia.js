import { LightningElement } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';

export default class CaminoAPLVAlergia extends NavigationMixin(LightningElement) {

    listaContainers = ['primerPasoContainer', 'segundoPasoContainer', 'tercerPasoContainer', 'cuartoPasoContainer'];
    indicePaso = 0;
    iconoAnterior = true;
    iconoPosterior = this.listaContainers.length < 1 ;
    get isDesktop() {
        return FORM_FACTOR === 'Large';
    }
    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    seleccionarPaso(event){
        let paso = event.currentTarget.dataset.id + 'Container';
        this.listaContainers.forEach( ele => {
            this.template.querySelector('[data-id=' + ele + ']').className='hidden-container';
        });
        this.template.querySelector('[data-id=' + paso + ']').className='show-container';
        this.indicePaso = this.listaContainers.indexOf(paso);
        this.iconoPosterior = this.indicePaso + 1 >= this.listaContainers.length;
        this.iconoAnterior = this.indicePaso <= 0;
        this.template.querySelector('[data-id="descripcion"]').scrollIntoView({
            behavior: 'smooth',
            block: 'start',
            inline: 'start'
        });
    }

    pasoSiguiente(){
        if(this.indicePaso + 1 < this.listaContainers.length){
            this.indicePaso++;
            this.seleccionarPasoIndice();
            this.iconoPosterior = this.indicePaso + 1 >= this.listaContainers.length;
            this.iconoAnterior = this.indicePaso <= 0;
        }
    }

    pasoAnterior(){
        if(this.indicePaso - 1 >= 0){
            this.indicePaso--;
            this.seleccionarPasoIndice();
            this.iconoPosterior = this.indicePaso + 1 >= this.listaContainers.length;
            this.iconoAnterior = this.indicePaso <= 0;
        }
    }

    seleccionarPasoIndice(){
        this.template.querySelector('[data-id="descripcion"]').scrollIntoView({
            behavior: 'smooth',
            block: 'start',
            inline: 'start'
        });
        this.listaContainers.forEach( ele => {
            this.template.querySelector('[data-id=' + ele + ']').className='hidden-container';
        });
        this.template.querySelector('[data-id=' + this.listaContainers[this.indicePaso] + ']').className='show-container';
    }
    
    redireccionarLey(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://www.argentina.gob.ar/normativa/nacional/ley-27305-267397'
            }
        });
    }

    redireccionar(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'cuidados_y_recomendaciones_alergia__c'
            }
        });
    }

}