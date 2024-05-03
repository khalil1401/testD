import { LightningElement, api } from 'lwc';
import setStatusPaciente from '@salesforce/apex/PerfilUsuarioNSJController.setStatusPaciente';
import iconFAQRS from '@salesforce/resourceUrl/iconHelpFAQNSJ';

export default class FormPerfilAvisoCobertura extends LightningElement {

    iconFAQ = iconFAQRS;

    @api
    paciente;
    today;
    fecha;
    fechastring;
    menorDiezDias;
    consentimiento = true;
    seleccionarFecha;
    primerTramite;
    consejos;
    estados;
    sinrespuesta;
    modal;
    textModal;
    status;
    primerTramiteValue;
    gestionIniciada;
    
    spanHelp;
    showSpinner;

    connectedCallback () {
        let date = new Date();
        let dia = date.getDate();
        if(dia.toString().length == 1) {
            dia = '0' + dia; 
        }
        let mes = date.getMonth() + 1;
        if(mes.toString().length == 1) {
            mes = '0' + mes; 
        }
        let anio = date.getFullYear();
        this.today = anio + '-' + mes + '-' + dia;
    }

    goToPerfilManager() {
        const customevent = new CustomEvent('closeform');
        this.dispatchEvent(customevent);
    }

    next(event) {
        let step = event.target.dataset.id;
        if(step == 'consentimiento') {
            this.consentimiento = false;
            this.seleccionarFecha = true;
        }
        else if(step == 'consejos') {
            this.seleccionarFecha = false;
            this.consejos = true;
        }
        else if(step == 'validarFecha') {
            let isValid = true;
            let inputFields = this.template.querySelectorAll('.validate');
            inputFields.forEach(inputField => {
                if(!inputField.checkValidity()) {
                    inputField.reportValidity();
                    isValid = false;
                }
            });
            if(isValid && this.fecha) {
                this.seleccionarFecha = false;
                this.primerTramite = true;
            }
        }
        else if(step == 'sinrespuesta' && this.menorDiezDias) {
            this.estados = false;
            this.sinrespuesta = true;
        }
    }

    setSinFecha(event) {
        this.estado = 'sinfecha';
        this.showSpinner = true;
        setStatusPaciente({ 
            accountId : this.paciente.Id,
            step : this.estado,
            fecha : this.fecha,
            primerTramite : this.primerTramiteValue
        })
        .then(result => {
            console.log('Success');
            this.goToPerfilManager();
        })
        .catch(error => {
            console.log(error);
            this.goToPerfilManager();
        });
    }
    
    getDate(event) {
        let dateselected = event.target.value;
        this.fechastring = dateselected;
        this.fecha = new Date(dateselected);
        this.fecha.setHours(0, 0, 0);
        this.fecha.setDate(this.fecha.getDate() + 1);

        let newDate = new Date();
        newDate.setHours(0, 0, 0);
        newDate.setDate(newDate.getDate() - 10);

        if(Date.parse(newDate) <= Date.parse(this.fecha)) {
            this.menorDiezDias = true;
        }
        else{
            this.menorDiezDias = false;
        }
    }

    checkSinRespuesta(event) {
        if(this.menorDiezDias) {
            this.estados = false;
            this.sinrespuesta = true;
        }
        else {
            let status = event.target.dataset.estado;
            let text = event.target.dataset.title;
            this.textModal = '"' + text + '"';
            this.estado = status;
            this.modal = true;
        }
    }

    openModal(event) {
        let status = event.target.dataset.estado;
        let text = event.target.dataset.title;
        this.textModal = '"' + text + '"';
        this.estado = status;
        this.modal = true;
    }

    backModal() {
        this.modal = false;
    }

    changeStatus() {
        this.setStatus();
    }

    setStatus() {
        this.showSpinner = true;
        setStatusPaciente({ 
            accountId : this.paciente.Id,
            step : this.estado,
            fecha : this.fecha,
            primerTramite : this.primerTramiteValue
        })
        .then(result => {
            console.log('Success');
            this.closeModal();
        })
        .catch(error => {
            console.log(error);
            this.closeModal();
        });
    }

    closeModal() {
        this.modal = false;
        this.estados = false;
        this.gestionIniciada = true;
    }

    back(event) {
        let step = event.target.dataset.step;
        console.log(step);
        if(step == 'consentimientoback') {
            this.goToPerfilManager();
        }
        else if(step == 'seleccionarfechaback') {
            this.goToPerfilManager();
        }
        else if(step == 'primertramiteback') {
            this.primerTramite = false;
            this.seleccionarFecha = true;
        }
        else if(step == 'consejosback') {
            this.consejos = false;
            this.seleccionarFecha = true;
        }
        else if(step == 'estadosback') {
            this.estados = false;
            this.primerTramite = true;
        }
    }
    
    showSpanHelp() {
        this.spanHelp = !this.spanHelp;
    }

    hideSpanHelp() {
        this.spanHelp = false;
    }

    setPrimerTramite(event) {
        let check = event.target.dataset.id;
        let primertramite = (check == 'true') ? true : false;
        this.primerTramiteValue = primertramite;
        this.primerTramite = false;
        this.estados = true;
    }
}