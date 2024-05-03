import { LightningElement, wire, track } from 'lwc';
import getTiposRecetasTerapiaCetogenica from'@salesforce/apex/ArticulosPortalPacientesController.getTiposRecetasTerapiaCetogenica';
import getRecetasTerapiaCetogenica from'@salesforce/apex/ArticulosPortalPacientesController.getRecetasTerapiaCetogenica';
import imagenesRecetasSR from '@salesforce/resourceUrl/recetasImagenes';

export default class ContainerRecetasTerapiaCetogenica extends LightningElement {

    flagContainerRecetas = true;
    flagContainerDescripcionReceta = false;

    @track tiposDeRecetas;
    @track recetas;
    @track error;
    @track tipoSeleccionado ='';
    imagenesRecetas = imagenesRecetasSR + '/';
    verMas = false;
    recetasComprimidas = [];
    mapRecetas = new Map();
    indiceRecetaSeleccionada;
    recetaSeleccionada;
    booleanRecetaAnterior;
    booleanRecetaPosterior;

    @wire (getTiposRecetasTerapiaCetogenica)
    wiredtiposDeRecetas ({error, data}) {
        if(data){
            this.tiposDeRecetas = data;
        } else if(error){
            this.error = error;
        }
    };

    @wire (getRecetasTerapiaCetogenica, {tipoReceta: '$tipoSeleccionado'})
    wiredRecetas ({error, data}) {
        if(data){
            var res = data.map((el, index) => {
                const path = {
                    indice: index
                };
                const articulo = Object.assign(path, el);
                return articulo;
            });
            this.verMas = false;
            this.recetas = res;
            console.log(this.recetas);
            this.indiceRecetaSeleccionada = -1;
            this.recetaSeleccionada = null;
            this.actualizarDisabledAnteriorSiguiente();
            this.setRecetasComprimidas();
            this.setMapaRecetas();
        } else if(error){
            console.log(error);
            this.error = error;
        }
    };

    seleccionarTipo(event){
        this.tipoSeleccionado = event.target.dataset.id;
        this.template.querySelector('[data-id=""]').className='buttonTipoReceta';
        for(let tipoReceta of this.tiposDeRecetas){
            this.template.querySelector('[data-id="'+ tipoReceta +'"]').className='buttonTipoReceta';
        }
        let div = this.template.querySelector('[data-id="'+ this.tipoSeleccionado +'"]');
        if(div){
            div.className='buttonTipoRecetaSeleccionado';
        }
    }

    setRecetasComprimidas(){
        this.recetasComprimidas = [];
        let cantidadDeRecetas = this.recetas.length;
        if(cantidadDeRecetas < 6){
            this.verMas = true;
        }
        else{
            this.recetasComprimidas = this.recetas.slice(0, 6);
        }
    }

    handleclick(){
        this.verMas = true;
    }

    setMapaRecetas(){
        for(let i = 0; i < this.recetas.length; i++){
            this.mapRecetas.set(this.recetas[i].indice, this.recetas[i]);
        }
    }

    verDetalles(event){
        document.body.style.overflowY  = "hidden";
        
        let indiceReceta = event.detail;
        this.indiceRecetaSeleccionada = indiceReceta;
        this.recetaSeleccionada = this.mapRecetas.get(indiceReceta);
        this.actualizarDisabledAnteriorSiguiente();
        this.flagContainerDescripcionReceta = true;
    }

    verRecetas(){
        this.indiceRecetaSeleccionada = -1;
        this.recetaSeleccionada = null;
        this.actualizarDisabledAnteriorSiguiente();
        this.flagContainerRecetas = true;
        this.flagContainerDescripcionReceta = false;
    }

    verRecetaAnterior(){
        this.indiceRecetaSeleccionada --;
        this.recetaSeleccionada = this.mapRecetas.get(this.indiceRecetaSeleccionada);
        this.actualizarDisabledAnteriorSiguiente();
    }

    verRecetaPosterior(){
        this.indiceRecetaSeleccionada ++;
        this.recetaSeleccionada = this.mapRecetas.get(this.indiceRecetaSeleccionada);
        this.actualizarDisabledAnteriorSiguiente();
    }

    actualizarDisabledAnteriorSiguiente(){
        this.booleanRecetaAnterior = this.indiceRecetaSeleccionada -1 < 0;
        this.booleanRecetaPosterior = this.indiceRecetaSeleccionada + 1 >= this.recetas.length;
    }

    closeModal(){
        document.body.style.overflowY  = "scroll";
        this.flagContainerDescripcionReceta = false;
    }
}