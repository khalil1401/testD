import { LightningElement, api } from 'lwc';
import saveJSONAccount from '@salesforce/apex/PerfilUsuarioNSJController.saveAccount';

export default class ModalConfirmarCorreo extends LightningElement {

    @api
    recordId
    @api
    fieldApiName;
    @api
    newValue;

    showSpinner;

    confirmar() {
        this.showSpinner = true;
        let newRecord = {
            Id : this.recordId
        };
        if(this.newValue) {
            newRecord[this.fieldApiName] = this.newValue;
        }
        let jsonObject = JSON.stringify(newRecord);
        saveJSONAccount({ 
            jsonAccount : jsonObject
        })
        .then(result => {
            this.closeModal();
        })
        .catch(error => {
            console.log("error");
            this.closeModal();
        });
    }

    closeModalConfirmarCorreo() {
        const customevent = new CustomEvent('closemodalconfirmarcorreo');
        this.dispatchEvent(customevent);
    }

    closeModal() {
        const customevent = new CustomEvent('closemodals');
        this.dispatchEvent(customevent);
    }
}