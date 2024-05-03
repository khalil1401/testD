import { LightningElement, wire, track } from 'lwc';
import getRecetasAlergia from'@salesforce/apex/ArticulosPortalPacientesController.getRecetasDeTipoAlergia';
import getTiposDeRecetaOncologia from'@salesforce/apex/ArticulosPortalPacientesController.getTiposDeRecetaAlergia';
import { NavigationMixin } from 'lightning/navigation';

export default class ContainerRecetasAlergia extends NavigationMixin(LightningElement) {

    flagContainerRecetas = true;
    flagContainerDescripcionReceta = false;
    @track tiposDeRecetas;
    @track recetas;
    @track error;
    @track tipoSeleccionado = '';
    @track verMas = false;
    recetasComprimidas = [];
    recetaSeleccionada;

    @wire (getTiposDeRecetaOncologia)
    wiredtiposDeRecetas ({error, data}) {
        if(data){
            this.tiposDeRecetas = data;
        } else if(error){
            this.error = error;
        }
    };

    @wire (getRecetasAlergia, {tipoReceta: '$tipoSeleccionado'})
    wiredRecetas ({error, data}) {
        if(data){
            var res = data;
            this.verMas = false;
            this.recetas = res;
            this.setRecetasComprimidas();
        } else if(error){
            console.log(error);
            this.error = error;
        }
    };

    seleccionarTipo(event){
        this.tipoSeleccionado = event.target.dataset.id;
    }

    setRecetasComprimidas(){
        this.recetasComprimidas = [];
        let cantidadDeRecetas = this.recetas.length;
        if(cantidadDeRecetas < 9){
            this.verMas = true;
        }
        else{
            this.recetasComprimidas = this.recetas.slice(0, 9);
        }
    }

    handleclick(){
        this.verMas = true;
    }

}