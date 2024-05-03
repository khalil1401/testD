import { LightningElement, wire, track } from 'lwc';
import getRecetasDisfagia from'@salesforce/apex/ArticulosPortalPacientesController.getRecetasDisfagia';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class ContainerRecetasStroke extends LightningElement {

    tipoReceta;
    receta;
    @track recetas;
    recetasAMostrar;    

    get isDesktop() {
        return FORM_FACTOR === 'Large';
    }

    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    @wire (getRecetasDisfagia)
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
        } else if(error){
            console.log(error);
            this.error = error;
        }
    };

    seleccionarTipoReceta(event){
        let tipoReceta = event.currentTarget.dataset.id;
        this.tipoReceta = tipoReceta;
        //cambiar estilo de boton mas
        let botonMas = 'botonMas' + tipoReceta;
        var divblock = this.template.querySelector('[data-id='+ botonMas +']');
        if(divblock){
            this.template.querySelector('[data-id="botonMasDesayuno"]').className='botonMas';
            this.template.querySelector('[data-id="botonMasAlmuerzo"]').className='botonMas';
            this.template.querySelector('[data-id="botonMasMerienda"]').className='botonMas';
            this.template.querySelector('[data-id="botonMasCena"]').className='botonMas';
            this.template.querySelector('[data-id='+ botonMas +']').className='botonMasSeleccionado';
        }
        //
        this.template.querySelector('[data-id="conatinerDetalles"]').className='conatinerDetallesShow';
        this.template.querySelector('[data-id="conatinerCards"]').className='conatinerDetallesHidden';
        //event
        let value = {
            tipoReceta: this.tipoReceta
        };
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
        });
        this.dispatchEvent(valueChangeEvent);

        this.buscarVideos();
    }
    
    seleccionarReceta(event){
        let receta = event.currentTarget.dataset.id;
        this.receta = receta;
    }

    buscarVideos(){
        let recetas = [];
        for(let i = 0; i<this.recetas.length; i++){
            if(this.recetas[i].Tipo_de_receta__c == this.tipoReceta){
                recetas.push(this.recetas[i]);
            }
        }
        this.recetasAMostrar = recetas;
    }

    hideModal(){
        this.receta = '';
    }

}