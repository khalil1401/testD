import { LightningElement, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getPedidos from'@salesforce/apex/ArticulosPortalPacientesController.getPedidos';

export default class PedidosManagerNSJ extends LightningElement {
    userId = Id;
    @track envios;

    @wire(getPedidos, {userId: '$userId'})
    wiredPedidos ({error, data}) {
        if(data){
            let res = data.map(el => {
                const path = {
                    date : new Date(el.CreatedDate).toLocaleDateString('en-GB'),
                    calle : el.Direccion_de_Envio__c.toLowerCase(),
                    localidad : el.Localidad_de_Envio__c.toLowerCase()
                };
                const envio = Object.assign(path, el);
                return envio;
            });
            this.envios = res.length > 0 ? res : null;
        } else if(error){
            console.log(error);
        }
    };

}