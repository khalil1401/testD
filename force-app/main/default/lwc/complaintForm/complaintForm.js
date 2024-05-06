import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import getFieldSet from '@salesforce/apex/CaseController.getFieldSet';
import saveComplaint from '@salesforce/apex/CaseController.saveComplaint';
import getInvoiceOrDeliveryNoteData from '@salesforce/apex/CaseController.getInvoiceOrDeliveryNoteData';

export default class ComplaintForm extends LightningElement {
	@api objectApiName;
	@api complainttypename;
	@api recordtypeid;
	@api invoiceid;
	@api title;
	@api objapiname;
	@track showSpinner = false;
	@track prectioTotal;

	showProductTable = true;
	fieldSetName;
	lblobjectName;
	title = '';
	formValues = {};
	inputFieldAPIs = [];
	products = [];
	@track isDisabled = false; 

	//load the record edit form with fields from fieldset.
	connectedCallback () {
		this.onLoading(true);
		let fieldSetName = '';
		if (this.objapiname == 'Dan360_Remito__c') {
			this.formValues.Dan360_Remito__c = this.invoiceid;
		} else if (this.objapiname == 'Dan360_Factura__c') {
			this.formValues.Dan360_Factura__c = this.invoiceid;
		}

		switch (this.complainttypename) {
			case 'Dan360_Devoluciones':
				fieldSetName = 'Dan360_ReclamoDevolucion';
				break;
			case 'Dan360_DiferenciaPreciosDescuentos':
				fieldSetName = 'Dan360_ReclamoDiferenciaPreciosYDesc';
				break;
			case 'Dan360_ReclamoPorFaltantes':
				fieldSetName = 'Dan360_ReclamoFaltante';
				break;
			case 'Dan360_DevolucionesPedidosSinCargo':
				fieldSetName = 'Dan360_ReclamoDevolucion';
				break;
			case 'Dan360_Otros':
				fieldSetName = 'Dan360_ReclamoOtros';
				this.showProductTable = false;
				break;
		}

		getInvoiceOrDeliveryNoteData({
			id: this.invoiceid,
			objApiName: this.objapiname
		}).then(data => {
			this.fillFormValues(data[0]);
			this.fillFieldSet(fieldSetName);
		}).catch(error => {
			console.log('error', error);
		}).finally(() => {
			this.onLoading(false);
		});
	}

	fillFieldSet (fieldSetName) {
		getFieldSet({
			complaintType: fieldSetName
		}).then(data => {
			let objStr = JSON.parse(data);

			this.inputFieldAPIs = JSON.parse(Object.values(objStr)[1]);
			this.inputFieldAPIs
				.forEach(element => {
					element.disabled = (element.label == 'Remito' || element.label == 'Factura' || element.label == 'Sucursal');
					element.hide = (this.objapiname == 'Dan360_Factura__c' && element.label == 'Remito') || (this.objapiname == 'Dan360_Remito__c' && element.label == 'Factura');
					element.value = this.formValues[element.fieldPath] || '';
				});

			this.error = undefined;
		}).catch(error => {
			this.error = error;
			this.lblobjectName = 'Case ' + this.error;
		});
	}

	fillFormValues (data) {
		Object.keys(data)
			.forEach(key => {
				if (key != 'Id') {
					if (key == 'Dan360_Pedido__r') {
						this.formValues['Dan360_Sucursal__c'] = data[key].AccountId;
						this.formValues['AccountId'] = data[key].AccountId;
					} else {
						this.formValues[key] = data[key] || '';
					}
				}
			});
	}

	onSave () {
		this.formValues.RecordTypeId = this.recordtypeid;

		if (this.showProductTable) {
			if (this.validateRequiredFields() && this.productsFormIsValid() && this.products.length > 0) {
				// switch (this.complainttypename) {
				// 	case 'Dan360_DevolucionesPedidosSinCargo':
				// 		this.formValues['Dan360_Cantidad_a_Devolver__c'] = this.products.map(item => item.description).join(', ').substring(0,225);
				// 		break;
				// 	case 'Dan360_Devoluciones':
				// 		this.formValues['Dan360_Cantidad_a_Devolver__c'] = this.products.map(item => item.description).join(', ').substring(0,225);
				// 		break;
				// 	case 'Dan360_DiferenciaPreciosDescuentos':
				// 		this.formValues['Dan360_DiferenciaDePrecio__c'] = this.products.map(item => item.description).join(', ').substring(0,225);
				// 		break;
				// 	case 'Dan360_ReclamoPorFaltantes':
				// 		this.formValues['Dan360_ProductosYCantidadesFaltantes__c'] = this.products.map(item => item.description).join(', ').substring(0,225);
				// 		break;
				// }

				let complaintProducts = this.getComplaintProducts();

				console.log('complaintProducts', complaintProducts);
				console.log('formValues',JSON.stringify(this.formValues));

				// return;
				this.isDisabled = true;
				saveComplaint({
					complaint: this.formValues,
					complaintProducts: complaintProducts,
					complaintWithProducts: true
				}).then(response => {
					let toastEvent;
					if (response.state == 'SUCCESS') {
						this.dispatchEvent(new CustomEvent(
							'success',
							{
								detail: response.data
							})
						);

						toastEvent = new ShowToastEvent({
							title: 'EXITOSO',
							message: response.message,
							variant: 'success'
						});
					} else {
						toastEvent = new ShowToastEvent({
							title: 'ERROR',
							message: response.message,
							variant: 'error'
						});
					}

					this.dispatchEvent(toastEvent);
				}).catch(error => {
					this.isDisabled = false;
					console.log('error', error);
				});
			}
		} else if (this.validateRequiredFields()) {
			saveComplaint({
				complaint: this.formValues,
				complaintProducts: [],
				complaintWithProducts: false
			}).then(response => {
				let toastEvent;
				if (response.state == 'SUCCESS') {
					this.dispatchEvent(new CustomEvent(
						'success',
						{
							detail: response.data
						})
					);

					toastEvent = new ShowToastEvent({
						title: 'EXITOSO',
						message: response.message,
						variant: 'success'
					});
				} else {
					toastEvent = new ShowToastEvent({
						title: 'ERROR',
						message: response.message,
						variant: 'error'
					});
				}

				this.dispatchEvent(toastEvent);
			}).catch(error => {
				console.log('error', error);
			});
		}
	}

	validateRequiredFields () {
		let success = true;

		this.template
			.querySelectorAll('lightning-input-field')
			.forEach(element => {
				if (success && element.reportValidity()) {
					this.formValues[element.fieldName] = element.value;
				} else {
					success = element.reportValidity();
				}
			});

		return success;
	}

	productsFormIsValid () {
		const productsTable = this.template.querySelector('c-complaint-product-table');
		let isValid = productsTable.reportValidity();

		this.products = isValid ? productsTable.sendListToParent() : [];

		return isValid;
	}

	getComplaintProducts (complaintId) {
		let complaintProducts = [];
		let isReturn = false;
		let isPricesAndDiscountsDiff = false;
		let isMissingProduct = false;

		isReturn = (this.complainttypename == 'Dan360_Devoluciones' || this.complainttypename == 'Dan360_DevolucionesPedidosSinCargo');
		isPricesAndDiscountsDiff = (this.complainttypename == 'Dan360_DiferenciaPreciosDescuentos');
		isMissingProduct = (this.complainttypename == 'Dan360_ReclamoPorFaltantes');

		console.log('products', this.products);

		this.products.forEach(item => {
			console.log('item', item);
			let product = {};

			if (isReturn) {
				product.Dan360_CantidadDevolver__c = item.quantity;
				product.Dan360_PrecioTotal__c = item.totalPrice;
				product.Dan360_IDLineaReferenciaSAP__c = item.idLinea;
			} else if (isPricesAndDiscountsDiff) {
				product.Precio_Cotizado__c = parseFloat(item.priceCotized);
				console.log('typeof');
				console.log(typeof product.Precio_Cotizado__c);
				product.Dan360_DiferenciaPrecio__c = item.Difprice;
				product.Diferencia_Precio_Unitario__c = item.price - item.priceCotized;
				product.Dan360_Precio__c = item.price;
				product.Dan360_PrecioTotal__c = item.totalPrice;
				product.Dan360_CantidadDevolver__c = item.quantity.toString();
				product.Dan360_IDLineaReferenciaSAP__c = item.idLinea;
			} else if (isMissingProduct) {
				product.Diferencia_Precio_Unitario__c = item.price;
				product.Dan360_CantidadProductoFaltante__c = item.quantity;
				product.Dan360_PrecioTotal__c = item.totalPrice;
				product.Dan360_IDLineaReferenciaSAP__c = item.idLinea;
			}

			product.Dan360_Producto__c = item.productId;
			product.Dan360_Reclamo__c = null;
			product.RecordTypeId = item.recordType;
			complaintProducts.push(product);
		});
		console.log('complaintProducts');
		console.log(complaintProducts);
		console.log('products', this.products);
		// return false;
		return complaintProducts;
	}

	onLoading (show) {
		this.dispatchEvent(
			new CustomEvent(
				'loading',
				{
					detail: show
				}
			)
		);
	}

	closeAction () {
		this.dispatchEvent(
			new CustomEvent('cancel')
		);
	}

	get showTotal () {
		return (this.complainttypename != 'Dan360_Otros');
	}

	totalPriceCalc (event) {
		this.prectioTotal = event.detail;
	}
}