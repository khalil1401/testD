import {LightningElement, api} from 'lwc';

export default class LightningReferenceInputList extends LightningElement {
	@api record;
	@api fieldname;
	@api iconname;

	handleSelect (event) {
		event.preventDefault();
		this.dispatchEvent(new CustomEvent(
			"select",
			{
				detail: this.record.Id
			}
		));
	}
}