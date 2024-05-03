import { LightningElement, wire, track } from 'lwc';
import getDescubriRecetasOncologia from'@salesforce/apex/ArticulosPortalPacientesController.getDescubriRecetasOncologia';
import { NavigationMixin } from 'lightning/navigation';

export default class ContainerDescubriRecetasOncologia extends NavigationMixin(LightningElement) {

    @track recetas;
    recetaMobile = {
        Tipo_de_receta__c: '',
        Title: '',
    };
    recetasMobile = [];

    @wire (getDescubriRecetasOncologia)
    wiredRecetas ({error, data}) {
        if(data){
            this.recetas = data;
            this.recetaMobile = this.recetas[0];
            this.recetasMobile.push(this.recetas[0]);
            this.recetasMobile.push(this.recetas[1]);
        } else if(error){
            console.log(error);
        }
    };

    redireccionarRecetas(){
        console.log("asdas");
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Recetas__c'
            }
        });
    }
}