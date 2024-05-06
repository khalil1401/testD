import {LightningElement, api, track, wire} from 'lwc';
import getPicklistFieldsValues from '@salesforce/apex/PicklistInputTypeController.getPicklistFieldsValues';

export default class LightningPicklistInput extends LightningElement {
	@api label;
	@api name;
	@api sobjectname;
	@api picklistapiname;
	picklistEntries = [];

	connectedCallback () {
		getPicklistFieldsValues({
			sobjectName: this.sobjectname,
			picklistApiName: this.picklistapiname
		}).then(response => {
			this.picklistEntries = response;
		}).catch(error => {
			console.log('error getting picklists values', error);
		});
	}

	handleValueChange (event) {
		this.dispatchEvent(
			new CustomEvent(
				'picklistvalueselected',
				{
					detail: {
						name: this.name,
						value: event.target.value
					}
				})
		);
	}
}