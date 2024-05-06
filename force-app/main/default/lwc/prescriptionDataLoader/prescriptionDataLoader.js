import {api, LightningElement, track} from 'lwc';
import saveData from '@salesforce/apex/PrescriptionDataLoaderController.saveData';
import {
	formatBytes,
	showToast
} from 'c/dan360Utils';

const columns = [
	{
		label: '',
		fieldName: ''
	},
	{
		label: '',
		fieldName: ''
	},
	{
		label: '',
		fieldName: ''
	},
	{
		label: '',
		fieldName: ''
	},
	{
		label: '',
		fieldName: ''
	},
	{
		label: '',
		fieldName: ''
	},
];

export default class StockDataLoader extends LightningElement {
	@track isDisabled = true;
	@track error;
	@track columns = columns;
	@track data;
	@track fileName;
	@track showSpinner = false;
	@api recordId;
	MAX_FILE_SIZE = 1500000;
	uploadedFiles = [];
	file;
	fileReader;
	fileContent;
	errors;
	isSuccess;

	get acceptedFormats () {
		return ['.csv'];
	}

	showSpinner () {
		this.showSpinner = !this.showSpinner;
	}

	connectedCallback () {
	}

	handleUpload (event) {
		this.uploadedFiles = event.detail.files;
		this.file = this.uploadedFiles[0];

		if (this.uploadedFiles != undefined && this.uploadedFiles.length > 0) {
			this.fileName = `Tamaño: [${formatBytes(this.file.size)}]`;
			this.uploadHelper(false);
		} else {
			this.fileName = 'Seleccione un archivo para ser procesado.';
		}
	}

	uploadHelper () {
		this.file = this.uploadedFiles[0];

		if (this.file.size > this.MAX_FILE_SIZE) {
			this.dispatchEvent(
				showToast(
					'error',
					'pester',
					'ERROR',
					`El tamaño de archivo sobrepasa el límite permitido. [${formatBytes(this.MAX_FILE_SIZE)}]`
				)
			);

			return;
		}

		// this.showSpinner();

		this.fileReader = new FileReader();
		this.fileReader.onloadend = (() => {
			this.fileContent = this.fileReader.result;
			console.log('this.fileContent', this.fileContent);
			this.save();
		});

		this.fileReader.readAsText(this.file);
	}

	save () {
		this.showSpinner = true;

		console.log('content', this.fileContent);
		console.log('content', JSON.stringify(this.fileContent));

		saveData({
			dataFile: JSON.stringify(this.fileContent)
		})
			.then(response => {
				console.log('response', response);

				let oResponse = response;
				console.log('response', response);

				this.isSuccess = oResponse.state == 'SUCCESS';

				if (this.isSuccess) {
					this.dispatchEvent(
						showToast('success', 'pester', 'ÉXITO', 'Stock registrado exitósamente.')
					);

					this.dispatchEvent(
						new CustomEvent('success')
					);
				} else {
					this.dispatchEvent(
						showToast(
							'error',
							'pester',
							'ERROR',
							oResponse.message
						)
					);
				}
			})
			.catch(errors => {
				this.isSuccess = false;
				console.log('errors', errors);
				this.errors = errors.body.message || errors.body.pageErrors.map(error => error.message).join('\r\n') || errors;
				console.log('this.errors', this.errors);
			})
			.finally(() => this.showSpinner = false)
	}
}