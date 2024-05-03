import { LightningElement, track } from 'lwc';
import saveFile from '@salesforce/apex/RenovationOSPECONController.updateAccounts';

const columns = [
    {
        label: 'Name', fieldName: 'AccountURL', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            }
        }
    },
    { label: 'Id de paciente', fieldName: 'ID_de_paciente__c' },
    { label: 'DNI', fieldName: 'DNI__c', type: 'text' },
    { label: 'Modulo hasta', fieldName: 'Modulo_hasta__c', type: 'Date' },

];

export default class RenovationOSPECON extends LightningElement {

    @track columns = columns;
    @track data;
    @track fileName = '';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    showAccountTable = false;
    showButton = false;
    errorCSV = false;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    updatedListSize;
    MAX_FILE_SIZE = 1500000;

    handleFilesChange(event) {

        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.showButton = true;
        }

    }

    handleSave() {
        if(confirm('Confirma actualización de cuentas?')){
            if (this.filesUploaded.length > 0) {
                this.uploadHelper();
            }
            else {
                this.fileName = 'Please select a CSV file to upload.';
            }
        }

    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            window.console.log('File Size is to long');
            return;
        }

        this.showLoadingSpinner = true;
        this.fileReader = new FileReader();

        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            this.saveToFile();
        });

        this.fileReader.readAsText(this.file);

    }

    saveToFile() {
        var records = [];
        saveFile({ base64Data: JSON.stringify(this.fileContents) })
            .then(result => {
                if (result != undefined) {
                    result.forEach(item => item['AccountURL'] = '/' + item['Id']);
                    this.showAccountTable = true
                    this.data = result;
                    this.fileName = this.fileName + ' - Carga Exitosa';
                    this.isTrue = false;
                    this.showLoadingSpinner = false;
                    this.errorCSV = false
                    records = result;
                } else {
                    this.showLoadingSpinner = false;
                    this.errorCSV = true
                }
            })
            .catch(error => {
                window.console.log(error);
            }).finally(() => {
                this.updatedListSize =  'Cuentas actualizadas: ('+records.length +')';
                //this.setSizeList(records.length);
            });
    }
    setSizeList(size) {
        this.updatedListSize =  'Cuentas actualizadas: ('+size +')';
    }
    back() {
        let url = window.location.href;
        var value = url.substr(0, url.lastIndexOf('/') + 1);
        window.history.back();
    }

}