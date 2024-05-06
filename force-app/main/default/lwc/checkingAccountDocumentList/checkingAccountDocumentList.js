import {LightningElement, api} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import WrappedHeaderTable from '@salesforce/resourceUrl/WrappedHeaderTable';
import getCheckingAccountDocuments from '@salesforce/apex/CheckingAccountController.getCheckingAccountDocuments';
import {NavigationMixin} from 'lightning/navigation';
import {
	showToast,
	formatDateddMMShortyyyy,
	exportToCSVFile,
	fillDataTable
} from 'c/dan360Utils';

export default class CheckingAccountDocumentList extends NavigationMixin(LightningElement) {
	@api account;
	@api startdate;
	@api enddate;
	@api documentnumber;
	@api cansearch = false;
	@api isinitialload;
	@api filters;

	hasResult = false;
	isLoaded = false;
	columns = [];
	data = [];
	stylesLoaded = false;

	toggle () {
		this.isLoaded = !this.isLoaded;
	}

	renderedCallback () {
		const dataTable = this.template.querySelector('.wrapped-header-datatable');
		if (dataTable) {
			dataTable.minColumnWidth = dataTable.minColumnWidth <= 50 ? 125 : dataTable.minColumnWidth;
			console.log('dataTable');
			console.log(dataTable);
			this.columnMinWidthSet = true;
		}

		if (!this.stylesLoaded) {
			Promise.all([loadStyle(this, WrappedHeaderTable)])
				.then(() => {
					this.stylesLoaded = true;
					this.getCheckingAccountReport();
				})
				.catch((error) => {
					console.error(`Error loading custom styles ${JSON.stringify(error)}`);
				});
		}
	}

	@api
	getCheckingAccountReport () {
		if (this.account) {
			this.toggle();
			this.hasResult = false;
			this.data = [];
			let objFilters = {};

			if (this.filters) {
				objFilters = JSON.parse(JSON.stringify(this.filters)).filters;
				console.log(objFilters);
			}

			objFilters['Dan360_Cliente__c'] = this.account;

			getCheckingAccountDocuments({criteria: objFilters})
				.then(response => this.onSuccess(response))
				.catch(error => this.onError(error))
				.finally(() => this.toggle());
		}
	}

	@api
	downloadCsvFile () {
		let columnsArr = [];
		let d = new Date();
		let date = new Date(d.getFullYear(), d.getMonth(), d.getDate()).toISOString();
		let fileName = 'Reporte ' + formatDateddMMShortyyyy(date.split('T')[0]);

		this.columns.forEach(function (column) {
			console.log('column');
			console.log(column);
			console.log(column.label !== 'Documento');
			if (column.type !== 'action') {
				if (column.label == 'Documento' || column.label == 'Semáforo') {
					return;
				}
				columnsArr.push({
					fieldName: column.fieldName,
					label: column.label
				});
			}
		});


		console.log('columns', this.columns);

		exportToCSVFile(columnsArr, this.data, fileName);
	}

	onSuccess (response) {
		let oResponse = response;

		if (oResponse.state == 'SUCCESS') {
			const data = oResponse.data;

			this.hasResult = Object.keys(data.GridData).length > 0;

			if (!this.hasResult) {
				this.dispatchEvent(
					showToast(
						'warning',
						'pester',
						'SIN RESULTADOS',
						oResponse.message
					)
				);
			} else {
				const processed = fillDataTable(data);
				this.columns = processed.columns;
				console.log(this.columns);
				this.columns.push({
					label: 'Documento',
					fieldName: 'PDFFileLink',
					type: 'url',
					hideDefaultActions: true,
					include: false,
					cellAttributes: {
						iconName: 'doctype:pdf',
					},
					typeAttributes: {
						label: {
							fieldName: 'PDFFile'
						},
						target: '_parent',
						tooltip: {
							fieldName: 'PDFFile'
						}
					}
				});

				this.data = processed.data;
				this.data.forEach(item => {
					item['PDFFile'] = 'Ver PDF';

					if (window.location.href.indexOf('/lightning/r/') > -1) {
						console.log('item', item);
						item['PDFFileLink'] = '/apex/checkingAccountPDF?invoice=' + item.Id
							+ '&docType=' + item.Dan360_TipoDeDocumento__c
							+ '&docNumber=' + item.Dan360_NroComprobante__c;
					} else {
						item['PDFFileLink'] = '/s/cuentacorrientepdf?invoice=' + item.Id
							+ '&docType=' + item.Dan360_TipoDeDocumento__c
							+ '&docNumber=' + item.Dan360_NroComprobante__c;
					}
				});
			}

			this.dispatchEvent(
				new CustomEvent(
					'dataloaded',
					{
						detail: {
							hasData: this.hasResult
						}
					})
			);
		} else if (oResponse.state == 'ERROR') {
			this.dispatchEvent(
				showToast(
					'error',
					'pester',
					'ERROR',
					'Ocurrió un error durante la búsqueda'
				)
			);
		}
	}

	onError (error) {
		this.hasResult = false;

		console.log('error getting data', error);
		this.dispatchEvent(
			showToast(
				'error',
				'pester',
				'ERROR',
				`Ocurrió un error mientras intentaba consultar los documentos de cuenta corriente.`
			)
		);
	}
}