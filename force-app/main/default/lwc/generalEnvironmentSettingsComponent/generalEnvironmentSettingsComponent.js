import { LightningElement, track, wire } from 'lwc';
import getData from '@salesforce/apex/GeneralEnvironmentSettingsComponentCtrl.getData';

const columnsCiclo = [
    {label: 'Label', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Fecha de Inicio',fieldName: 'fechaDeInicio',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}},
    {label: 'Fecha de Fin',fieldName: 'fechaDeFin',type: 'date-local',sortable: true,cellAttributes: {alignment: 'left'},typeAttributes: {month: "2-digit",day: "2-digit"}}
];
const columnsCNTP = [
    {label: 'Label', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Compensatorio', fieldName: 'compensatorio', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}}
];
const columnsLimiteDeRetraso = [
    {label: 'Label', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Limite de retraso', fieldName: 'limiteDeRetraso', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}}
];
const columnsTarget = [
    {label: 'Label', fieldName: 'label', type: 'text', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Nicho', fieldName: 'targetNicho', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Pediatricos General', fieldName: 'targetPediatricosGeneral', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Pediatricos Alergia', fieldName: 'targetPediatricosAlergia', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Adultos General', fieldName: 'targetAdultosGeneral', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}},
    {label: 'Oncologia', fieldName: 'targetOncologia', type: 'number', sortable: true, cellAttributes: {alignment: 'left'}}
];

export default class GeneralEnvironmentSettingsComponent extends LightningElement {

    @track data
    wiredDataResult;
    error;
    showSpinner = false;
    columns = [];

    @wire(getData , {
        metadata: 'target',
        fields: 'Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Target__c, Target_Nicho__c, Target_Pediatricos_General__c, Target_Pediatricos_Alergia__c, Numero_de_mes__c, Target_Adultos_General__c, Target_Oncologia__c'
    })
    wiredData(value) {
        this.wiredDataResult = value;
        const { data, error } = value;
        if (data) {
            this.columns = columnsTarget;
            console.log(data);
        } else if (error) {
            this.error = error;
            this.data = undefined;
            this.showSpinner = false;
        }
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    getSelectedById(event) {
        this.selectedRows = event.detail.selectedRows;
        for (let i = 0; i < this.selectedRows.length; i++){
            console.log("You selected: " + this.selectedRows[i].id);
        }
        this.disableApproval = (this.selectedRows.length == 0 || this.estadoSelected == 'Aprobada') ? true : false
        this.disableReject = (this.selectedRows.length == 0 || this.estadoSelected == 'Rechazada') ? true : false
    }

    showToast(titulo, mensaje, tipo, modo) {
        const event = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: tipo,
            mode: modo
        });
        this.dispatchEvent(event);
    }

}