import { LightningElement, api, wire } from 'lwc';
import getDirecciones from '@salesforce/apex/PerfilUsuarioNSJController.getDirecciones';
import { refreshApex } from '@salesforce/apex';

export default class FormPerfilDirecciones extends LightningElement {
    @api
    paciente;
    direcciones;
    wiredDirecciones;
    selectedDireccion;
    showModal;
    showModalEliminar;
    showModalConfirmacion;
    addButtonDisabled;
    direccionObject;

    @wire(getDirecciones, { accountId: '$paciente.Id' })
    wiredGetContactos(result) {
        this.wiredDirecciones = result;
        if (result.data) {
            this.direcciones = result.data;
            this.addButtonDisabled = this.direcciones.length > 1 ? true : false
        } else if (result.error) {
            console.log(result.error);
        }
    }

    goToPerfilManager() {
        const customevent = new CustomEvent('closeform');
        this.dispatchEvent(customevent);
    }

    selectDireccion(event) {
        let id = event.target.dataset.id;
        for(let i = 0; i<this.direcciones.length; i++) {
            if(this.direcciones[i].id == id) {
                this.selectedDireccion = this.direcciones[i];
                this.showModal = true;
            }
        }
    }

    deleteDireccion() {
        this.showModalEliminar = true;
    }

    closeModal() {
        refreshApex(this.wiredDirecciones);
        this.showModal = false;
        this.showModalEliminar = false;
        this.showModalConfirmacion = false;
    }

    saveDireccion(event) {
        this.direccionObject = event.detail;
        this.showModal = false;
        this.showModalEliminar = false;
        this.showModalConfirmacion = true;
    }

    addNewDireccion() {
        this.selectedDireccion = {};
        this.showModal = true;
    }
}