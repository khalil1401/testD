import {LightningElement, api, track, wire} from 'lwc';
import {loadStyle} from "lightning/platformResourceLoader";
import WrappedHeaderTable from "@salesforce/resourceUrl/WrappedHeaderTable";
import getTracking from '@salesforce/apex/ProfessionalTrackingController.getTracking'
import transferProfessional from '@salesforce/apex/ProfessionalTrackingController.transferProfessional';
import shareProfessional from '@salesforce/apex/ProfessionalTrackingController.shareProfessional';
import unsubscribeProfessional from '@salesforce/apex/ProfessionalTrackingController.unsubscribeProfessional';
import {
	fillDataTable,
	showToast
} from 'c/dan360Utils';

export default class ProfessionalTrackingList extends LightningElement {
	@api filters = {};
	@api showmodal;
	@api modaltitle;
	@api action;

	isLoaded = false;
	hasResult = false;
	columns = [];
	data = [];
	professionalsSelected = [];
	trackingIds = [];

	toggle () {
		this.isLoaded = !this.isLoaded;
	}

	renderedCallback () {
		const dataTable = this.template.querySelector('.wrapped-header-datatable');
		if (dataTable) {
			dataTable.minColumnWidth = dataTable.minColumnWidth <= 50 ? 100 : dataTable.minColumnWidth;
			this.columnMinWidthSet = true;
		}

		if (!this.stylesLoaded) {
			Promise.all([loadStyle(this, WrappedHeaderTable)])
				.then(() => {
					this.stylesLoaded = true;
					this.loadData();
				})
				.catch((error) => {
					console.error(`Error loading custom styles ${JSON.stringify(error)}`);
				});
		}
	}

	@api
	loadData () {
		this.toggle();
		this.hasResult = false;

		let objFilters = {};

		if (this.filters) {
			objFilters = JSON.parse(JSON.stringify(this.filters));
		}

		getTracking({
			criterias: objFilters
		}).then(
			response => this.processTracking(response)
		).catch(
			error => this.onError(error)
		).finally(
			() => this.toggle()
		);
	}

	processTracking (response) {
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
				const processed = fillDataTable(data, true);
				this.columns = processed.columns;
				this.data = processed.data;
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
		console.log('error', error);
	}

	handleSelectedRows (event) {
		this.professionalsSelected = JSON.parse(JSON.stringify(event.detail.selectedRows));

		this.professionalsSelected.forEach(element => {
			this.trackingIds.push({
				Profesional__c: element.ProfessionalLink.replace('/', ''),
				Visitador__c: element.VisitorLink.replace('/', ''),
				Instituciones: element.InstitucionesIds
			});
		});

		this.dispatchEvent(
			new CustomEvent('recordsselected',
				{
					detail: {
						hasSelectedRecords: this.professionalsSelected && this.professionalsSelected.length > 0,
						numberOfSelectedRecords: this.professionalsSelected.length
					}
				})
		);
	}

	handleCloseTransferModal () {
		this.dispatchEvent(
			new CustomEvent('closetransfermodal')
		);
	}

	clearArrays () {
		this.professionalsSelected = [];
	}

	handleTransfer (event) {
		let apmSelected = JSON.parse(JSON.stringify(event.detail.apm)).value;
		console.log('@@this.trackingIds ' + this.trackingIds);

		transferProfessional({
			newAPM: apmSelected,
			professionalsSelected: this.trackingIds
		}).then(data => {
			if (data) {
				showToast('success', 'pester', 'ÉXITO', 'Profesionales transferidos exitósamente.');
				this.handleCloseTransferModal();
				this.loadData();
			} else {
				showToast('error', 'pester', 'ERROR', 'Profesionales no transferidos.');
			}
		}).catch(error => {
			console.log('error', error);
			showToast('error', 'pester', 'ERROR', `Profesionales no transferidos. ${error}`);
		});
	}

	handleShare (event) {
		let apmSelected = JSON.parse(JSON.stringify(event.detail.apm)).value;

		shareProfessional({
			newAPM: apmSelected,
			professionalsSelected: this.trackingIds
		}).then(data => {
			if (data) {
				showToast('success', 'pester', 'ÉXITO', 'Profesionales compartidos exitósamente.');
				this.handleCloseTransferModal();
				this.loadData();
			} else {
				showToast('error', 'pester', 'ERROR', 'Profesionales no compartidos.');
			}
		}).catch(error => {
			console.log('error', error);
			showToast('error', 'pester', 'ERROR', `Profesionales no compartidos. ${error}`);
		});
	}

	handleUnsubscribe (event) {
		let detail = JSON.parse(event.detail.data);

		unsubscribeProfessional({
			professionalsToUnsubscribe: detail
		}).then(data => {
			if (data) {
				this.dispatchEvent(showToast('success', 'pester', 'ÉXITO', 'Profesionales dado de baja exitósamente.'));
				this.handleCloseTransferModal();
				this.loadData();
			} else {
				this.dispatchEvent(showToast('error', 'pester', 'ERROR', 'Profesionales no dado de baja.'));
			}
		}).catch(error => {
			console.log('error', error);
			this.dispatchEvent(showToast('error', 'pester', 'ERROR', `Profesionales no dado de baja. ${error}`));
		});
	}
}