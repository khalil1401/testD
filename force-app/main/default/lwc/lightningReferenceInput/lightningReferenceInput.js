import {LightningElement, api, track, wire} from 'lwc';
import find from '@salesforce/apex/ReferenceInputTypeController.find';
import getIconInfo from '@salesforce/apex/ReferenceInputTypeController.getIconInfo';
import findRemitoSucursal from '@salesforce/apex/ReferenceInputTypeController.findRemitoSucursal';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import search from '@salesforce/apex/Lookup.search';
export default class LightningReferenceInput extends LightningElement {
	@track records;
	@track error;
	@track selectedRecord;
	@api index;
	@api relationshipfield;
	@api iconname;
	@api sobjectname;
	@api referenceapiname;
	@api label;
	@api searchfield = ['Name'];
	@api searchfield2 = ['Dan360_Remito__c'];
	@api searchfield3 = ['BillingStreet'];
	@api recordtypeid;
	@api fieldname = '';
	@api cliente;

	renderedCallback () {
	}

	connectedCallback () {
		getIconInfo({
			sobjectName: this.sobjectname
		}).then(iconname => {
			this.iconname = iconname;
		}).catch(error => {
			console.log('error getting icons', error);
		});
	}

	handleChange (event) {
		console.log('entrando...', event.detail.value);
		const searchKey = event.detail.value;
		let params = {
			objectName: this.sobjectname,
			fields: this.searchfield,
			keyword: searchKey,
		};
		if (searchKey && searchKey.length > 2) {
			if (this.recordtypeid) {
				params.objectName = this.sobjectname;
				params.fields = this.searchfield;
				params.keyword = searchKey;
				params.recordTypeId = this.recordtypeid;
			} else {
				params.objectName = this.sobjectname;
				if(params.objectName == 'Dan360_Remito__c'){
					params.fields = this.searchfield2;
				}
				else if (params.objectName == 'Account'){
					params.fields = this.searchfield3;
				}
				else{
					params.fields = this.searchfield;
				}
				params.keyword = searchKey;
				params.recordId = this.cliente;
			}

			console.log('params...', params);
			if (params.objectName == 'Dan360_Remito__c' || params.objectName == 'Account') {
				findRemitoSucursal(params)
				.then(result=>{
					this.records = result;

					console.log('result', result);

					for (let i = 0; i < this.records.length; i++) {
						const rec = this.records[i];
						this.records[i].Name = rec[params.fields];
					}

					this.error = undefined;
				}).catch(error => {
					this.error = error;
					this.records = undefined;
					console.log('error', error);
				});
			} else{
				find(params)
				.then(result => {
					this.records = result;

					console.log('result', result);

					for (let i = 0; i < this.records.length; i++) {
						const rec = this.records[i];
						this.records[i].Name = rec[params.fields];
					}

					this.error = undefined;
				}).catch(error => {
					this.error = error;
					this.records = undefined;
					console.log('error', error);
				});
			}
		}
	}

	handleSelect (event) {
		event.preventDefault();
		const selectedRecordId = event.detail;

		this.selectedRecord = this.records.find(record => record.Id === selectedRecordId);
		this.dispatchEvent(new CustomEvent(
			"referenceselected",
			{
				detail: {
					name: this.referenceapiname,
					value: this.selectedRecord.Id
				}
			}
		));
	}

	handleRemove (event) {
		event.preventDefault();
		this.selectedRecord = undefined;
		this.records = undefined;
		this.error = undefined;
		this.dispatchEvent(new CustomEvent(
			"referenceremoved",
			{
				detail: {
					name: this.referenceapiname,
					value: ''
				}
			}
		));
	}
}