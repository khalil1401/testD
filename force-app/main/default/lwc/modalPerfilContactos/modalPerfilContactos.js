import { LightningElement, api, wire } from 'lwc';
import getRelaciones from '@salesforce/apex/FormularioRegistroController.getPickListRelacionContacto';
import getTiposTelefono from '@salesforce/apex/FormularioRegistroController.getPickListTiposDeTelefono';
import updateContact from '@salesforce/apex/PerfilUsuarioNSJController.updateContact';
import insertContact from '@salesforce/apex/PerfilUsuarioNSJController.insertContact';
import { loadStyle } from 'lightning/platformResourceLoader';
import nsjstyle from '@salesforce/resourceUrl/nsjCss';

export default class ModalPerfilContactos extends LightningElement {

    relaciones;
    tiposDeTelefono;
    @api
    contacto;
    @api
    dniExistente;
    newContact = {};
    showMobilePhoneField;
    showSpinner;
    errorDNIExistente;

    connectedCallback() {
        loadStyle(this, nsjstyle)
        .catch((error) => {
        showMessageError(this, 'Ha ocurrido un error!', error);
        });

        //reviso si existe contacto para editar o es uno nuevo
        if(this.contacto.Id) {
            this.newContact["Id"] = this.contacto.Id;
            this.newContact["Paciente__c"] = this.contacto.Paciente__c;
        }
        else{
            this.newContact["Paciente__c"] = this.contacto.Paciente__c;
        }
        //reviso si el contacto
        if(this.contacto.Tipo_de_Telefono_de_Contacto__c == 'Celular') {
            this.showMobilePhoneField = true;
        }
        else {
            this.showMobilePhoneField = false;
        }
        console.log(this.dniExistente);
    }

    @wire(getRelaciones)
    wiredGetRelaciones(result) {
        if (result.data) {
            let res = result.data.map(el => {
                const path = {
                    label : el,
                    value : el
                };
                const item = Object.assign(path, null);
                return item;
            });
            this.relaciones = res;
        } else if (result.error) {
            console.log(result.error);
        }
    }

    @wire(getTiposTelefono)
    wiredGetTiposTelefono(result) {
        if (result.data) {
            let res = result.data.map(el => {
                const path = {
                    label : el,
                    value : el
                };
                const item = Object.assign(path, null);
                return item;
            });
            this.tiposDeTelefono = res;
        } else if (result.error) {
            console.log(result.error);
        }
    }

    closeModal() {
        const customevent = new CustomEvent('closemodal');
        this.dispatchEvent(customevent);
    }

    handleFormInputChange(event){
        this.newContact[event.target.name] = event.target.value;
        if(event.target.type == 'checkbox') {
            this.newContact[event.target.name] = event.target.checked;
        }
        //reviso si el contacto cambia de tipo de tel
        if(event.target.name == 'Tipo_de_Telefono_de_Contacto__c') {
            if(this.newContact.Tipo_de_Telefono_de_Contacto__c == 'Celular') {
                this.showMobilePhoneField = true;
            }
            else {
                this.showMobilePhoneField = false;
            }
        }
        //reviso si el contacto cambia el dni
        if(event.target.name == 'DNI__c') {
            this.errorDNIExistente = false;
        }
    }

    saveObject() {
        let allValid = true;
        var inputFields = this.template.querySelectorAll('.inputValidation');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                allValid = false;
            }
        });

        if(this.newContact.DNI__c == this.dniExistente) {
            this.errorDNIExistente = true;
            allValid = false;
        }

        if(allValid) {
            //Update contacto
            this.showSpinner = true;
            let jsonObject = JSON.stringify(this.newContact);
            if(this.newContact.Id) {
                updateContact({ 
                    jsonContact : jsonObject
                })
                .then(result => {
                    this.closeModal();
                })
                .catch(error => {
                    console.log(error);
                });
            }
            else {
                insertContact({ 
                    jsonContact : jsonObject
                })
                .then(result => {
                    this.closeModal();
                })
                .catch(error => {
                    console.log(error);
                });
            }
        }
    }
}