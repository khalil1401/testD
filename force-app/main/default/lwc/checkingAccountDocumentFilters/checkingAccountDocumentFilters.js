import {api, LightningElement, track} from 'lwc';
import {showToast, cloneInputs} from 'c/dan360Utils';
import getFieldSet from '@salesforce/apex/CheckingAccountController.getFieldSet';

export default class CheckingAccountDocumentFilters extends LightningElement {
	// #region properties

	@track selectedRecord;
	@track records;
	@api disabledownload;
	@api filters = {};
	@api fieldName = 'Name';
	@api recordId;
	searchdisabled = true;
	date = new Date();
	startDate;
	endDate;
	maxDate;
	lblobjectName;
	error;
	renderCall = false;
	inputFields = [];
	/* @track  */cliente;

	connectedCallback () {
		this.initializeDates();
		this.renderFieldSet();
		console.log(this.recordId);
		console.log(this.cliente);
	}

	disabledSearch (value) {
		this.searchdisabled = !value;
	}

	initializeDates () {
		let date = new Date();
		this.maxDate = new Date(date.getFullYear(), date.getMonth(), date.getDate()).toISOString();
	}

	@api
	onDateRangeChange (event) {
		let validDateRange = true;
		let date = '';

		if (
			event.target.value != null ||
			event.target.value != undefined ||
			event.target.value != ''
		) {
			date = new Date(event.target.value).toISOString();
		}

		if (event.target.name == 'startDate') {
			this.startDate = event.target.value;
			event.target.name = 'Dan360_FechaDocumento__c >';
			event.target.value = (date == null || date == undefined || date == '') ? '' : date.split('T')[0];
		} else if (event.target.name == 'endDate') {
			this.endDate = event.target.value;
			event.target.name = 'Dan360_FechaDocumento__c <';
			event.target.value = (date == null || date == undefined || date == '') ? '' : date.split('T')[0];
		}

		if (this.startDate > this.endDate) {
			validDateRange = false;
			this.dispatchEvent(showToast('error', 'pester', 'ERROR', 'La fecha inicial no puede ser mayor a la fecha final'));
		}

		this.handleChange(event);

		return validDateRange;
	}

	@api
	handleSearch () {
		this.dispatchEvent(
			new CustomEvent(
				'searchdocuments',
				{
					detail: {
						filters: this.filters
					}
				})
		);
	}

	handleDownloadCsvFile () {
		this.dispatchEvent(
			new CustomEvent('downloadcsvfile')
		);
	}

	renderFieldSet () {
		getFieldSet({
			fieldSetName: 'Dan360_FiltrosCuentaCorriente'
		}).then(data => {
			let fields = JSON.parse(data);

			fields.forEach(element => {
				element.isReference = (element.type == 'reference');
				element.isPicklist = (element.type == 'picklist');
				element.isTextOrDate = (element.type == 'string' || element.type == 'date');

				if (element.type == 'date') {
					element.value = this.startDate;
					element.toClone = (element.fieldPath == 'startDate');
				}
				
				if (element.fieldPath == 'Dan360_NroComprobante__c') {
					element.label = 'Número de documento';
				}
			});

			cloneInputs(fields);

			this.inputFields = fields;

		}).catch(error => {
			console.log('error getting fieldset', error);
		});
	}

	formIsValid () {
		let success = true;
		this.template
			.querySelectorAll('lightning-input')
			.forEach(element => {
				success = element.reportValidity();

				if (!success) {
					return;
				}
			});

		this.disabledSearch(success);

		return success;
	}

	handleChange (event) {
		if (event.target.name.indexOf('Date') > -1) {
			this.onDateRangeChange(event)
		} else {
			this.addFilterProperty(event.target.name || event.detail.name, event.target.value || event.detail.value);
		}
	}

	addFilterProperty (key, value) {
		if(key == 'Dan360_Pedido__r.Dan360_UnidadNegocio__c'){
			key = 'Unidad_de_Negocio__c';
		}
		this.filters[key] = value;

		this.removeEmptyFiltersProperties();
		this.filtersStateFeedback();
		this.disabledSearch(Object.keys(this.filters).length > 0 && this.formIsValid());
	}

	removeEmptyFiltersProperties (element) {
		if (element) {
			delete this.filters[element];
		} else {
			Object.keys(this.filters)
				.forEach(key => {
					if (this.filters[key] == '' ||
						this.filters[key] == null ||
						this.filters[key] == undefined
					) {
						delete this.filters[key];
					}
				});
		}
	}

	handlePicklistValueSelected (event) {
		this.handleChange(event);
	}

	handleReferenceValueSelected (event) {
		this.handleChange(event);
	}

	handleReferenceValueRemoved (event) {
		this.handleChange(event);
	}

	filtersStateFeedback () {
		console.log('this.filters event');
		console.log(this.filters);
		this.dispatchEvent(
			new CustomEvent('filtersfeedback',
				{
					detail: {
						filters: this.filters
					}
				})
		);
	}
}