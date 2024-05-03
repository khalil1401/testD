import { LightningElement, api, wire } from 'lwc';
import getLocalidades from '@salesforce/apex/LookupComponentController.getLocalidades';
import getObraSociales from '@salesforce/apex/LookupComponentController.getObrasSociales';
import getInstituciones from '@salesforce/apex/LookupComponentController.getInstituciones';
import getProfesionales from '@salesforce/apex/LookupComponentController.getProfesionales';

export default class LookupInput extends LightningElement {

    @api object;
    @api label;
    @api value;
    @api selectedItemId;
    @api disabled;
    @api required;
    @api idMunicipio;
    @api fieldApiName;

    items;
    filteredItems;
    showItems;

    @api 
    showErrorValidation() {
        let inputFields = this.template.querySelectorAll('.inputValidation');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
            }
        });
    }

    connectedCallback() {
        if(this.object == 'Tratamiento__c') {
            if(this.fieldApiName == 'Obra_social__c'){
                getObraSociales()
                .then(result => {
                    this.items = result;
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                });
            }
            else if(this.fieldApiName == 'Centro_de_tratamiento__c'){
                getInstituciones()
                .then(result => {
                    this.items = result;
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                });
            }
        }
        else if(this.object == 'Tratamiento_de_profesional__c') {
            if(this.fieldApiName == 'Profesional__c'){
                getProfesionales()
                .then(result => {
                    this.items = result;
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                });
            }
        }

    }    

    @wire(getLocalidades, { idMunicipio: '$idMunicipio' })
    wiredGetLocalidades({ error, data }) {
        if (data) {
            this.value = '';
            this.selectedItemId = '';
            this.sendItemId();
            this.items = data;
            if(this.items.length == 1){
                this.value = this.items[0].Name;
                this.selectedItemId = this.items[0].Id;
                this.sendItemId();
            }
        } else if (error) {
            console.log(error);
        }
    }

    filterItems(event){
        let inputValue = event.target.value;
        let newItems = this.items.filter(function (el) {
            return el.Name.toUpperCase().includes(inputValue.toUpperCase());
        });
        this.filteredItems = newItems;
        this.showItems = true;
    }

    selectItem(event){
        let id = event.target.dataset.id;
        let name = event.target.dataset.name;
        this.selectedItemId = id;
        this.value = name.toUpperCase();
        this.showItems = false;
        this.sendItemId();
    }

    sendItemId() {
        const myEvent = new CustomEvent('mydata', {
            detail: { id: this.selectedItemId }
        });
        this.dispatchEvent(myEvent);
    }
}