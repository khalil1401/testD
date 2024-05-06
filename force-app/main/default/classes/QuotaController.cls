public with sharing class QuotaController {
	@AuraEnabled
	public static ServerResponse save(String base64Data) {
		ServerResponse response = new ServerResponse();
		List<Dan360_Cuota__c> newDues = new List<Dan360_Cuota__c>();
		List<QuotaWrapper> validatedData = new List<QuotaWrapper>();
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<String> headerRow = new List<String>();
		List<String> fileRows = new List<String>();
		List<String> dataRows = new List<String>();
		Set<String> productsId = new Set<String>();
		Set<String> clientsId = new Set<String>();
		Map<String, Id> clientsSFId = new Map<String, Id>();
		Map<String, Id> productsSFId = new Map<String, Id>();
		Set<String> commercialChannel = new Set<String>();
		Set<String> distributionChannel = new Set<String>();
		Map<Id, List<Dan360_Cuota__c>> duesByDistributionChannel = new Map<Id, List<Dan360_Cuota__c>>();
		Map<Id, List<Dan360_Cuota__c>> duesByProductChannel = new Map<Id, List<Dan360_Cuota__c>>();
		Map<Id, List<Dan360_Cuota__c>> duesByCommercialChannel = new Map<Id, List<Dan360_Cuota__c>>();
		Map<Id, List<Dan360_Cuota__c>> duesByClient = new Map<Id, List<Dan360_Cuota__c>>();
		Boolean hasErrors = false;
		Integer invalidRecords = 0;
		String message;

		if (!String.isEmpty(base64Data)) {
			String data = JSON.deserializeUntyped(base64Data).toString();

			fileRows = data.split('\r\n');
			headerRow = fileRows[0].split(',');

			Boolean headerRowIsValid = validateHeaderRow(headerRow, message);

			if (headerRowIsValid) {
				dataRows = getDataRows(fileRows);

				if (dataRows != null && !dataRows.isEmpty()) {
					validatedData = validateCSVData(dataRows);

					if (validatedData != null && !validatedData.isEmpty()) {
						for (QuotaWrapper quota : validatedData) {
							if (quota.clientId != null) {
								clientsId.add(quota.clientId);
							}

							if (quota.productId != null) {
								productsId.add(quota.productId);
							}
						}

						for (Account account : [
							SELECT  Id,
									Id_SAP__c
							FROM    Account
							WHERE   Id_SAP__c IN :clientsId
						]) {
							clientsSFId.put(account.Id_SAP__c, account.Id);
						}

						for (Product2 product : [
							SELECT  Id,
									Id_SAP__c
							FROM    Product2
							WHERE   Id_SAP__c IN :productsId
						]){
							productsSFId.put(product.Id_SAP__c, product.Id);
						}

						for (QuotaWrapper q : validatedData) {
							System.debug('quota: ' + JSON.serialize(q));

							Dan360_Cuota__c quota = new Dan360_Cuota__c();

							if (!String.isEmpty(q.productId) &&
								productsSFId.containsKey(q.productId)
							) {
								quota.Dan360_Producto__c = productsSFId.get(q.productId);
							} else {
								quota.addError('SAP ID de producto no encontrado.');
							}

							if (!String.isEmpty(q.clientId) &&
								clientsSFId.containsKey(q.clientId)
							) {
								quota.Dan360_Cliente__c = clientsSFId.get(q.clientId);
							} else {
								quota.addError('SAP ID de cliente no encontrado.');
							}

							if (!String.isEmpty(q.commercialChannel)) {
								quota.Dan360_CanalComercial__c = q.commercialChannel;
							}

							if (!String.isEmpty(q.distributionChannel)) {
								quota.Dan360_CanalDistribucion__c = q.distributionChannel;
							}

							quota.Dan360_Cuota__c = Integer.valueOf(q.quota);
							quota.Dan360_Saldo__c = Integer.valueOf(q.balance);
							quota.Dan360_VigenciaDesde__c = Date.valueOf(q.initialDate);
							quota.Dan360_VigenciaHasta__c = Date.valueOf(q.finalDate);
							quota.Dan360_EstadoCuota__c = q.status;

							if (!q.isValid()) {
								if (q.messages != null && !q.messages.isEmpty()) {
									for (String m : q.messages) {
										quota.addError(m);
									}
								}
							}

							dues.add(quota);
						}

						System.debug('dues: ' + JSON.serialize(dues));

						List<Database.SaveResult> saveResults = Database.insert(dues);

						for (Database.SaveResult result : saveResults) {
							if (!hasErrors) {
								hasErrors = !result.isSuccess();
							}

							if (!result.isSuccess()) {
								for (Database.Error error : result.getErrors()) {
									response.addError(String.valueOf(result.getId()), error.getMessage());
								}
							}
						}
					}
				}
			}else {
				response.state = 'ERROR';
				response.data = null;
				response.message = 'CSV no válido.';
				hasErrors = true;
			}
		} else {
			response.state = 'ERROR';
			response.data = null;
			response.message = 'CSV no válido.';
			hasErrors = true;
		}
		if (!hasErrors) {
			response.state = hasErrors ? 'ERROR' : 'SUCCESS';
			response.data = dues;			
		}

		return response;
	}

	private static Boolean validateHeaderRow(List<String> headerRow, String message) {
		Integer columnIndex = 0;
		Boolean isValid = true;
		message = 'Cabecero no válido [Esperado: {0}, ';

		if (headerRow[0] != 'Producto') {
			isValid = false;
			message = String.format(message, new String[] { 'Producto', headerRow[0] });
		}

		if (isValid && headerRow[1] != 'Cuota') {
			isValid = false;
			message = String.format(message, new String[] { 'Producto', headerRow[1] });
		}

		if (isValid && headerRow[2] != 'Cliente') {
			isValid = false;
			message = String.format(message, new String[] { 'Cliente', headerRow[2] });
		}

		if (isValid && headerRow[3] != 'Canal Comercial') {
			isValid = false;
			message = String.format(message, new String[] { 'Canal Comercial', headerRow[3] });
		}

		if (isValid && headerRow[4] != 'Canal de distribución') {
			isValid = false;
			message = String.format(message, new String[] { 'Canal de distribución', headerRow[4] });
		}

		if (isValid && headerRow[5] != 'Saldo') {
			isValid = false;
			message = String.format(message, new String[] { 'Saldo', headerRow[5] });
		}

		if (isValid && headerRow[6] != 'Vigencia desde') {
			isValid = false;
			message = String.format(message, new String[] { 'Vigencia desde', headerRow[6] });
		}

		if (isValid && headerRow[7] != 'Vigencia hasta') {
			isValid = false;
			message = String.format(message, new String[] { 'Vigencia hasta', headerRow[7] });
		}

		if (isValid && headerRow[8] != 'Estado de cuota') {
			isValid = false;
			message = String.format(message, new String[] { 'Vigencia hasta', headerRow[8] });
		}

		return isValid;
	}

	private static List<String> getDataRows(List<String> fileRows) {
		List<String> dataRows = new List<String>();
		Slice s = new Slice(fileRows);

		for (Object row : s.slice(1)) {
			dataRows.add(String.valueOf(row));
		}

		return dataRows;
	}

	private static List<QuotaWrapper> validateCSVData(List<String> dataRows) {
		List<QuotaWrapper> validatedData = new List<QuotaWrapper>();
		Integer rowIndex = 1;

		for (String dataRow : dataRows) {
			QuotaWrapper wrapper = new QuotaWrapper();
			List<String> dataColumns = dataRow.split(',');

			// Product
			if (!String.isEmpty(dataColumns[0])) {
				wrapper.productId = dataColumns[0];
			} else {
				wrapper.setValidationResult(false);
				wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Debe agregar producto.');
			}

			// Quota
			if (!String.isEmpty(dataColumns[1])) {
				wrapper.quota = dataColumns[1];
			} else {
				wrapper.setValidationResult(false);
				wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Debe agregar cuota.');
			}

			// By distribution channel
			if (!String.isEmpty(dataColumns[4])) {
				wrapper.distributionChannel = dataColumns[4];

				if (!String.isEmpty(dataColumns[2]) &&
					!String.isEmpty(dataColumns[3])
				) {
					wrapper.setValidationResult(false);
					wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Cuota por canal de distribución no puede contener cliente y canal comercial.');
				} else {
					// Quota by client
					if (!String.isEmpty(dataColumns[2])) {
						wrapper.clientId = dataColumns[2];
					}

					// Quota by commercial channel
					if (!String.isEmpty(dataColumns[3])) {
						wrapper.commercialChannel = dataColumns[3];
					}
				}
			// By client || commercial channel
			} else if (String.isEmpty(dataColumns[4]) &&
				(!String.isEmpty(dataColumns[2]) || !String.isEmpty(dataColumns[3]))
			) {
				if (!String.isEmpty(dataColumns[2]) && !String.isEmpty(dataColumns[3])) {
					wrapper.setValidationResult(false);
					wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] La cuota sólo debe contener cliente o canal comercial.');
				} else {
					if (!String.isEmpty(dataColumns[2])) {
						wrapper.clientId = dataColumns[2];
					}

					if (!String.isEmpty(dataColumns[3])) {
						wrapper.commercialChannel = dataColumns[3];
					}
				}
			// Else not apply, quota by product
			} /*else {
				wrapper.setValidationResult(false);
				wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Cuota no válida.');
			}*/

			// Balance
			if (!String.isEmpty(dataColumns[5])) {
				wrapper.balance = dataColumns[5];
			} else {
				wrapper.setValidationResult(false);
				wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Debe agregar saldo.');
			}

			// Initial Date
			if (!String.isEmpty(dataColumns[6])) {
				wrapper.initialDate = dataColumns[6];
			} else {
				wrapper.setValidationResult(false);
				wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Debe agregar fecha inicial de vigencia.');
			}

			// Final Date
			if (!String.isEmpty(dataColumns[7])) {
				wrapper.finalDate = dataColumns[7];
			} else {
				wrapper.setValidationResult(false);
				wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Debe agregar fecha final de vigencia.');
			}

			// Quota Status
			if (!String.isEmpty(dataColumns[8])) {
				wrapper.status = dataColumns[8];
			} else {
				wrapper.setValidationResult(false);
				wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Debe agregar un estado de cuota.');
			}

			validatedData.add(wrapper);
		}

		return validatedData;
	}

	public class QuotaWrapper {
		@AuraEnabled
		public String productId;

		@AuraEnabled
		public String quota;

		@AuraEnabled
		public String clientId;

		@AuraEnabled
		public String commercialChannel;

		@AuraEnabled
		public String distributionChannel;

		@AuraEnabled
		public String balance;

		@AuraEnabled
		public String initialDate;

		@AuraEnabled
		public String finalDate;

		@AuraEnabled
		public String status;

		@AuraEnabled
		public Boolean recordIsValid;

		@AuraEnabled
		public List<String> messages;

		public QuotaWrapper() {
			this.messages = new List<String>();
			this.recordIsValid = true;
		}

		public void addMessage(String message) {
			this.messages.add(message);
		}

		public void setValidationResult(Boolean isValid) {
			this.recordIsValid = isValid;
		}

		public Boolean isValid() {
			return this.recordIsValid;
		}
	}
}