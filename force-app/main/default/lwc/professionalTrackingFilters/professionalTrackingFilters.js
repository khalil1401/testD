import {LightningElement, api, track, wire} from 'lwc';
import getRecordTypeId from '@salesforce/apex/ProfessionalTrackingController.getRecordTypeId';
import getUser from '@salesforce/apex/ProfessionalTrackingController.getUser';
import getSupervisores from '@salesforce/apex/ProfessionalTrackingController.getSupervisores';

export default class ProfessionalTrackingFilters extends LightningElement {
	@track filters = {};
	@api hasSelectedRecords = false;
	@api numberOfSelectedRecords = 0;
	@api enablesupervisorfilter;

	isLoaded = false;
	inputFields = [];
	recordTypeIds = {};
	showSpinner;
	supervisores = [];
	usuarioSelected = '';
	supervisorSelected = '';
	users;
	usersList;
	professionalRecordTypeIds = [];
	institutionRecordTypeIds = [];

	toggle () {
		this.isLoaded = !this.isLoaded;
	}

	get disabledActions () {
		return !this.hasSelectedRecords;
	}

	connectedCallback () {
		getRecordTypeId({
			sobjectname: 'Account',
			apiname: null
		}).then(response => {
			Object.keys(response).forEach(key => {
				if (key === 'Profesional_de_la_Salud') {
					this.professionalRecordTypeIds.push(response[key]);
				}

				if (key === 'Otro_Profesional') {
					this.professionalRecordTypeIds.push(response[key]);
				}

				if (key === 'Institucion') {
					this.institutionRecordTypeIds.push(response[key]);
				}
			});
		}).catch(error => {
			console.log('error', error);
		});
	}

	handleChange (event) {
		this.addFilterProperty(event.target.name || event.detail.name, event.target.value || event.detail.value);
	}

	addFilterProperty (key, value) {
		this.filters[key] = value;

		this.removeEmptyFiltersProperties();
		this.filtersStateFeedback();
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

	handleReferenceValueSelected (event) {
		this.handleChange(event);
	}

	handleReferenceValueRemoved (event) {
		this.handleChange(event);
	}

	filtersStateFeedback () {
		this.dispatchEvent(
			new CustomEvent('filtersfeedback',
				{
					detail: {
						filters: this.filters,
						numberOfSelectedRecords: this.numberOfSelectedRecords
					}
				})
		);
	}

	handleTransferOrShare (event) {
		let title;
		let action;

		if (event.target.name === 'transfer') {
			action = 'transferir';
		} else if (event.target.name === 'share') {
			action = 'compartir';
		} else if (event.target.name === 'unsubscribe') {
			action = 'baja';
		}

		title = action === 'baja' ? `Baja de profesionales` : `Profesionales a ${action}`;

		this.dispatchEvent(
			new CustomEvent('transferorshareprofessional',
				{
					detail: {
						showModal: true,
						title: title,
						action: action
					}
				})
		);
	}

	@wire(getSupervisores)
	WiredSupervisores ({error, data}) {
		if (data) {
			if (data.length > 1) {
				this.supervisores.push({label: 'Todos', value: ''});
			}
			for (var i in data) {
				this.supervisores = [...this.supervisores, {label: data[i].Name, value: data[i].Id}];
			}
			this.error = undefined;
		} else if (error) {
			console.log('ERROR: ' + error);
			this.error = error;
		}
	}
	get optionsSupervisores () {
		return this.supervisores;
	}

	handleFilterSupervisorChange (event) {
		this.supervisorSelected = event.detail.value;
	}


	@wire(getUser, {
		supervisor: "$supervisorSelected"
	})
	WiredUsers ({error, data}) {
		if (data) {
			this.users = [];
			this.usersList = [];
			this.users.push({label: 'Todos', value: ''});
			for (var i in data) {
				this.users = [...this.users, {label: data[i].Name, value: data[i].ContactId}];
				this.usersList.push(data[i].ContactId);
			}
			this.error = undefined;
		} else if (error) {
			console.log('ERROR: ' + error);
			this.error = error;
		}
	}

	get optionsUsuarios () {
		return this.users;
	}

	handleFilterUserChange (event) {
		this.showSpinner = true;
		this.usuarioSelected = event.detail.value;
		this.addFilterProperty('Visitador__c', this.usuarioSelected);
	}
}