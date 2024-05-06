import {LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import {loadStyle} from "lightning/platformResourceLoader";
import getInvoiceProducts from '@salesforce/apex/CaseController.getInvoiceProducts';

import getInvoiceOrDeliveryNoteData from '@salesforce/apex/CaseController.getInvoiceOrDeliveryNoteData'; 
import getFacturaByOrder from '@salesforce/apex/CaseController.getFacturaByOrder'; 

import WrappedHeaderTable from "@salesforce/resourceUrl/WrappedHeaderTable";
import getProductComplaintRecordTypeId from '@salesforce/apex/CaseController.getProductComplaintRecordTypeId';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

// #region const
const colsDevoluciones = [
	{
		label: 'Código de producto',
		fieldName: 'productCode',
		type: 'text',
		hideDefaultActions: true
	},
	{
		label: 'Nombre',
		fieldName: 'productName',
		type: 'text',
		hideDefaultActions: true
	},
	{
		label: 'Cantidad facturado',
		fieldName: 'productQuantity',
		type: 'number',
		hideDefaultActions: true
	},
	{
		label: 'Cantidad a devolver',
		fieldName: 'quantity',
		type: 'number',
		hideDefaultActions: true,
		editable: 'true',
		cellAttributes:{
			class:'quantity-class'
		}
	},
	{
		label: 'Total de devolución',
		fieldName: 'totalReturn',
		type: 'currency',
		hideDefaultActions: true,
	}
];

const colsDiferencia = [
	{
		label: 'Código de producto',
		fieldName: 'productCode',
		type: 'text',
		hideDefaultActions: true
	},
	{
		label: 'Nombre',
		fieldName: 'productName',
		type: 'text',
		hideDefaultActions: true
	},
	{
		label: 'Precio unitario',
		fieldName: 'productUnitPrice',
		type: 'number',
		hideDefaultActions: true,
	},
	{
		label: 'Cantidad facturada',
		fieldName: 'productQuantity',
		type: 'number',
		hideDefaultActions: true
	},
	{
		label: 'Precio total facturado',
		fieldName: 'productTotalPrice',
		type: 'number',
		hideDefaultActions: true
	},
	{
		label: 'Precio unitario cotizado',
		fieldName: 'precioInformado',
		type: 'number',
		hideDefaultActions: true,
		editable: 'true',
		cellAttributes:{
			class:'precioInformado-class'
		}
	},
	{
		label: 'Diferencia total de precio',
		fieldName: 'Difprecio',
		type: 'number',
		hideDefaultActions: true
	}
];

const colsFaltantes = [
	{
		label: 'Código de producto',
		fieldName: 'productCode',
		type: 'text',
		hideDefaultActions: true
	},
	{
		label: 'Nombre',
		fieldName: 'productName',
		type: 'text',
		hideDefaultActions: true
	},
	{
		label: 'Cantidad facturado',
		fieldName: 'productQuantity',
		type: 'number',
		hideDefaultActions: true
	},
	{
		label: 'Cantidad faltante',
		fieldName: 'quantity',
		type: 'number',
		hideDefaultActions: true,
		editable: 'true',
		cellAttributes:{
			class:'quantity-class'
		}
	},
	{
		label: 'Total en faltante',
		fieldName: 'totalMissing',
		type: 'currency',
		hideDefaultActions: true,
	}
];
// #endregion

export default class ComplaintProductTable extends LightningElement {
	@track columns;
	@track productList = [];
	@track productListRemito = [];
	@track productListFactura = [];
	@api facturaid;
	@api complainttypename;
	@api objapiname;
	error;
	showData = false;
	fieldToComplete;
	totalPrice = 0;
	stylesLoaded = false;
	recordTypeId = '';

	@api
	reportValidity () {
		let isValid = true;
		let items = this.template.querySelector('lightning-datatable').getSelectedRows();
		if (!items || items.length == 0) {
			isValid = false;
		} else {
			items.forEach(item => {
				if (this.complainttypename == 'Dan360_Devoluciones' ||
					this.complainttypename == 'Dan360_DevolucionesPedidosSinCargo' ||
					this.complainttypename == 'Dan360_ReclamoPorFaltantes'
				) {
					if (!item.quantity || item.quantity <= 0) {
						isValid = false;
					}
				} else if (this.complainttypename == 'Dan360_DiferenciaPreciosDescuentos') {
					if (!item.precioInformado || item.precioInformado <= 0) {
						isValid = false;
					}
				}
			});
		}
		if (!isValid) {
			const evt = new ShowToastEvent({
				title: 'Error en tabla de productos',
				message: 'Debe indicar al menos un producto y cumplimentar la informacion necesaria.',
				variant: 'error'
			});
			this.dispatchEvent(evt);
		}
		return isValid;
	}

	@api
	sendListToParent () {
		let items = this.template.querySelector('lightning-datatable').getSelectedRows();
		let products = [];

		items.forEach(item => {
			let description = '';
			let totalPrice = 0;
			let priceCotized = 0;
			if (this.complainttypename == 'Dan360_Devoluciones' ||
				this.complainttypename == 'Dan360_DevolucionesPedidosSinCargo' ||
				this.complainttypename == 'Dan360_ReclamoPorFaltantes'
			) {
				description = item.quantity + ' unidades de ' + item.productName;
				totalPrice = item.quantity * item.productUnitPrice;
			} else {
				description = '$' + item.Difprecio + ' del producto: ' + item.productName;
				totalPrice = item.productTotalPrice;
				priceCotized = item.precioInformado;
			}

			products.push({
				productId: item.productoId,
				description: description,
				quantity: item.quantity || item.productQuantity,
				Difprice: item.Difprecio,
				totalPrice: totalPrice,
				price: item.productUnitPrice,
				recordType: this.recordTypeId,
				idLinea: item.idLinea,
				priceCotized : priceCotized
			});
		});

		console.log('send list to parent[products]:', products);

		return products;
	}

	renderedCallback () {
		const someDataTable = this.template.querySelector('.wrapped-header-datatable');
		if (someDataTable) {
			someDataTable.minColumnWidth = someDataTable.minColumnWidth <= 50 ? 100 : someDataTable.minColumnWidth;
			this.columnMinWidthSet = true;
		}

		if (!this.stylesLoaded) {
			Promise.all([loadStyle(this, WrappedHeaderTable)])
				.then(() => {
					this.stylesLoaded = true;
				})
				.catch((error) => {
					console.error("Error loading custom styles");
				});
		}
	}

	connectedCallback () {
		let recordTypeName = '';
		getInvoiceProducts({invoiceId: this.facturaid, objApiName: this.objapiname})
			.then(data => {
				console.log('data');
				console.log(data);
				this.productList = data;
			}).catch(error => {
				console.log(error);
				this.error = error;
			})

		if (this.objapiname == 'Dan360_Factura__c') {
			getInvoiceOrDeliveryNoteData({id: this.facturaid, objApiName: 'Dan360_Factura__c'})
			.then(data => {
				getInvoiceProducts({invoiceId: data[0].Dan360_Remito__c, objApiName: 'Dan360_Remito__c'})
				.then(data => {
					this.productListRemito = data;
				}).catch(error => {
					console.log(error);
					this.error = error;
				})
			}).catch(error => {
				console.log(error);
				this.error = error;
			})
		} else if (this.objapiname == 'Dan360_Remito__c') {
			getInvoiceOrDeliveryNoteData({id: this.facturaid, objApiName: 'Dan360_Remito__c'})
			.then(data => {
				getFacturaByOrder({idOrder: data[0].Dan360_Pedido__c})
				.then(data => {
					if(data){
						getInvoiceProducts({invoiceId: data[0].Id, objApiName: 'Dan360_Factura__c'})
						.then(data => {
							this.productListFactura = data;
						}).catch(error => {
							console.log(error);
							this.error = error;
						})
					}
				}).catch(error => {
					console.log(error);
					this.error = error;
				})
			}).catch(error => {
				console.log(error);
				this.error = error;
			})
		}

		switch (this.complainttypename) {
			case 'Dan360_Devoluciones':
				this.columns = colsDevoluciones;
				this.fieldToComplete = 'Cantidad a devolver';
				recordTypeName = 'Dan360_ProductoReclamoDevolucion';
				break;
			case 'Dan360_DiferenciaPreciosDescuentos':
				this.columns = colsDiferencia;
				this.fieldToComplete = 'Precio informado por el cliente';
				recordTypeName = 'Dan360_ProductoReclamoDiferenciaPrecios';
				break;
			case 'Dan360_ReclamoPorFaltantes':
				this.columns = colsFaltantes;
				this.fieldToComplete = 'Cantidad faltante';
				recordTypeName = 'Dan360_ProductoReclamoFaltantes';
				break;
			case 'Dan360_DevolucionesPedidosSinCargo':
				this.columns = colsDevoluciones;
				this.fieldToComplete = 'Cantidad a devolver';
				recordTypeName = 'Dan360_ProductoReclamoDevolucion';
				break;
		}

		getProductComplaintRecordTypeId({recordTypeName: recordTypeName})
			.then(data => {
				this.recordTypeId = data;
			}).catch(error => {
				console.log(error)
			});
	}

	guardarValoresDevolucion (event) {
		let productos = event.detail.draftValues;
		productos.forEach(producto => {
			let productoToSend = this.productList.find(elem => elem.productoId == producto.productoId);
			let productoToSendFactura; 
			let productoToSendRemito; 
			if (this.objapiname == 'Dan360_Factura__c') {
				productoToSendFactura = this.productList.find(elem => elem.productoId == producto.productoId); 
				productoToSendRemito = this.productListRemito.find(elem => elem.productoId == producto.productoId); 
			} else if (this.objapiname == 'Dan360_Remito__c') {
				productoToSendRemito = this.productList.find(elem => elem.productoId == producto.productoId);
				if(this.productListFactura.length > 0){
					productoToSendFactura = this.productListFactura.find(elem => elem.productoId == producto.productoId);
				}
				
			}
			let pendiente = (productoToSend.productQuantity - productoToSend.productQuantityClaimed);
			if (pendiente < 0) pendiente = 0;
			if (producto.quantity && producto.quantity <= pendiente && producto.quantity >= 0) {
				productoToSend.quantity = producto.quantity;
				productoToSend.totalReturn = producto.quantity * productoToSend.productUnitPrice;
				this.calcularValorTotal();
			} else {
				let mess = 'Ingreso una cantidad no permitida ==> ';
				mess += 'Facturada: ' + productoToSend.productQuantity.toString();
				mess += ' -- Reclamada: ' + productoToSend.productQuantityClaimed.toString();
				mess += ' -- Pendiente: ' + pendiente.toString();
				const evt = new ShowToastEvent({
					title: 'Error',
					message: mess,
					variant: 'error'
				});
				this.dispatchEvent(evt);
			}
		});
		
	}

	guardarValoresDiferenciaPrecios (event) {
		let productos = event.detail.draftValues;

		productos.forEach(producto => {
			let productoToSend = this.productList.find(elem => elem.productoId == producto.productoId);

			if (producto.precioInformado >= 0 && producto.precioInformado <= productoToSend.productUnitPrice) {
				productoToSend.precioInformado = producto.precioInformado;
				productoToSend.Difprecio = productoToSend.productTotalPrice - (productoToSend.precioInformado * productoToSend.productQuantity);
				this.calcularValorTotal();
			} else {
				const evt = new ShowToastEvent({
					title: 'Error',
					message: 'Ingreso un precio incorrecto',
					variant: 'error'
				});
				this.dispatchEvent(evt);
			}
		});
	}

	guardarValoresFaltantes (event) {
		let productos = event.detail.draftValues;
		productos.forEach(producto => {
			let productoToSend = this.productList.find(elem => elem.productoId == producto.productoId);
			let pendiente = (productoToSend.productQuantity - productoToSend.productQuantityClaimed);
			if (pendiente < 0) pendiente = 0;
			if (producto.quantity && producto.quantity >= 0 && producto.quantity <= pendiente) {
				productoToSend.quantity = producto.quantity;
				productoToSend.totalMissing = producto.quantity * productoToSend.productUnitPrice;
				this.calcularValorTotal();
			} else {
				let mess = 'Ingreso una cantidad no permitida ==> ';
				mess += 'Facturada: ' + productoToSend.productQuantity.toString();
				mess += ' -- Reclamada: ' + productoToSend.productQuantityClaimed.toString();
				mess += ' -- Pendiente: ' + pendiente.toString();
				const evt = new ShowToastEvent({
					title: 'Error',
					message: mess,
					variant: 'error'
				});
				this.dispatchEvent(evt);
			}
		});
	}

	guardarValores (event) {
		console.log('this.complainttypename');
		console.log(this.complainttypename);
		console.log('sección comentada');
		switch (this.complainttypename) {
			case 'Dan360_Devoluciones':
				this.guardarValoresDevolucion(event);
				this.columns = [...colsDevoluciones];
				break;
			case 'Dan360_DiferenciaPreciosDescuentos':
				
				this.guardarValoresDiferenciaPrecios(event);
				this.columns = [...colsDiferencia];
				break;
			case 'Dan360_ReclamoPorFaltantes':
				this.guardarValoresFaltantes(event);
				this.columns = [...colsFaltantes];
				break;
			 case 'Dan360_DevolucionesPedidosSinCargo':
			 	this.guardarValoresDevolucion(event);
			 	this.columns = [...colsDevoluciones];
		 	break;
		}
	}

	calcularValorTotal () {
		let precio = 0;
		let items = this.template.querySelector('lightning-datatable').getSelectedRows();
		if (items.length > 0) {
			let style = document.createElement('style');
			items.forEach(element => {
				let aElement = this.complainttypename == 'Dan360_DiferenciaPreciosDescuentos' ? element.precioInformado : element.quantity; 
				let nameClass = this.complainttypename == 'Dan360_DiferenciaPreciosDescuentos' ? 'precioInformado-class' : 'quantity-class'; 
		
				if (aElement == undefined){
					style.innerText = '.slds-table tbody tr.slds-is-selected>td.'+nameClass+'{background-color: #FFFFFF !important;}';
					this.template.querySelector('lightning-datatable').appendChild(style);
				} else {
					style.innerText = '.slds-table tbody tr.slds-is-selected>td.'+nameClass+'{background-color: #F3F3F3 !important;}';
					this.template.querySelector('lightning-datatable').appendChild(style);
				}
			});
		}

		let key;
		switch (this.complainttypename) {
			case 'Dan360_Devoluciones':
				key = 'totalReturn';
				break;
			case 'Dan360_DiferenciaPreciosDescuentos':
				key = 'Difprecio';
				break;
			case 'Dan360_ReclamoPorFaltantes':
				key = 'totalMissing';
				break;
			case 'Dan360_DevolucionesPedidosSinCargo':
				key = 'totalReturn';
				break;
		}

		items.forEach(element => {
			if (typeof element[key] != undefined) {
				precio += element[key];
			} else {
				precio += 0;
			}
		});

		this.totalPrice = precio;

		this.dispatchEvent(
			new CustomEvent(
				'totalprice',
				{
					detail: this.totalPrice
				}
			)
		);
	}
}