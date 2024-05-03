import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTratamiento from '@salesforce/apex/PerfilUsuarioNSJController.getTratamiento';
import getTratamientoProf from '@salesforce/apex/PerfilUsuarioNSJController.getTratamientoDeProfesional';

export default class FormPerfilTratamiento extends LightningElement {

    @api
    paciente;
    @track
    wiredTratamiento;
    @track
    wiredTratamientoProf;
    tratamiento;
    tratamientoProf;
    areaTerapeutica;
    selectedProfesional = {};
    existeProfesionalSecundario = false;
    labelModal;

    recordId;
    object;
    fieldApiName;
    fieldType;
    oldValue;
    showModal;
    showModalProfesional;

    @wire(getTratamiento, { accountId: '$paciente.Id' })
    wiredGetTratamiento(result) {
        this.wiredTratamiento = result;
        if (result.data) {
            this.tratamiento = result.data;
            this.areaTerapeutica = this.tratamiento.Cuenta__r.Area_terapeutica__c;
        } else if (result.error) {
            console.log(result.error);
        }
    }

    @wire(getTratamientoProf, { tratamientoId: '$tratamiento.Id' })
    wiredGetTratamientoProf(result) {
        this.wiredTratamientoProf = result;
        if (result.data) {
            this.tratamientoProf = result.data;
            if(this.tratamientoProf.length > 1) {
               this.existeProfesionalSecundario = true; 
            }
        } else if (result.error) {
            console.log(result.error);
        }
    }

    setEditableField(event){
        let fieldRecordId = event.target.dataset.record;
        let fieldApiNameId = event.target.dataset.id;
        let fieldObjectId = event.target.dataset.object;
        let fieldTypeId = event.target.dataset.fieldtype;

        let idInput = event.target.dataset.id;
        if(idInput){
            idInput = 'input-' + idInput;
        }
        
        let input = this.template.querySelector('[data-id='+ idInput + ']');
        if(input){
            this.recordId = fieldRecordId;
            this.object = fieldObjectId;
            this.fieldApiName = fieldApiNameId;
            this.fieldType = fieldTypeId;
            this.oldValue = input.value;
            this.openModal();
        }
    }

    goToPerfilManager() {
        const customevent = new CustomEvent('closeform');
        this.dispatchEvent(customevent);
    }

    openModalProfesional(event) {
        let id = event.target.dataset.id;
        for(let i = 0; i<this.tratamientoProf.length; i++) {
            if(this.tratamientoProf[i].id == id) {
                this.selectedProfesional = this.tratamientoProf[i];
                this.labelModal = '¿Desea actualizar este campo?';
                this.showModalProfesional = true;                
            }
        }
    }

    openModal() {
        this.showModal = true;
    }

    closeModal() {
        refreshApex(this.wiredTratamiento);
        refreshApex(this.wiredTratamientoProf);
        this.showModal = false;
        this.showModalProfesional = false;
        this.eliminarProfesional = false;
        this.selectedProfesional = {};
    }

    closeModalDelete() {
        refreshApex(this.wiredTratamiento);
        refreshApex(this.wiredTratamientoProf);
        this.showModal = false;
        this.showModalProfesional = false;
        this.selectedProfesional = {};
        this.eliminarProfesional = false;
        this.existeProfesionalSecundario = false;
    }

    addProfesional() {
        this.selectedProfesional["Tratamiento__c"] = this.tratamiento.Id;
        this.labelModal = '¿Desea añadir un nuevo profesional?';
        this.showModalProfesional = true;
    }

    deleteProfesional(event) {
        let id = event.target.dataset.id;
        this.selectedProfesional["id"] = id;
        this.eliminarProfesional = true;
        this.showModalProfesional = true;
    }
}