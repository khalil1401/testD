public without sharing class PrescriptionDataLoaderController {
	@AuraEnabled
	public static ServerResponse saveData(String dataFile){
		ServerResponse response = new ServerResponse();
		List<VisMed_Receta__c> newPrescriptions = new List<VisMed_Receta__c>();
		List<VisMed_Receta__c> prescriptionsToUpdate = new List<VisMed_Receta__c>();
		List<PrescriptionWrapper> validatedData = new List<PrescriptionWrapper>();
		List<String> headerRow = new List<String>();
		List<String> fileRows = new List<String>();
		List<String> dataRows = new List<String>();
		Set<String> professionalsId = new Set<String>();
		Set<String> productsId = new Set<String>();
		Set<String> quartersId = new Set<String>();
		Map<Id, List<VisMed_Receta__c>> prescriptionsByProfessional = new Map<Id, List<VisMed_Receta__c>>();
		Map<Id, List<VisMed_Receta__c>> prescriptionsForIdAssignation = new Map<Id, List<VisMed_Receta__c>>();
		Boolean hasErrors = false;
		Integer invalidRecords = 0;
		String message;

		System.debug('dataFile');
		System.debug(dataFile);

		if (!String.isEmpty(dataFile)) {
			String data = JSON.deserializeUntyped(dataFile).toString();

			fileRows = data.split('\r\n');
			headerRow = fileRows[0].split(',');

			Boolean headerRowValidationResult = validateHeaderRow(headerRow, message);

			if (headerRowValidationResult) {
				dataRows = getDataRows(fileRows);

				if (!dataRows.isEmpty() && dataRows.size() > 0) {
					validatedData = validateCSVData(dataRows);

					for (PrescriptionWrapper record : validatedData) {
						if (record.isValid()) {
							professionalsId.add(record.contactId);
							productsId.add(record.productId);
							quartersId.add(record.quarterId);
						} else {
							invalidRecords++;
						}
					}

					if (invalidRecords == 0) {
						for (VisMed_Receta__c prescription : [
							SELECT  Profesional_de_la_receta__c,
									Producto__c,
									Cuatrimestre__c,
									Cantidad__c
							FROM    VisMed_Receta__c
							WHERE   Profesional_de_la_receta__c IN :professionalsId
						]) {
							if (!prescriptionsByProfessional.containsKey(prescription.Profesional_de_la_receta__c)) {
								prescriptionsByProfessional.put(prescription.Profesional_de_la_receta__c, new List<VisMed_Receta__c>());
							}

							prescriptionsByProfessional.get(prescription.Profesional_de_la_receta__c).add(prescription);
						}

						for (PrescriptionWrapper record : validatedData) {
							if (prescriptionsByProfessional.containsKey(record.contactId)) {
								List<VisMed_Receta__c> professionalsPrescriptions = prescriptionsByProfessional.get(record.contactId);

								for (VisMed_Receta__c existingPrescription : professionalsPrescriptions) {
									if (record.productId == existingPrescription.Producto__c &&
										record.quarterId == existingPrescription.Cuatrimestre__c
									) {
										existingPrescription.Cantidad__c = existingPrescription.Cantidad__c != null ?
											existingPrescription.Cantidad__c + Integer.valueOf(record.quantity) :
											Integer.valueOf(record.quantity);

										prescriptionsToUpdate.add(existingPrescription);
									} else {
										VisMed_Receta__c newPrescription = new VisMed_Receta__c();
										newPrescription.Profesional_de_la_receta__c = record.contactId;
										newPrescription.Producto__c = record.productId;
										newPrescription.Cuatrimestre__c = record.quarterId;
										newPrescription.Cantidad__c = Integer.valueOf(record.quantity);

										newPrescriptions.add(newPrescription);
									}
								}
							} else {
								VisMed_Receta__c newPrescription = new VisMed_Receta__c();
								newPrescription.Profesional_de_la_receta__c = record.contactId;
								newPrescription.Producto__c = record.productId;
								newPrescription.Cuatrimestre__c = record.quarterId;
								newPrescription.Cantidad__c = Integer.valueOf(record.quantity);

								newPrescriptions.add(newPrescription);
							}
						}
					}
				}
			} else {
				response.state = 'ERROR';
				response.message = message;

				return response;
			}
		} else {
			response.state = 'ERROR';
			response.message = 'Ocurrió un error en la carga del archivo.';

			return response;
		}

		System.debug(newPrescriptions);
		update prescriptionsToUpdate;
		insert newPrescriptions;

		response.state = (invalidRecords == 0) ? 'SUCCESS' : 'ERROR';
		response.data = validatedData;

		return response;
	}

	 private static Boolean validateHeaderRow(List<String> headerRow, String message) {
		Integer columnIndex = 0;
		Boolean isValid = true;
		message = 'Cabecero no válido [Esperado: {0}, Actual: {1}]';

		if (headerRow[0] != 'Profesional') {
			isValid = false;
			message = String.format(message, new String[] { 'Profesional', headerRow[0] });
		}

		if (isValid && headerRow[1] != 'Cuatrimestre') {
			isValid = false;
			message = String.format(message, new String[] { 'Cuatrimestre', headerRow[0] });
		}

		if (isValid && headerRow[2] != 'Producto') {
			isValid = false;
			message = String.format(message, new String[] { 'Producto', headerRow[0] });
		}

		if (isValid && headerRow[3] != 'Cantidad') {
			isValid = false;
			message = String.format(message, new String[] { 'Cantidad', headerRow[0] });
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

	private static List<PrescriptionWrapper> validateCSVData(List<String> dataRows) {
		List<PrescriptionWrapper> validatedData = new List<PrescriptionWrapper>();
		Integer rowIndex = 1;

		for (String dataRow : dataRows) {
			PrescriptionWrapper wrapper = new PrescriptionWrapper();
			List<String> dataColumns = dataRow.split(',');

			if (dataColumns[0] != null) {
				wrapper.contactId = dataColumns[0];
			} else {
				wrapper.setValidationResult(false);
				wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Debe agregar profesional.');
			}

			if (dataColumns[1] != null) {
				wrapper.quarterId = dataColumns[1];
			} else {
				wrapper.setValidationResult(false);
				wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Debe agregar cuatrimestre.');
			}

			if (dataColumns[2] != null) {
				wrapper.productId = dataColumns[2];
			} else {
				wrapper.setValidationResult(false);
				wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Debe agregar producto.');
			}

			if (dataColumns[3] != null) {
				String quantity = dataColumns[3];

				if (quantity.isNumeric()) {
					wrapper.quantity = dataColumns[3];
				} else {
					wrapper.quantity = '';
					wrapper.setValidationResult(false);
					wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + ']' + String.format('Dato no válido, se esperaba valor númerico. [Actual: {0}]', new String[] { quantity }));
				}
			} else {
				wrapper.setValidationResult(false);
				wrapper.addMessage('[Ln: ' + String.valueOf(rowIndex) + '] Debe agregar cantidad.');
			}

			validatedData.add(wrapper);
		}

		return validatedData;
	}

	public class PrescriptionWrapper {
		@AuraEnabled
		public String contactId;

		@AuraEnabled
		public String quarterId;

		@AuraEnabled
		public String productId;

		@AuraEnabled
		public String quantity;

		@AuraEnabled
		public Boolean recordIsValid;

		@AuraEnabled
		public List<String> messages;

		public PrescriptionWrapper() {
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