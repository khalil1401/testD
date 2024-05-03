import { LightningElement, api, track, wire } from 'lwc';
import getUserId from '@salesforce/apex/PerfilUsuarioNSJController.getUserId';
import getEnvio from '@salesforce/apex/PerfilUsuarioNSJController.getEnvio';
import getDataPacienteBestCare from '@salesforce/apex/PerfilUsuarioNSJController.getDataPacienteBestCare';
import iconEnvioNSJRS from '@salesforce/resourceUrl/iconEnvioNSJ';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

export default class PerfilManagerNSJ extends NavigationMixin(LightningElement) {
    paciente;
    nombrePaciente;
    tipoPaciente;
    @track
    wiredPaciente;
    envio;
    dataBestCare;
    daysBetween;

    pacienteId;
    disabled = true;
    readyToSave;
    
    oldValue;
    object;
    fieldApiName;
    fieldType;
    recordId;

    showManager = true;
    showFormDatosPersonales;
    showFormDireccion;
    showFormPedido;
    showFormTratamiento;
    showFormContactos;
    showCardEnvio;
    showAvisoCoberturaOS;

    iconEnvio = iconEnvioNSJRS;

    @wire(getUserId)
    wiredGetUserId(result) {
        this.wiredPaciente = result;
        if (result.data) {
            this.paciente = result.data.Account;
            this.nombrePaciente = this.paciente.FirstName + ' ' + this.paciente.LastName;
            this.tipoPaciente = this.paciente.RecordType.DeveloperName;
            this.pacienteId = result.data.AccountId;
            if(this.tipoPaciente == 'Paciente_Best_Care') {
                this.getDataBestCare();
            }
        } else if (result.error) {
            console.error(result.error);
        }
    }

    @wire(getEnvio, {accountId: '$paciente.Id'})
    wiredGetEnvio(result) {
        if (result.data) {
            let el = result.data;
            if(el.Direccion_de_Envio__c && el.Localidad_de_Envio__c) {
                const path = {
                    direccion : el.Direccion_de_Envio__c.toLowerCase() + ', ' + el.Localidad_de_Envio__c.toLowerCase()
                };
                const register = Object.assign(path, el);
                this.envio = register;
            }
        } else if (result.error) {
            console.error(result.error);
        }
    }

    getDataBestCare() {
        getDataPacienteBestCare({ 
            pacienteId : this.paciente.Id
        })
        .then(result => {
            this.dataBestCare = result;
            let date_1 = new Date();
            date_1.setHours(21);
            date_1.setMinutes(0);
            date_1.setSeconds(0);
            let date_2 = new Date(this.dataBestCare.moduloHasta);
            let difference = date_2.getTime() - date_1.getTime();
            let TotalDays = Math.ceil(difference / (1000 * 3600 * 24));
            this.daysBetween = TotalDays;
            console.log(result);
        })
        .catch(error => {
            console.log(error);
        });
    }
    
    selectVinculoPrimerContacto(event){
        this.paciente.V_nculo__c = event.detail.value;
    }

    handleLocalidadEvent(event) {
        this.selectedLocalidadId = event.detail.id;
    }

    accountToUpdate() {
        this.disabled = false;
        this.readyToSave = true;
    }

    cancelUpdateData() {
        this.disabled = true;
        this.readyToSave = false;
    }

    updateData() {
        this.disabled = true;
        this.readyToSave = false;
    }

    goToSubseccion(event) {
        let id = event.target.dataset.id;
        this.showManager = false;
        this.showFormDatosPersonales = false;
        this.showFormTratamiento = false;
        this.showFormDireccion = false;
        this.showFormPedido = false;
        this.showFormContactos = false;
        this.showAvisoCoberturaOS = false;        
        if(id == 'datos-personales') {
            this.showFormDatosPersonales = true;    
        }
        else if(id == 'datos-direccion') {
            this.showFormDireccion = true;    
        }
        else if(id == 'datos-tratamiento') {
            this.showFormTratamiento = true;    
        }
        else if(id == 'datos-contacto') {
            this.showFormContactos = true;    
        }
        else if(id == 'aviso-cobertura') {
            this.showAvisoCoberturaOS = true;    
        }
    }

    gotToHome(){
        refreshApex(this.wiredPaciente);
        this.showFormDatosPersonales = false;
        this.showFormDireccion = false;
        this.showFormPedido = false;
        this.showFormTratamiento = false;
        this.showFormContactos = false;
        this.showAvisoCoberturaOS = false;
        this.showManager = true;
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

    showForm(event){
        let id = event.target.dataset.id;
        this.showManager = false;
        this.showFormDatosPersonales = false;
        this.showFormDireccion = false;
        this.showFormPedido = false;
        this.showFormTratamiento = false;
        this.showFormContactos = false;
        this.showAvisoCoberturaOS = false;
        if(id == 'datos-personales') {
            this.showFormDatosPersonales = true;
        }
        else if(id == 'datos-direccion') {
            this.showFormDireccion = true;    
        }
        else if(id == 'datos-pedido') {
            this.showFormPedido = true;
        }
        else if(id == 'principal') {
            this.showManager = true;
        }
        else if(id == 'datos-tratamiento') {
            this.showFormTratamiento = true;
        }
        else if(id == 'datos-contacto') {
            this.showFormContactos = true;
        }
    }

    logout() {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            }
        });
    }

    scrollTo(event) {
        let direction = event.target.dataset.id;
        let div = this.template.querySelector('[data-id="container-cards"]');
        if(div) {
            if(direction == 'toleft') {
                div.scrollLeft = div.scrollLeft - 10000;
            }
            else {
                div.scrollLeft = div.scrollLeft + 10000;
            }
        }
    }

    scrollEvent(event) {
        let div = this.template.querySelector('[data-id="container-cards"]');
        if(div) {
            if(div.scrollLeft > 100) {
                let divr = this.template.querySelector('[data-id="toright"]');
                if(divr) {
                    divr.classList.add('circle-selected');
                }
                let divl = this.template.querySelector('[data-id="toleft"]');
                if(divl) {
                    divl.classList.remove('circle-selected');
                    divl.classList.add('circle');
                }
            }
            else{
                let divl = this.template.querySelector('[data-id="toleft"]');
                if(divl) {
                    divl.classList.add('circle-selected');
                }
                let divr = this.template.querySelector('[data-id="toright"]');
                if(divr) {
                    divr.classList.remove('circle-selected');
                    divr.classList.add('circle');
                }
            }
        }
    }
}