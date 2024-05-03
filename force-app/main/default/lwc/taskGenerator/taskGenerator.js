import { LightningElement, api, track } from 'lwc';
import getAccounts from '@salesforce/apex/TaskGeneratorController.getAccountWrapper';
import queueTasks from '@salesforce/apex/TaskGeneratorController.queueTasks';
import getFields from '@salesforce/apex/TaskGeneratorController.getFields';

export default class TaskGenerator extends LightningElement {
    @api accList = [];
    @api accounts = [];
    @track columns;
    @api finalList = [];
    @track preSelectedRows;
    @api empty;
    @api selectedRecords = [];
    @api selectedAccounts;
    @api dueDate;
    @api showSpinner;
    @api showButton;
    @api showResult;
    @api resultMessage;
    @track columns = [];

    getAllColumns() {
        let items = [];
        getFields({})
            .then((result) => {
                result.forEach(element => {
                    items.push({
                        label: element.fieldName,
                        fieldName: element.fieldPath,
                        sortable: false
                    });
                });
                this.columns = items;
            })
            .catch((error) => {
                this.empty = true;
                console.log('66- ' + JSON.stringify(error));
            });
    }

    connectedCallback() {
        this.showResult = false;
        this.showSpinner = false;
        this.getAllColumns();
        let accList = this.accList.split(",");
        let splitedList = [];
        accList.forEach(element => {
            splitedList.push(element.replace("[", "").replace("]", "").trim())
        });
        getAccounts({ ids: splitedList })
            .then((result) => {
                this.accounts = result.accList;
                this.preSelectedRows = result.selectedIdSet;
                this.selectedRecords = this.accounts;
                this.selectedAccounts = this.accounts.length;
                if (this.accounts.length > 0) {
                    this.empty = false;
                    this.showButton = true;
                } else {
                    this.empty = true;
                    this.showButton = false;
                }
            })
            .catch((error) => {
                this.empty = true;
                console.log('37- ' + JSON.stringify(error));
            });
    }

    getSelectedRows() {
        this.selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        this.selectedAccounts = this.selectedRecords.length;
    }
    insertTasks() {
        if (this.dueDate == '' || this.dueDate == null) {
            alert("Por favor ingrese una fecha de vencimiento valida");
        } else if (this.selectedRecords.length == 0) {
            alert("Por favor seleccione al menos un paciente");
        } else {
            this.showButton = false;
            this.showSpinner = true;
            queueTasks({
                accounts: this.selectedRecords,
                dueDate: this.dueDate
            })
                .then((result) => {
                    this.resultMessage = "Se programo la creación de tareas para " + this.selectedRecords.length + ' pacientes, recibira un mail con los resultados';
                    console.log(result);
                    this.showSpinner = false;
                    this.showButton = true;
                    this.showResult = true;
                })
                .catch((error) => {
                    this.resultMessage = "Error. No se pudieron generar las tareas : " + error;
                    console.log('102- ' + JSON.stringify(error));
                    this.showSpinner = false;
                    this.showButton = true;
                    this.showResult = true;
                });
        }
    }
    handleDateChange(event) {
        this.dueDate = event.target.value;
    }

    back() {
        let url = window.location.href;
        var value = url.substr(0, url.lastIndexOf('/') + 1);
        window.history.back();
    }
}