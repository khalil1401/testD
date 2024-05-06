import {LightningElement, api, track, wire} from 'lwc';
import getAPMList from '@salesforce/apex/ProfessionalTrackingController.getAPMList';
import getUser from '@salesforce/apex/ProfessionalTrackingController.getUser';
import {
	isValidDateRange,
	showToast,
	removeEmptyProperties
} from 'c/dan360Utils';

export default class ProfessionalTrackingModal extends LightningElement {
	@api openmodal = false;
	@api columns = [];
	@api tracking = [];
	@api title;
	@api actionname;

	selectedAPM;
	apmsList = [];
	isTransferAction = true;
	isShareAction = false;
	isUnsubscribe = false;
	reason = '';
	supervisores = [];
	usuarioSelected = '';
	supervisorSelected = '';
	reasonSelected = '';
	users;
	usersList;
	toUnsubscribe = [];
	isValidForm = true;
	isValidDateRange = false;
	deactivationDate;
	reactivationDate;
	reasonForUnsubscribe;
	comment;

	columnsToUnsubscribe = [
		{
			fieldName: 'VisitorLink',
			hideDefaultActions: true,
			label: 'Visitador',
			type: 'url',
			typeAttributes: {
				label: {
					fieldName: 'Visitador'
				},
				target: '_parent',
				tooltip: {
					fieldName: 'Visitor'
				}
			}
		},
		{
			fieldName: 'ProfessionalLink',
			hideDefaultActions: true,
			label: 'Profesional',
			type: 'url',
			typeAttributes: {
				label: {
					fieldName: 'Professional'
				},
				target: '_parent',
				tooltip: {
					fieldName: 'Professional'
				}
			}
		}
	];

	get isTransfer () {
		return this.isTransferAction;
	}

	get isShare () {
		return this.isShareAction;
	}

	get isTemporal () {
		return this.reasonSelected === 'Baja Temporal';
	}

	get optionsUsuarios () {
		return this.users;
	}

	renderedCallback () {
		if (!this.isComponentLoaded) {
			/* Add Click event listener to listen to window click to reset the picklist selection 
			to text view if context is out of sync*/
			window.addEventListener('click', (evt) => {
				this.handleWindowOnclick(evt);
			});
			this.isComponentLoaded = true;
		}

		if (this.actionname == 'compartir') {
			this.isTransferAction = false;
			this.isUnsubscribe = false;
			this.isShareAction = true;
		} else if (this.actionname == 'baja') {
			this.isTransferAction = false;
			this.isUnsubscribe = true;
			this.isShareAction = false;
		}
	}

	connectedCallback () {
		getAPMList()
			.then(data => {
				data.forEach(apm => {
					let apmObj = {label: apm.Name, value: apm.Id};

					this.apmsList.push(apmObj);
				});
			})
			.catch(error => console.log('error', error));
	}

	showModal () {
		this.openmodal = true;
	}

	closeModal () {
		this.openmodal = false;
		this.reasonSelected = '';

		this.dispatchEvent(
			new CustomEvent('canceltransfer')
		);
	}

	handleChange (event) {
		this.selectedAPM = event.detail;
	}

	doTransfer () {
		this.dispatchEvent(
			new CustomEvent('transfer',
				{
					detail: {
						apm: this.selectedAPM
					}
				}
			)
		)
	}

	doShare () {
		this.dispatchEvent(
			new CustomEvent('share',
				{
					detail: {
						apm: this.selectedAPM
					}
				}
			)
		)
	}

	doUnsubscribe () {
		this.toUnsubscribe = [];

		this.template
			.querySelectorAll('lightning-input')
			.forEach(element => {
				this.isValidForm = element.reportValidity();
				if (!this.isValidForm) {
					return;
				}
			});

		if (this.isValidForm || (this.isValidForm && this.reasonForUnsubscribe === 'Baja Temporal' && this.isValidDateRange)) {
			this.tracking.forEach(professional => {
				let p = JSON.parse(JSON.stringify(professional));
				this.toUnsubscribe.push({
					deactivationDate: this.deactivationDate,
					reactivationDate: this.reactivationDate,
					reasonForUnsubscribe: this.reasonForUnsubscribe,
					comment: this.comment,
					professional: p.ProfessionalLink.replace('/', ''),
					visitor: p.VisitorLink.replace('/', ''),
				});
			});
			// return;

			this.dispatchEvent(
				new CustomEvent('unsubscribe',
					{
						detail: {
							data: JSON.stringify(this.toUnsubscribe)
						}
					})
			);
		}
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

	handleFilterUserChange (event) {
		this.selectedAPM = event.detail;
	}

	handlePicklistValueSelected (event) {
		this.reasonForUnsubscribe = this.reasonSelected = event.detail.value;

		this.toUnsubscribe.forEach(elementToUnsubscribe => {
			removeEmptyProperties(elementToUnsubscribe);
		});
	}

	handleDateChange (event) {
		if (event.target.name.indexOf('Desactivacion') > -1) {
			this.deactivationDate = event.detail.value;
		} else if (event.target.name.indexOf('Reactivacion') > -1) {
			this.reactivationDate = event.detail.value;
		}

		if (this.deactivationDate && this.reactivationDate) {
			let response = isValidDateRange(this.deactivationDate, this.reactivationDate);

			if (!(this.isValidDateRange = response.getValidationResult())) {
				let r = response.getResponse();
				this.dispatchEvent(showToast(r.variant, r.mode, r.title, r.message));
			}
		}
	}

	handleCommentChange (event) {
		this.comment = event.detail.value;
	}
}