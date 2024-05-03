import { LightningElement, api, track, wire } from 'lwc';
import getDatosPersonales from '@salesforce/apex/PerfilUsuarioNSJController.getDatosPersonales';
import { refreshApex } from '@salesforce/apex';

export default class FormPerfilDatosPersonales extends LightningElement {
    @api
    paciente;
    @api
    nombrePaciente;
    @track
    wiredCuenta;
    cuenta;
    
    recordId;
    object;
    fieldApiName;
    fieldType;
    oldValue;
    newValue;

    showModal;
    showModalTelefono;
    showModalConfirmarCorreo;

    @wire(getDatosPersonales, {pacienteId : '$paciente.Id'})
    wiredGetDatosPersonales(result) {
        this.wiredCuenta = result;
        if (result.data) {
            this.cuenta = result.data;
        } else if (result.error) {
            console.error(result.error);
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

    openModal() {
        this.showModal = true;
    }

    openModalTelefono() {
        this.showModalTelefono = true;
    }

    openModalConfirmarCorreo(event) {
        this.newValue = event.detail;
        this.showModal = false;
        this.showModalConfirmarCorreo = true;
    }

    closeModal() {
        refreshApex(this.wiredCuenta);
        this.showModal = false;
        this.showModalTelefono = false;
        this.showModalConfirmarCorreo = false;
    }

    closeModalConfirmarCorreo() {
        this.showModal = true;
        this.showModalConfirmarCorreo = false;
        this.showModalTelefono = false;
    }
}