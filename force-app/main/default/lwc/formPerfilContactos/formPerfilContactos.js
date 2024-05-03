import { LightningElement, api, track, wire } from 'lwc';
import getContactos from '@salesforce/apex/PerfilUsuarioNSJController.getContacts';
import { refreshApex } from '@salesforce/apex';

export default class FormPerfilContactos extends LightningElement {
    @api
    paciente;
    @track
    wiredContacts;
    contacts;
    showModal;
    selectedContact;
    addButtonDisabled;
    showModalEliminacion;
    dniExistente;

    @wire(getContactos, { accountId: '$paciente.Id' })
    wiredGetContactos(result) {
        this.wiredContacts = result;
        if (result.data) {
            var res = result.data.map(el => {
                if(el.Tipo_de_Telefono_de_Contacto__c == 'Celular') {
                    const path = {
                        showMobilePhoneField : true
                    };
                    const record = Object.assign(path, el);
                    return record;
                }
                else {
                    const path = {
                        showMobilePhoneField : false
                    };
                    const record = Object.assign(path, el);
                    return record;
                }
            });
            this.contacts = res;
            this.addButtonDisabled = this.contacts.length > 1 ? true : false;
        } else if (result.error) {
            console.log(result.error);
        }
    }

    goToPerfilManager() {
        const customevent = new CustomEvent('closeform');
        this.dispatchEvent(customevent);
    }

    selectContact(event) {
        let dni = event.target.dataset.id;
        this.dniExistente = '';
        for(let i = 0; i<this.contacts.length; i++) {
            if(this.contacts[i].DNI__c == dni) {
                this.selectedContact = this.contacts[i];
                this.showModal = true;
            }
            else {
                //agrego el dni del otro contacto
                this.dniExistente = this.contacts[i].DNI__c;
            }
        }
    }

    closeModal() {
        refreshApex(this.wiredContacts);
        this.showModal = false;
        this.showModalEliminacion = false;
    }

    addNewContact() {
        this.selectedContact = {};
        this.selectedContact["Paciente__c"] = this.paciente.Id;
        this.showModal = true;
        //agrego el dni del otro contacto
        this.dniExistente = '';
        if(this.contacts) {
            this.dniExistente = this.contacts[0].DNI__c;
        }
    }

    deleteContact(event) {
        let dni = event.target.dataset.id;
        for(let i = 0; i<this.contacts.length; i++) {
            if(this.contacts[i].DNI__c == dni) {
                this.selectedContact = this.contacts[i];
                this.showModalEliminacion = true;
            }
        }
    }
}