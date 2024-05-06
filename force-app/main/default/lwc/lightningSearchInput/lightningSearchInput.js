import {LightningElement, track, api} from 'lwc';

export default class LightningSearchInput extends LightningElement {
	@track searchKey;
	@api label;

	connectedCallback () {
	}

	handleChange (event) {
		const searchKey = event.target.value;

		this.dispatchEvent(new CustomEvent(
			'change',
			{
				detail: searchKey
			}
		));
	}
}