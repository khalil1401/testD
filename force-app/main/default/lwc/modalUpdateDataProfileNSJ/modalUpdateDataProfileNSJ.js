import { LightningElement, api, wire } from 'lwc';
import getPicklistValues from '@salesforce/apex/PerfilUsuarioNSJController.getPicklistValues';
import saveJSONAccount from '@salesforce/apex/PerfilUsuarioNSJController.saveAccount';
import saveJSONTratamiento from '@salesforce/apex/PerfilUsuarioNSJController.saveTratamiento';
import { loadStyle } from 'lightning/platformResourceLoader';
import nsjstyle from '@salesforce/resourceUrl/nsjCss';

export default class ModalUpdateDataProfileNSJ extends LightningElement {

    @api
    recordId;
    @api
    oldValue;
    @api
    fieldType;
    @api
    object;
    @api
    fieldApiName;
    @api
    parameter;

    newValue;
    picklistValue;
    showSpinner;

    @api
    get _isNormalInput() {
        return this.fieldType == 'normal' ? true : false;
    }

    @api
    get _isSelectInput() {
        return this.fieldType == 'select' ? true : false;
    }

    @api
    get _isLookupInput() {
        return this.fieldType == 'lookup' ? true : false;
    }

    connectedCallback() {
        loadStyle(this, nsjstyle)
        .catch((error) => {
        showMessageError(this, 'Ha ocurrido un error!', error);
        });
        
        if (this._isSelectInput) {
            getPicklistValues({ 
                objectPicklist : this.object, 
                fieldPicklist : this.fieldApiName,
                area : this.parameter
            })
            .then(result => {
                let res = result.map(el => {
                    const path = {
                        label : el,
                        value : el
                    };
                    const item = Object.assign(path, null);
                    return item;
                });
                this.picklistValue = res;
            })
            .catch(error => {
                console.log("error");
            });
        }
    }

    handleChangePicklistValue(event) {
        this.newValue = event.detail.value;
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

        if(this.fieldApiName == 'Obra_social__c' && !this.newValue) {
            this.template.querySelector('c-lookup-input').showErrorValidation();
            allValid = false;
        }

        if(this.fieldApiName == 'Centro_de_tratamiento__c' && !this.newValue) {
            this.template.querySelector('c-lookup-input').showErrorValidation();
            allValid = false;
        }
        
        if(allValid) {
            this.showSpinner = true;
            let newRecord = {
                Id : this.recordId
            };
            if(this.newValue) {
                newRecord[this.fieldApiName] = this.newValue;
            }
            let jsonObject = JSON.stringify(newRecord);
            if(this.object == 'Account') {
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
            else if(this.object == 'Tratamiento__c') {
                saveJSONTratamiento({ 
                    jsonTratamiento : jsonObject
                })
                .then(result => {
                    this.closeModal();
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                    this.closeModal();
                });
            }
            else if(this.object == 'Tratamiento_de_profesional__c') {
                saveJSONTratamientoProf({ 
                    jsonTratamientoProf : jsonObject
                })
                .then(result => {
                    this.closeModal();
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                    this.closeModal();
                });
            }
        }
    }

    handleDataLookup(event){
        this.newValue = event.detail.id;
    }

    openConfirmarModal() {
        let allValid = true;
        
        var inputFields = this.template.querySelectorAll('.inputValidation');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                allValid = false;
            }
        });

        if(allValid) {
            const customevent = new CustomEvent('confirmarcorreo', {
                detail: this.newValue
            });
            this.dispatchEvent(customevent);
        }
    }

    closeModal() {
        const customevent = new CustomEvent('closemodal');
        this.dispatchEvent(customevent);
    }
}