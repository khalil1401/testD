import { LightningElement, wire, track } from 'lwc';
import getVideosCetogenica from'@salesforce/apex/ArticulosPortalPacientesController.getVideosTerapiaCetogenica';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class VideosTerapiaCetogenica extends LightningElement {

    linkVideo = 'https://www.youtube.com/embed/Blf4oq3fZZo?controls=1';
    cantidadVideosAMostrar = 3;
    title = 'Conocé la historia de Balti y la Terapia Cetogénica';
    videosAMostrar = [];
    indice = 0;
    iconoAnterior = true;
    iconoPosterior;
    @track recetas;
    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    @wire (getVideosCetogenica)
    wiredRecetas ({error, data}) {
        if(data){
            var res = data.map(el => {
                const path = {
                    url : el.URL_Video__c + '?controls=0&showinfo=0&autohide=1',
                    dataId: el.URL_Video__c + '?controls=1'
                };
                const receta = Object.assign(path, el);
                return receta;
            });
            this.recetas = res;
            this.completarVideosAMostrar();
        } else if(error){
            console.log(error);
            this.error = error;
        }
    };

    completarVideosAMostrar(){
        this.videosAMostrar = this.recetas.slice(0,this.cantidadVideosAMostrar);
        this.iconoPosterior = this.indice + 1 >= this.recetas.length;
    }

    videoSiguiente(){
        if(this.indice + this.cantidadVideosAMostrar < this.recetas.length){
            this.indice = this.indice + 1;
            this.videosAMostrar = this.recetas.slice(this.indice, this.indice + this.cantidadVideosAMostrar);
            this.iconoPosterior = this.indice + this.cantidadVideosAMostrar >= this.recetas.length;
            this.iconoAnterior = this.indice <= 0;
        }
    }

    videoAnterior(){
        if(this.indice - 1 >= 0){
            this.indice = this.indice - 1;
            this.videosAMostrar = this.recetas.slice(this.indice ,this.indice + this.cantidadVideosAMostrar);
            this.iconoPosterior = this.indice + this.cantidadVideosAMostrar >= this.recetas.length;
            this.iconoAnterior = this.indice <= 0;
        }
    }

    handleClick(event){
        let link = event.target.dataset.id;
        this.linkVideo = link;
    }
    
}