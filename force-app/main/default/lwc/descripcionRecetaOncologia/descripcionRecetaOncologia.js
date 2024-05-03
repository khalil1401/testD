import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getRecetaOncologia from'@salesforce/apex/ArticulosPortalPacientesController.getRecetaOncologia';
import { NavigationMixin } from 'lightning/navigation';

export default class DescripcionRecetaOncologia extends NavigationMixin(LightningElement) {

    currentPageReference = null;
    urlStateParameters = null;

    @track urlTituloReceta = '';
    @api receta = null;
    titulo = '';
    ingredientes = '';
    preparacion = '';
    tipoDeReceta = '';
    consejos = '';
    cantidad = '';
    tiempoPreparacion = '';
    recetaImg;

    @wire (getRecetaOncologia, {tituloReceta: '$urlTituloReceta'})
    wiredReceta ({error, data}) {
        if(data){
            this.receta = data;
            this.titulo = this.receta.Title;
            this.recetaImg = this.receta.Imagen__c;
            this.ingredientes = this.receta.Ingredientes_de_recetas__c;
            this.preparacion = this.receta.Preparacion_receta__c;
            this.tipoDeReceta = this.receta.Tipo_de_receta__c;
            this.consejos = this.receta.Consejos_recetas__c;
            this.cantidad = this.receta.Cantidad_porciones_receta__c;
            this.tiempoPreparacion = this.receta.Tiempo_preparacion_receta__c;
        } else if(error){
            console.log(error);
        }
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.urlTituloReceta = this.urlStateParameters.tituloReceta || null;
       }
    };

    redireccionarRecetas(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Recetas__c'
            }
        });
    }
}