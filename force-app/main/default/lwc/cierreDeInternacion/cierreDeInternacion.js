import { LightningElement, api, wire } from 'lwc';
import cerrarInternacion from '@salesforce/apex/CierreDeInternacionController.cerrarInternacion';
import getInternacion from '@salesforce/apex/CierreDeInternacionController.getInternacion';
import getPickListValues from '@salesforce/apex/CierreDeInternacionController.getPickListValues';

export default class CierreDeInternacion extends LightningElement {

    @api internacion;
    mensajeAlerta;
    fechaDeCierre;
    yaCerrada;
    showSpinner;
    options = [];
    value;
    error;
    errorMessg;

    getOptions() {
        let values = [];
        console.log(values);
        getPickListValues()
            .then((result) => {
                result.forEach(element => {
                    console.log(element);
                    values.push(
                        { label: element, value: element }
                    );
                });
                this.options = values;
            })
            .catch((error) => {
                console.log('21- ' + JSON.stringify(error));
            });


    }

    connectedCallback() {
        this.error= false;
        this.mensajeAlerta = false;
        this.showSpinner = false;
        this.getOptions();
        getInternacion({ internacionId: this.internacion })
            .then((result) => {
                if (result.Fecha_de_Fin_Internaci_n__c == null) {
                    this.yaCerrada = false;
                } else {
                    this.errorMessg= 'Internación ya cerrada'
                    this.yaCerrada = true;
                }
            })
            .catch((error) => {
                this.yaCerrada = false;
                console.log('25- ' + JSON.stringify(error));
            });
    }
    handleDateChange(event) {
        this.mensajeAlerta = true;
        this.fechaDeCierre = event.target.value;
    }
    back() {
        let url = window.location.href;
        var value = url.substr(0, url.lastIndexOf('/') + 1);
        window.history.back();
    }
    cerrarInternacion() {
        this.showSpinner = true;

        cerrarInternacion({
            internacionId: this.internacion,
            fechaDeCierre: this.fechaDeCierre,
            estadoDeCierre: this.value
        })
            .then((result) => {
                this.showSpinner = false;
                this.yaCerrada = true;
                this.errorMessg= 'Internación ya cerrada'
            })
            .catch((error) => {
                this.yaCerrada = true;
                this.showSpinner = false;
                this.errorMessg = 'Error en cierre de internación, consulte con un administrador.';
                console.log('82- ' + JSON.stringify(error));
            });
    }
    handleChange(event) {
        this.value = event.detail.value;
    }
}