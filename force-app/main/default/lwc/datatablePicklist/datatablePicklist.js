/* eslint-disable @lwc/lwc/no-api-reassignments */
import {LightningElement, api} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import CustomDataTableResource from '@salesforce/resourceUrl/CustomDataTable';

export default class DatatablePicklist extends LightningElement {
	@api label;
	@api placeholder;
	@api options;
	@api value;
	@api context;
	@api variant;
	@api name;
	showPicklist = false;
	picklistValueChanged = false;

	//capture the picklist change and fire a valuechange event with details payload.
	handleChange (event) {
		event.preventDefault();
		this.picklistValueChanged = true;
		this.value = event.detail.value;
		this.showPicklist = false;
		console.log('handleClick_context', this.context);
		console.log('handleClick_value', this.value);
		console.log('handleClick_label', this.label);
		console.log('handleClick_name', this.name);
		// this.dispatchCustomEvent('valuechange', this.context, this.value, this.label, this.name);
		this.dispatchCustomEvent('valuechange', this.value, this.label, this.name);
	}

	//loads the custom CSS for picklist custom type on lightning datatable
	renderedCallback () {
		Promise.all([
			loadStyle(this, CustomDataTableResource),
		]).then(() => {});
		if (!this.guid) {
			this.guid = this.template.querySelector('.picklistBlock').getAttribute('id');
			/* Register the event with this component as event payload. 
			Used to identify the window click event and if click is outside the current context of picklist, 
			set the dom to show the text and not the combobox */
			this.dispatchEvent(
				new CustomEvent('itemregister', {
					bubbles: true,
					composed: true,
					detail: {
						callbacks: {
							reset: this.reset,
						},
						template: this.template,
						guid: this.guid,
						name: 'c-datatable-picklist'
					}
				})
			);
		}
	}

	//show picklist combobox if window click is on the same context, set to text view if outside the context
	reset = (context) => {
		console.log('context', JSON.stringify(context));
		if (this.context !== context) {
			console.log('context', JSON.stringify(context));
			this.showPicklist = false;
		}
	}

	//Fire edit event on to allow to modify the picklist selection.
	handleClick (event) {
		event.preventDefault();
		event.stopPropagation();
		this.showPicklist = true;
		// this.dispatchCustomEvent('edit');
		console.log('handleClick_context', this.context);
		console.log('handleClick_value', this.value);
		console.log('handleClick_label', this.label);
		console.log('handleClick_name', this.name);
		// this.dispatchCustomEvent('edit', this.context, this.value, this.label, this.name);
		this.dispatchCustomEvent('edit', this.value, this.label, this.name);
	}

	//Blur event fired to set the combobox visibility to false.
	handleBlur (event) {
		event.preventDefault();
		this.showPicklist = false;
		console.log('picklistValueChanged', this.picklistValueChanged);
		if (!this.picklistValueChanged) { // this.dispatchCustomEvent('customtblur');
			console.log('handleBlur_context', this.context);
			console.log('handleBlur_value', this.value);
			console.log('handleBlur_label', this.label);
			console.log('handleBlur_name', this.name);
			// this.dispatchCustomEvent('customtblur', this.context, this.value, this.label, this.name);
			this.dispatchCustomEvent('customtblur', this.value, this.label, this.name);
		}
	}

	dispatchCustomEvent (eventName, context, value, label, name) {
		this.dispatchEvent(
			new CustomEvent(eventName,
				{
					composed: true,
					bubbles: true,
					cancelable: true,
					detail: {
						data: {
							context: context,
							value: value,
							label: label,
							name: name
						}
					}
				}
			)
		);
	}
}