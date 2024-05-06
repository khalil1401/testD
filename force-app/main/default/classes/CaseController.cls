public with sharing class CaseController {
	@AuraEnabled
	public static List<WrapperProductComplaint> getInvoiceProducts(Id invoiceId, String objApiName) {
		List<WrapperProductComplaint> wrapperList = new List<WrapperProductComplaint>();

		if(objApiName == 'Dan360_Remito__c'){
			Decimal totalClaimed = 0;
			Decimal devuelto = 0;
			Map<Id, Decimal> claimedByProduct = new Map<Id, Decimal>();

			List<Dan360_ProductosDeReclamo__c> listClaimProduct = [
				SELECT Dan360_Producto__c, Dan360_CantidadDevolver__c
				FROM Dan360_ProductosDeReclamo__c
				WHERE Dan360_Reclamo__r.Dan360_Remito__c = : invoiceId AND Dan360_Reclamo__r.Dan360_Factura__c = NULL AND Dan360_Reclamo__r.Status <> 'Rechazado'
			];

			for(Dan360_ProductosDeReclamo__c claim : listClaimProduct){
				try {
					devuelto = Decimal.valueOf(claim.Dan360_CantidadDevolver__c);
				} catch(Exception e) {
					devuelto = 0;
				} finally {
					if (devuelto < 0) devuelto = 0;
				}

				totalClaimed = devuelto;

				if(claimedByProduct.containsKey(claim.Dan360_Producto__c)) {
					claimedByProduct.put(claim.Dan360_Producto__c, claimedByProduct.get(claim.Dan360_Producto__c) + totalClaimed);
				} else {
					claimedByProduct.put(claim.Dan360_Producto__c, totalClaimed);
				}
			}

			List<Dan360_ProductoDeRemito__c> listProductRemito = [
				SELECT Dan360_CantidadProducto__c, Dan360_NombreProducto__c, Dan360_Producto__c, Dan360_Producto__r.ProductCode
				FROM Dan360_ProductoDeRemito__c
				WHERE Dan360_Remito__c = : invoiceId
			];

			for(Dan360_ProductoDeRemito__c prodRemito : listProductRemito){
				totalClaimed = (claimedByProduct.containsKey(prodRemito.Dan360_Producto__c) ? claimedByProduct.get(prodRemito.Dan360_Producto__c) : 0);
				WrapperProductComplaint wrapper = new WrapperProductComplaint(
					prodRemito.Dan360_NombreProducto__c,
					prodRemito.Dan360_CantidadProducto__c,
					prodRemito.Dan360_Producto__c,
					prodRemito.Dan360_Producto__r.ProductCode,
					totalClaimed
				);
				wrapperList.add(wrapper);
			}
		}

		if(objApiName == 'Dan360_Factura__c'){
			Decimal totalClaimed = 0;
			Decimal faltante = 0;
			Decimal devuelto = 0;
			Map<Id, Decimal> claimedByProduct = new Map<Id, Decimal>();

			List<Dan360_ProductosDeReclamo__c> listClaimProduct = [
				SELECT Dan360_Producto__c, Dan360_CantidadProductoFaltante__c, Dan360_CantidadDevolver__c
				FROM Dan360_ProductosDeReclamo__c
				WHERE Dan360_Reclamo__r.Dan360_Factura__c = : invoiceId AND Dan360_Reclamo__r.Status <> 'Rechazado' AND Dan360_Reclamo__r.RecordType.Name != 'Diferencia de precios y descuentos'
			];

			for(Dan360_ProductosDeReclamo__c claim : listClaimProduct){
				try {
					faltante = Decimal.valueOf(claim.Dan360_CantidadProductoFaltante__c);
				} catch(Exception e) {
					faltante = 0;
				} finally {
					if (faltante < 0) faltante = 0;
				}

				try {
					devuelto = Decimal.valueOf(claim.Dan360_CantidadDevolver__c);
				} catch(Exception e) {
					devuelto = 0;
				} finally {
					if (devuelto < 0) devuelto = 0;
				}

				totalClaimed = faltante + devuelto;

				if(claimedByProduct.containsKey(claim.Dan360_Producto__c)) {
					claimedByProduct.put(claim.Dan360_Producto__c, claimedByProduct.get(claim.Dan360_Producto__c) + totalClaimed);
				} else {
					claimedByProduct.put(claim.Dan360_Producto__c, totalClaimed);
				}
			}

			List<Dan360_ProductoDeFactura__c> listProduct = [
				SELECT  Id,
						Dan360_CantidadProductoFacturado__c,
						Dan360_Descuento__c,
						Dan360_NombreProducto__c,
						Dan360_PrecioTotal__c,
						Dan360_PrecioUnitario__c,
						Dan360_ImporteCalculoUnitario__c,
						Dan360_Producto__c,
						Dan360_Producto__r.ProductCode,
						Dan360_IdLinea__c,
						Dan360_ImporteNetoGravado__c
				FROM Dan360_ProductoDeFactura__c
				WHERE Dan360_Factura__c = : invoiceId
			];

			for(Dan360_ProductoDeFactura__c prod : listProduct){
				totalClaimed = (claimedByProduct.containsKey(prod.Dan360_Producto__c) ? claimedByProduct.get(prod.Dan360_Producto__c) : 0);
				//Decimal totalPrice = prod.Dan360_PrecioUnitario__c * prod.Dan360_CantidadProductoFacturado__c;
				Decimal totalPrice = prod.Dan360_ImporteCalculoUnitario__c * prod.Dan360_CantidadProductoFacturado__c;
				WrapperProductComplaint wrapper = new WrapperProductComplaint(
					prod.Dan360_NombreProducto__c,
					prod.Dan360_CantidadProductoFacturado__c,
					//prod.Dan360_PrecioUnitario__c,
					prod.Dan360_ImporteCalculoUnitario__c,
					totalPrice,
					prod.Dan360_Producto__c,
					prod.Dan360_Producto__r.ProductCode,
					totalClaimed,
					prod.Dan360_IdLinea__c
				);
				wrapperList.add(wrapper);
			}
		}
		System.debug(wrapperList);
		return wrapperList;
	}

	@AuraEnabled
	public static String getFieldSet(String complaintType) {
		Danone360Helper helper = new Danone360Helper('Case');
		return helper.getFieldsFromFieldSet(complaintType);
	}

	@AuraEnabled
	public static Id getRecordTypeId(String typeOfComplaintApiName){
		Danone360Helper helper = new Danone360Helper('Case');
		Map<String, Id> recordTypes = helper.getRecordTypes();
		//System.debug(recordTypes);
		return recordTypes.get(typeOfComplaintApiName);
	}

	@AuraEnabled
	public static Id getProductComplaintRecordTypeId(String recordTypeName){
		Danone360Helper helper = new Danone360Helper('Dan360_ProductosDeReclamo__c');
		Map<String, Id> recordTypes = helper.getRecordTypes();
		System.debug(recordTypes);
		return recordTypes.get(recordTypeName);
	}

	@AuraEnabled
	public static Object getInvoiceOrDeliveryNoteData(Id id, String objApiName) {
		Object obj = null;

		if (objApiName == 'Dan360_Factura__c') {
			obj = [
				SELECT  Id,
						Name,
						Dan360_Pedido__c,
						Dan360_Pedido__r.AccountId,
						Dan360_Remito__c
				FROM    Dan360_Factura__c
				WHERE   Id = :id
			];
		} else if (objApiName == 'Dan360_Remito__c') {
			obj = [
				SELECT  Id,
						Name,
						Dan360_Pedido__c,
						Dan360_Sucursal__c
				FROM    Dan360_Remito__c
				WHERE   Id = :id
			];
		}

		return obj;
	}

	@AuraEnabled
	public static Object getFacturaByOrder(Id idOrder) {
		Object obj = null;
		System.debug('idOrder');
		System.debug(idOrder);
		obj = [
			SELECT  Id,
					Name,
					Dan360_Pedido__c
			FROM    Dan360_Factura__c
			WHERE   Dan360_Pedido__c = :idOrder
		];
		System.debug('obj');
		System.debug(obj);
		return obj;
	}

	@AuraEnabled
	public static ServerResponse saveComplaint(Case complaint, List<Dan360_ProductosDeReclamo__c> complaintProducts, Boolean complaintWithProducts){
		ServerResponse response = new ServerResponse();
		List<String> errors = new List<String>();
		Boolean productsInserted = false;
		// System.debug(complaintProducts);
		// for (Dan360_ProductosDeReclamo__c product : complaintProducts) {
		// 	System.debug('product.Precio_Cotizado__c');
		// 	System.debug(product.Precio_Cotizado__c);
		// }
		System.debug('complaint: '+ complaint);
		response.state = 'SUCCESS';
		if (complaintWithProducts && complaint != null && complaintProducts != null && !complaintProducts.isEmpty()) {
			Database.SaveResult result = Database.insert(complaint, true);

			if (result.isSuccess()) {
				response.data = complaint.Id;

				Id invoiceOrderId = complaint.Dan360_Pedido__c;

				Map<Id, String> orderItems = new Map<Id, String>();
				for (OrderItem orderItem : [
					SELECT  Id,
							Product2Id,
							Dan360_UnidadMedida__c
					FROM    OrderItem
					WHERE   OrderId = :invoiceOrderId
				]) {
					orderItems.put(orderItem.Product2Id, orderItem.Dan360_UnidadMedida__c);
				}

				for (Dan360_ProductosDeReclamo__c product : complaintProducts) {
					product.Dan360_Reclamo__c = complaint.Id;
					product.Dan360_UnidadMedidaProducto__c = orderItems.get(product.Dan360_Producto__c);
					System.debug('product');
					System.debug(product);
				}

				productsInserted = saveComplaintProducts(complaintProducts, errors);

				if (productsInserted) {
					response.message = 'Reclamo registrado exitósamente.';
				} else if (!productsInserted && !errors.isEmpty()) {
					response.state = 'ERROR';
					response.message = String.join(errors, ',');
				}
			} else {
				response.state = 'ERROR';
				for(Database.Error err : result.getErrors()) {
					response.message += err.getStatusCode();
					response.message += ': ' + err.getMessage();
					response.message += ' [' + err.getFields() + ']';
				}
			}
		} else if (!complaintWithProducts && complaint != null ) {
			Database.SaveResult result = Database.insert(complaint, true);

			if (result.isSuccess()) {
				response.data = complaint.Id;
				response.message = 'Reclamo registrado exitósamente.';
			} else {
				response.state = 'ERROR';
				for(Database.Error err : result.getErrors()) {
					response.message += err.getStatusCode();
					response.message += ': ' + err.getMessage();
					response.message += ' [' + err.getFields() + ']';
				}
			}
		} else {
			response.state = 'ERROR';
			response.message = (complaintProducts == null || complaintProducts.isEmpty()) ?
				'Debe elegir los productos a registrar en el reclamo.' :
				(complaint == null) ?
					'No fue posible generar reclamo por falta de información.' :
					'Verifique la información para generar reclamo.';
		}
		return response;
	}

	private static Boolean saveComplaintProducts(List<Dan360_ProductosDeReclamo__c> complaintProducts, List<String> errors){
		Boolean success = true;
		System.debug(complaintProducts);
		if (complaintProducts != null && !complaintProducts.isEmpty()) {
			Database.SaveResult[] results = Database.insert(complaintProducts, true);

			for (Database.SaveResult result : results) {
				success = result.isSuccess();
				System.debug('success <--->'+success);
				if (!success) {
					for(Database.Error err : result.getErrors()) {
						errors.add(err.getStatusCode() + ': ' + err.getMessage() +' [' + err.getFields() + ']');
					}
				}
			}
		}

		return success;
	}

	@AuraEnabled
	public static string getObjApiName(String objectId){
		String objectName ;
		String keyCode  = objectId.subString(0,3);

		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		for(Schema.SObjectType objectInstance : gd.values()){
			if(objectInstance.getDescribe().getKeyPrefix() == keyCode){
				//do your processing with the API name what you want
				objectName = objectInstance.getDescribe().getName();
				System.debug('Id is related to object: '+ objectInstance.getDescribe().getName());
				break;
			}
		}
		return objectName;
	}

	@AuraEnabled
	public static boolean isDevliveryFromNotCharge(Id id, String objApiName){
		System.debug('metodo nuevo');
		// SELECT Id, name, Dan360_Pedido__r.RecordType.Name  FROM Dan360_Remito__c where id = 'a0C03000002ks2BEAQ' order by CreatedDate desc
		// Pedido de Venta Directa
		List<Dan360_Remito__c> remito = [
			SELECT Id, name, Dan360_Pedido__r.RecordType.Name, Dan360_Pedido__r.RecordTypeId
			FROM Dan360_Remito__c
			WHERE Id =:id
		];
		Boolean isNotCharge = false;
		// List<Dan360_Factura__c> invoice = [
		// 		SELECT  Id, Name
		// 		FROM    Dan360_Factura__c
		// 		WHERE   Dan360_Remito__c = :id
		// 	];
		// if(invoice.size() == 0){
		// 	isNotCharge = true;
		// }
		System.debug('record type: '+remito[0].Dan360_Pedido__r.RecordType.Name);
		Id sinCargoRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Dan360_PedidoSinCargo').getRecordTypeId();
		if(!remito.isEmpty() && remito[0].Dan360_Pedido__r.RecordTypeId == sinCargoRecordTypeId){
			isNotCharge = true;
		}
		System.debug(remito);
		System.debug('is NOt charge: '+ isNotCharge);
		return isNotCharge;
		

	}

	public class WrapperProductComplaint{
		@AuraEnabled
		public string productName;

		@AuraEnabled
		public Decimal productQuantity;

		@AuraEnabled
		public Decimal productUnitPrice;

		@AuraEnabled
		public Decimal productTotalPrice;

		@AuraEnabled
		public String productCode;

		@AuraEnabled
		public Id productoId;

		@AuraEnabled
		public Decimal productQuantityClaimed;

		@AuraEnabled
		public String idLinea;

		@AuraEnabled
		public Id invoiceId;

		public WrapperProductComplaint(
			String productName,
			Decimal productQuantity,
			Decimal productUnitPrice,
			Decimal productTotalPrice,
			Id productoId
		) {
			this.productName = productName;
			this.productQuantity = productQuantity;
			this.productUnitPrice = productUnitPrice;
			this.productTotalPrice = productTotalPrice;
			this.productoId = productoId;
		}

		public WrapperProductComplaint(
			String productName,
			Decimal productQuantity,
			Decimal productUnitPrice,
			Decimal productTotalPrice,
			Id productoId,
			String productCode,
			Decimal productQuantityClaimed
		) {
			this.productName = productName;
			this.productQuantity = productQuantity;
			this.productUnitPrice = productUnitPrice;
			this.productTotalPrice = productTotalPrice;
			this.productoId = productoId;
			this.productCode = productCode;
			this.productQuantityClaimed = productQuantityClaimed;
		}

		public WrapperProductComplaint(
			String productName,
			Decimal productQuantity,
			Decimal productUnitPrice,
			Decimal productTotalPrice,
			Id productoId,
			String productCode,
			Decimal productQuantityClaimed,
			String idLinea
		) {
			this.productName = productName;
			this.productQuantity = productQuantity;
			this.productUnitPrice = productUnitPrice;
			this.productTotalPrice = productTotalPrice;
			this.productoId = productoId;
			this.productCode = productCode;
			this.productQuantityClaimed = productQuantityClaimed;
			this.idLinea = idLinea;
		}

		public WrapperProductComplaint(
			String productName,
			Decimal productQuantity,
			Id productoId
		) {
			this.productName = productName;
			this.productQuantity = productQuantity;
			this.productoId = productoId;
		}

		public WrapperProductComplaint(
			String productName,
			Decimal productQuantity,
			Id productoId,
			String productCode,
			Decimal productQuantityClaimed
		) {
			this.productName = productName;
			this.productQuantity = productQuantity;
			this.productoId = productoId;
			this.productCode = productCode;
			this.productQuantityClaimed = productQuantityClaimed;
		}

	}
}