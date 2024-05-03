import { LightningElement, api } from 'lwc';
import saveTratamientoProf from '@salesforce/apex/PerfilUsuarioNSJController.saveTratamientoProf';
import deleteTratamientoProf from '@salesforce/apex/PerfilUsuarioNSJController.deleteTratamientoProf';
import { loadStyle } from 'lightning/platformResourceLoader';
import nsjstyle from '@salesforce/resourceUrl/nsjCss';

export default class ModalPerfilProfesional extends LightningElement {

    @api
    label;
    @api
    profesional;
    @api
    eliminacion;

    showSpinner;
    jsonObject = {};

    valueRadio;
    errorDerivador = false;

    get options() {
        return [
            { label: 'Este profesional te derivó a un especialista.', value: 'true' },
            { label: 'Iniciaste el tratamiento con este profesional.', value: 'false' },
        ];
    }

    connectedCallback() {
        loadStyle(this, nsjstyle)
        .catch((error) => {
        showMessageError(this, 'Ha ocurrido un error!', error);
        });

        if(this.profesional.id) {
            this.jsonObject["Id"] = this.profesional.id;
            if(this.profesional.profesionalDerivador) {
                this.valueRadio = 'true';
                this.jsonObject['Profesional_Derivador__c'] = true;
            }
            else{
                this.valueRadio = 'false';
                this.jsonObject['Profesional_Derivador__c'] = false;
            }
        }
        else{
            this.jsonObject["Tratamiento__c"] = this.profesional.Tratamiento__c;
            this.jsonObject['Profesional_Derivador__c'] = null;
        }
    }

    handleDataLookup(event){
        this.jsonObject["Profesional__c"] = event.detail.id;
    }

    handleRadioGroup(event) {
        this.valueRadio = event.detail.value;
        this.errorDerivador = false;
        if(this.valueRadio == 'true') {
            this.jsonObject['Profesional_Derivador__c'] = true; 
        }
        else if(this.valueRadio == 'false') {
            this.jsonObject['Profesional_Derivador__c'] = false; 
        }
    }

    closeModal() {
        const customevent = new CustomEvent('closemodal');
        this.dispatchEvent(customevent);
    }

    saveData() {
        let allValid = true;

        if((!this.profesional.nombreProfesional && !this.jsonObject.Profesional__c) || 
            (this.profesional.nombreProfesional && !this.jsonObject.Profesional__c && 
                this.jsonObject.Profesional_Derivador__c == null)) {
            this.template.querySelector('c-lookup-input').showErrorValidation();
            allValid = false;
        }
        if(this.jsonObject.Profesional_Derivador__c == null) {
            this.errorDerivador = true;
            allValid = false;
        }
        
        if(allValid) {
            this.showSpinner = true;
            let json = JSON.stringify(this.jsonObject);
            saveTratamientoProf({ 
                jsonTratamientoProf : json
            })
            .then(result => {
                this.closeModal();
            })
            .catch(error => {
                console.log(error);
            });
        }
    }

    deleteProfesional() {
        this.showSpinner = true;
        deleteTratamientoProf({ 
            recordId : this.profesional.id
        })
        .then(result => {
            const customevent = new CustomEvent('closemodaldelete');
            this.dispatchEvent(customevent);    
        })
        .catch(error => {
            console.log(error);
        });
    }
}