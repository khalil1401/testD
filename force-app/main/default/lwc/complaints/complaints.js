import {LightningElement, api, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getRecordTypeId from '@salesforce/apex/CaseController.getRecordTypeId';
import getObjApiName from '@salesforce/apex/CaseController.getObjApiName';

export default class Complaints extends NavigationMixin(LightningElement) {
	@track chooseTypeOfComplaint = true;
	@track isReturnComplaint = false;
	@track isDiffPriceOrDiscountComplaint = false;
	@track isMissingComplaint = false;
	@track isOtherTypeOfComplaint = false;
	@track invoiceId;
	@track recordTypeId;
	@track title = 'Seleccione el tipo de reclamo';
	@api recordId;
	@api objApiName;
	complaintSelected = false;
	complaintTypeName;
	showSpinnner = false;

	handleContinue () {
		this.chooseTypeOfComplaint = false;
	}

	switchComplaintTemplate (event) {
		this.chooseTypeOfComplaint = false;
		this.invoiceId = this.recordId;
		this.complaintSelected = event.detail != null && event.detail != '';
		this.complaintTypeName = event.detail;

		switch (this.complaintTypeName) {
			case 'Dan360_Devoluciones':
				this.title = 'Reclamo por devolución';
				break;
			case 'Dan360_DiferenciaPreciosDescuentos':
				this.title = 'Reclamo por diferencia de precios y descuentos';
				break;
			case 'Dan360_ReclamoPorFaltantes':
				this.title = 'Reclamo por faltantes';
				break;
			case 'Dan360_DevolucionesPedidosSinCargo':
				this.title = 'Reclamo por devolución';
				break;
			case 'Dan360_Otros':
				this.title = 'Reclamos de servicios';
				break;
			default:
				break;
		}

		getRecordTypeId({
			typeOfComplaintApiName: this.complaintTypeName
		}).then(data => {
			this.recordTypeId = data;
		}).catch(error => {
			console.log(error);
		});
	}

	handleShowSpinner (event) {
		this.showSpinnner = event.detail;
	}

	closeAction (event) {
		this.dispatchEvent(new CustomEvent('close'));
	}

	redirectToComplaint (event) {
		window.location.replace('/' + event.detail);
	}

	get renderType () {
		if (this.objApiName != null &&
			this.chooseTypeOfComplaint == true
		) {
			return true;
		}
		return false;
	}
}