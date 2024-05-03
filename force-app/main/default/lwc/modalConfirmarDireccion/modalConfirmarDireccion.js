import { LightningElement, api } from 'lwc';
import upsertDireccion from '@salesforce/apex/PerfilUsuarioNSJController.upsertDireccion';

export default class ModalConfirmarDireccion extends LightningElement {

    @api
    direccion;
    showSpinner;

    showMsgEdit;

    connectedCallback() {
        if(this.direccion.id){
            this.showMsgEdit = true;
        }
    }

    confirmar() {
        this.showSpinner = true;
        upsertDireccion({ 
            id : this.direccion.id,
            principal : this.direccion.principal,
            direccion : this.direccion.direccion,
            cp : this.direccion.cp,
            localidad : this.direccion.localidad,
            ref : this.direccion.ref,
            pacienteId : this.direccion.pacienteId
        })
        .then(result => {
            this.closeModal();
        })
        .catch(error => {
            console.log(error);
            this.closeModal();
        });
    }

    closeModal() {
        const customevent = new CustomEvent('closemodalconf');
        this.dispatchEvent(customevent);
    }
}