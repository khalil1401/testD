import { LightningElement, track , api , wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import saveFile from '@salesforce/apex/orderDataLoaderController.saveFile';
import modal from "@salesforce/resourceUrl/modalWidth";
import { loadStyle } from "lightning/platformResourceLoader";
import getValuesTipoVenta from '@salesforce/apex/orderDataLoaderController.getTipoVenta';


const columnsOrder = [
    /* { label: 'Código Cliente', fieldName: 'codCliente' }, */ 
    { label: 'Sucursal', fieldName: 'sucursal' },
    { label: 'Orden de Compra', fieldName: 'ordenDeCompra'}, 
    /* { label: 'Observación', fieldName: 'observacion'},  */
    { label: 'Código Producto', fieldName: 'codProducto'},
    { label: 'Nombre Producto', fieldName: 'nombreProducto'}, 
    { label: 'Cantidad Solicitada', fieldName: 'cantidadProducto'}
];



export default class OrderDataLoader extends LightningElement {
    @track isDisabled = true;
    @api recordId;
    @track error;
    @track columnsOrder = columnsOrder;
    @track data;
    @track fileName = '';
    @track showLoadingSpinner = false;
    @track tipoVenta;
    tipoVentaOpcs;
    
    @wire(getValuesTipoVenta) tipoVentaValue({ data, error }){
        if (data) {
            console.log(data);
            this.tipoVentaOpcs = data;
        } else {
            console.debug(error);
        }
    }; 


    uploadedFiles = [];
    file;
    MAX_FILE_SIZE = 1500000;
    fileReader;
    fileContents;

    get acceptedCSVFormats() {
        return ['.csv'];
    }

    get options() {
        return [
            { label: 'AMN', value: '5800' },
            { label: 'Nuba', value: '5771' },
        ];
    }

    get optionsTipoVenta(){
        return this.tipoVentaOpcs;
    }

    connectedCallback() {
        loadStyle(this, modal);
    }


    handleChangeTipoVenta(event){
        this.tipoVenta = event.detail.value;
    }

    handleSave(){
        this.uploadHelper(true);
    }

    uploadFileHandler(event){
        if(this.tipoVenta ==null){
            this.dispatchEvent(
                new ShowToastEvent({
    
                    title: 'Error!!',
    
                    message: ' La unidad de negocio y/o tipo de venta no puede estar vacia',
    
                    variant: 'error',
    
                }),
    
            );
        }else{
            this.uploadedFiles = event.detail.files;
            this.fileName = event.detail.files[0].name;
            console.log('uploadedFiles');
            console.log(this.uploadedFiles);
            if(this.uploadedFiles.length > 0){
                this.uploadHelper(false);
            }else{
                this.fileName = 'Por favor, Suba un archivo para ser procesado'
            }
        }            
    }

    uploadHelper(isSave) {

        this.file = this.uploadedFiles[0];
        console.log('this file '+ JSON.stringify(this.file));
        console.log(this.file);
        if (this.file.size > this.MAX_FILE_SIZE) {
 
            console.log('File Size is to long');
 
            return ;
 
        }
        
        this.showLoadingSpinner = true;

 

        this.fileReader= new FileReader();
 
  
 
        this.fileReader.onloadend = (() => {

            this.fileContents = this.fileReader.result;
            console.log('this.fileContents');
            console.log(this.fileContents);
            this.saveToFile(isSave);
 
        });
 
  
 
        this.fileReader.readAsText(this.file);
        
    }
    
    saveToFile(isSave) {

        saveFile({ base64Data: JSON.stringify(this.fileContents),tipoVenta: this.tipoVenta, isSave: isSave})
 
        .then(result => {
            //let error = "";
            window.console.log('result ====> ');
 
            window.console.log(result);


            this.data = result;
 
                if(this.isDisabled){
                    this.isDisabled = false;
                }
            
                this.fileName = this.fileName + ' - Carga Correcta';
            
            
                this.showLoadingSpinner = false;
            
            
                if(isSave) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                        
                            title: 'Success!!',
                        
                            message: this.file.name + ' - Se guardo Correctamente!!!',
                        
                            variant: 'success',
                        
                        }),
                    
                    );
                    this.isDisabled = true;
                    this.uploadedFiles= [];
                    this.file = null;
                    eval("$A.get('e.force:refreshView').fire();");

                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                        
                            title: 'Success!!',
                        
                            message: this.file.name + ' - Archivo cargado correctamente, por favor guarde el pedido para continuar',
                        
                            variant: 'success',
                        
                        }),
                    
                    );
                }



            /* console.log('error');
            console.log(result[0].error);
  
            for (let i = 0; i < result.length; i++) {
                console.log('Error en:' + i);
                console.log(result[i].error);
                if(result[i].error !== ""){
                    error = result[i].error;
                    break;
                }
            } */
            /* console.log(error);
            if(error === ""){
                this.data = result;
 
                if(this.isDisabled){
                    this.isDisabled = false;
                }
            
                this.fileName = this.fileName + ' - Carga Correcta';
            
            
                this.showLoadingSpinner = false;
            
            
                if(isSave) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                        
                            title: 'Success!!',
                        
                            message: this.file.name + ' - Se guardo Correctamente!!!',
                        
                            variant: 'success',
                        
                        }),
                    
                    );
                    this.isDisabled = true;
                    this.uploadedFiles= [];
                    this.file = null;

                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                        
                            title: 'Success!!',
                        
                            message: this.file.name + ' - Se proceso Correctamente!!',
                        
                            variant: 'success',
                        
                        }),
                    
                    );
                }
                console.log('Error esta vacio');
            } */
        })
 
        .catch(error => {
 
  
 
            window.console.log(error);
            
            this.showLoadingSpinner = false;
            
            this.dispatchEvent(
 
                new ShowToastEvent({
 
                    title: 'Error al cargar el archivo',
 
                    message: error.body.message,
 
                    variant: 'error',
 
                }),
 
            );
 
        });
 
    }

     // this method validates the data and creates the csv file to download
     downloadCSVFile() {
        
        const mockData = [{
            "Sucursal": '552910193',
            "Orden de Compra": '458',
            "Codigo Producto": '174732',
            "Nombre Producto": 'MONOGEN 6X400G INT (INT)',
            "Cantidad Solicitada": 7
        }]
        
        let rowEnd = '\r\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        mockData.forEach(function (record) {            
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;
        
        // main for loop to get the data based on key value
        for(let i=0; i < mockData.length; i++){
            let colValue = 0;
            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = mockData[i][rowKey] === undefined ? '' : mockData[i][rowKey];
                    csvString += value;                    
                    colValue++;
                }
            }
            csvString += rowEnd;            
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'Pedido de muestra.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }

    
}