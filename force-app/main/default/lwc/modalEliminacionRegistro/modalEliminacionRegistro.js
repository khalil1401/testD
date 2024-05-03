import { LightningElement, api } from 'lwc';
import deleteDireccion from '@salesforce/apex/PerfilUsuarioNSJController.deleteDireccion';
import deleteContact from '@salesforce/apex/PerfilUsuarioNSJController.deleteContact';

export default class ModalEliminacionRegistro extends LightningElement {

    @api
    recordId;
    @api
    pacienteId;
    @api
    object;
    showSpinner;

    @api
    get modalContact() {
        if(this.object == 'Contact') {
            return true;
        }
        else return false;
    }

    closeModal() {
        const customevent = new CustomEvent('closemodal');
        this.dispatchEvent(customevent);
    }

    confirmar() {
        if(this.object == 'Contact') {
            this.showSpinner = true;
            deleteContact({ 
                recordId : this.recordId,
                pacienteId : this.pacienteId
            })
            .then(result => {
                this.closeModal();
            })
            .catch(error => {
                console.log(error);
                this.closeModal();
            });
        }
        else if(this.object == 'Direccion') {
            this.showSpinner = true;
            deleteDireccion({ 
                recordId : this.recordId
            })
            .then(result => {
                this.closeModal();
            })
            .catch(error => {
                console.log(error);
                this.closeModal();
            });
        }
    }
}