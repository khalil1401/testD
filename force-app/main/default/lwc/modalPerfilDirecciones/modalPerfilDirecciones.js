import { LightningElement, api, track, wire } from 'lwc';
import getProvincias from '@salesforce/apex/FormularioRegistroController.getPickListProvincias';
import getMunicipios from '@salesforce/apex/FormularioRegistroController.getPickListMunicipios';
import upsertDireccion from '@salesforce/apex/PerfilUsuarioNSJController.upsertDireccion';
import { loadStyle } from 'lightning/platformResourceLoader';
import nsjstyle from '@salesforce/resourceUrl/nsjCss';

export default class ModalPerfilDirecciones extends LightningElement {

    @api
    direccion;
    @api
    pacienteId;
    optionsProvincias;
    selectedProvincia;
    optionsMunicipios;
    selectedMunicipio;
    selectedLocalidadId;
    disabledMunicipio = true;
    disabledLocalidad = true;
    showSpinner;
    showTitle;
    isPrincipal;

    connectedCallback() {
        loadStyle(this, nsjstyle)
        .catch((error) => {
        showMessageError(this, 'Ha ocurrido un error!', error);
        });

        if(this.direccion.id) {
            this.showTitle = true;
        }
        if(this.direccion.principal) {
            this.isPrincipal = true;
        }
    }

    @wire(getProvincias)
    wiredGetProvincias({ error, data }) {
        if (data) {
            let res = data.map(el => {
                const path = {
                    label : el,
                    value: el
                };
                const itemProvincia = Object.assign(path, null);
                return itemProvincia;
            });
            this.optionsProvincias = res;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getMunicipios, { provincia: '$selectedProvincia' })
    wiredGetMunicipios({ error, data }) {
        if (data) {
            let res = data.map(el => {
                const path = {
                    label : el.Name,
                    value: el.Id
                };
                const itemMunicipio = Object.assign(path, null);
                return itemMunicipio;
            });
            this.optionsMunicipios = res;
            if(this.optionsMunicipios.length == 1){
                this.selectedMunicipio = this.optionsMunicipios[0].value;
            }
        } else if (error) {
            console.log(error);
        }
    }

    selectProvincia(event){
        this.selectedProvincia = event.detail.value;
        this.selectedMunicipio = '';
        this.selectedLocalidadId = '';
        this.disabledMunicipio = false;
        this.disabledLocalidad = true;
    }

    selectMunicipio(event){
        this.selectedMunicipio = event.detail.value;
        this.selectedLocalidadId = '';
        this.disabledLocalidad = false;
    }
    
    handleDataLookup(event) {
        this.selectedLocalidadId = event.detail.id;
    }

    closeModal() {
        const customevent = new CustomEvent('closemodal');
        this.dispatchEvent(customevent);
    }

    confirmar() {
        let allValid = true;
        var inputFields = this.template.querySelectorAll('.inputValidation');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                allValid = false;
            }
        });

        if(!this.selectedLocalidadId) {
            allValid = false;
        }

        if(allValid) {
            let id = this.direccion.id;;
            let pacienteId = this.pacienteId;
            let calle = this.template.querySelector('[data-id="calle"]').value;
            let altura = this.template.querySelector('[data-id="altura"]').value;
            let piso = this.template.querySelector('[data-id="piso"]').value;
            let dpto = this.template.querySelector('[data-id="dpto"]').value;
            let direccion = calle + ' ' + altura + ' ' + piso + ' ' + dpto;
            let cp = this.template.querySelector('[data-id="cp"]').value;
            let localidad = this.selectedLocalidadId;
            let ref = this.template.querySelector('[data-id="referencia"]').value;
            let principal = this.template.querySelector('[data-id="direccion-principal"]').checked;
    
            if(direccion && cp && localidad) {
                this.showSpinner = true;
                let dirobj = {
                    id : id,
                    principal : principal,
                    direccion : direccion,
                    cp : cp,
                    localidad : localidad,
                    ref : ref,
                    pacienteId : pacienteId
                }
                const customevent = new CustomEvent('savedireccion', {
                    detail: dirobj
                });
                this.dispatchEvent(customevent);        
            }
        }
    }

    handleChangeCheckbox(event) {
        if(event.detail.checked) {
            this.isPrincipal = true;
        }
        else {
            this.isPrincipal = false;
        }
    }
}