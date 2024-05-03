import { LightningElement, api, wire } from 'lwc';
import getTiposTelefono from '@salesforce/apex/FormularioRegistroController.getPickListTiposDeTelefono';
import saveAccount from '@salesforce/apex/PerfilUsuarioNSJController.saveAccount';
import { loadStyle } from 'lightning/platformResourceLoader';
import nsjstyle from '@salesforce/resourceUrl/nsjCss';

export default class ModalPerfilTelefono extends LightningElement {

    @api
    paciente;
    tiposDeTelefono;
    tipoTelefonoSeleccionado;
    codArea;
    telefono;
    object = {};
    showSpinner;
    showValidacion = false;

    connectedCallback() {
        loadStyle(this, nsjstyle)
        .catch((error) => {
        showMessageError(this, 'Ha ocurrido un error!', error);
        });
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

    handleFormInputChange(event){
        this.object[event.target.name] = event.target.value;
        this.tipoTelefonoSeleccionado = this.object["Tipo_de_telefono__c"];
        this.telefono = this.object["tel"];
        this.codArea = this.object["codarea"];
    }

    saveData() {
        this.showSpinner = true;
        let acc = {
            Id : this.paciente.Id,
            Tipo_de_telefono__c : this.object["Tipo_de_telefono__c"],
        };
        if(acc['Tipo_de_telefono__c'] == 'Celular') {
            acc['Phone'] = '549' + this.object["codarea"] + this.object["tel"]
        }
        else {
            acc['Phone'] = '54' + this.object["codarea"] + this.object["tel"]
        }

        let jsonObject = JSON.stringify(acc);
        saveAccount({ 
            jsonAccount : jsonObject
        })
        .then(result => {
            this.closeModal();
        })
        .catch(error => {
            console.log(error);
            this.closeModal();
        });
    }

    volverForm() {
        this.showValidacion = false;
    }

    validar() {
        let allValid = true;
        var inputFields = this.template.querySelectorAll('.inputValidation');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                allValid = false;
            }
        });

        if(allValid) {
            this.showValidacion = true;
        }
    }

    closeModal() {
        const customevent = new CustomEvent('closemodal');
        this.dispatchEvent(customevent);
    }
}