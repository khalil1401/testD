import { LightningElement, wire, track } from 'lwc';
import getRecetasOncologia from'@salesforce/apex/ArticulosPortalPacientesController.getRecetasOncologia';
import getTiposDeRecetaOncologia from'@salesforce/apex/ArticulosPortalPacientesController.getTiposDeRecetaOncologia';

export default class ContainerRecetasOncologia extends LightningElement {

    @track tiposDeRecetas;
    @track recetas;
    @track error;
    @track tipoSeleccionado ='';
    verMas = false;
    recetasComprimidas = [];

    @wire (getTiposDeRecetaOncologia)
    wiredtiposDeRecetas ({error, data}) {
        if(data){
            this.tiposDeRecetas = data;
        } else if(error){
            this.error = error;
        }
    };

    @wire (getRecetasOncologia, {tipoDeReceta: '$tipoSeleccionado'})
    wiredRecetas ({error, data}) {
        if(data){
            this.verMas = false;
            this.recetas = data;
            this.setRecetasComprimidas();
        } else if(error){
            console.log(error);
            this.error = error;
        }
    };

    seleccionarTipo(event){
        this.tipoSeleccionado = event.target.dataset.id;
        console.log(this.tipoSeleccionado);
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

}