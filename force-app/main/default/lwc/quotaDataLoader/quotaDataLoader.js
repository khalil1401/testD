import {LightningElement, api, track} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import {showToast, formatBytes} from 'c/dan360Utils';
import save from '@salesforce/apex/QuotaController.save';
// import modal from '@salesforce/resourceUrl/modalWidth';

const quotaColumns = [
	{
		label: 'Producto',
		fieldName: 'Dan360_Producto__c'
	},
	{
		label: 'Cuota',
		fieldName: 'Dan360_Cuota__c'
	},
	{
		label: 'Producto',
		fieldName: 'Dan360_Producto__c'
	},
	{
		label: 'Cliente',
		fieldName: 'Dan360_Cliente__c'
	},
	{
		label: 'Canal Comercial',
		fieldName: 'Dan360_CanalComercial__c'
	},
	{
		label: 'Saldo',
		fieldName: 'Dan360_Saldo__c'
	},
	{
		label: 'Vigencia desde',
		fieldName: 'Dan360_VigenciaDesde__c'
	},
	{
		label: 'Vigencia hasta',
		fieldName: 'Dan360_VigenciaHasta__c'
	},
	{
		label: 'Estado de cuota',
		fieldName: 'Dan360_EstadoCuota__c'
	}
];

export default class QuotaDataLoader extends LightningElement {
	@track isDisabled = true;
	@track error;
	@track quotaColumns = quotaColumns;
	@track data;
	@track unidadNegocio = 'AMN';
	@track fileName;
	@track showLoadingSpinner = false;
	@api recordId;
	MAX_FILE_SIZE = 1500000;
	uploadedFiles = [];
	file;
	fileReader;
	fileContents;
	errors;
	success;

	get acceptedFormats () {
		return ['.csv'];
	}

	connectedCallback () {
		// loadStyle(this, modal);
	}

	handleChange (event) {
	}

	handleSave () {
	}

	uploadHandler (event) {
		this.uploadedFiles = event.detail.files;
		this.file = this.uploadedFiles[0];

		if (this.uploadedFiles.length > 0) {
			this.fileName = `Tamaño: [${formatBytes(this.file.size)}]`;
			this.uploadHelper(false);
		} else {
			this.fileName = 'Seleccione un archivo para ser procesado';
		}
	}

	uploadHelper () {
		this.file = this.uploadedFiles[0];

		if (this.file.size > this.MAX_FILE_SIZE) {
			console.log('File Size is to long', this.file.size);
			this.dispatchEvent(
				showToast('error', 'pester', 'ERROR', `El tamaño de archivo sobrepasa el límite permitido. [${formatBytes(this.MAX_FILE_SIZE)}]`)
			);
			return;
		}

		this.showLoadingSpinner = true;

		this.fileReader = new FileReader();
		this.fileReader.onloadend = (() => {
			this.fileContents = this.fileReader.result;
			console.log(this.fileContents);
			this.saveToFile();
		});

		this.fileReader.readAsText(this.file);
	}

	saveToFile () {
		save({
			base64Data: JSON.stringify(this.fileContents)
		}).then(response => {
			let oResponse = response;
			
			console.log('oResponse', oResponse);

			this.success = oResponse.state == 'SUCCESS';
			if (this.success) {
				this.fileName = 'Carga exitosa';
				this.dispatchEvent(
					showToast('success', 'pester', 'ÉXITO', 'Cuotas registradas exitósamente.')
				);
				// this.dispatchEvent(
				// 	new CustomEvent('close')
				// );
			}

			// this.errors = oResponse.errors;
		}).catch(errors => {
			this.success = false;
			console.log('errors', errors);
			this.errors = errors.body.message || errors.body.pageErrors.map(error => error.message).join('\r\n') || errors;
			console.log('this.errors', this.errors);
		}).finally(() => {
			this.showLoadingSpinner = false;
		});
	}
}