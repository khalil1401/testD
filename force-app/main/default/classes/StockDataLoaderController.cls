public without sharing class StockDataLoaderController {
	@AuraEnabled
	public static ServerResponse saveData(String base64Data) {
		ServerResponse response = new ServerResponse();
		List<Stock_x_Ciclo__c> newCycleStocks = new List<Stock_x_Ciclo__c>();
		List<Stock_x_MM__c> newMMStocks = new List<Stock_x_MM__c>();
		// Mantener una lista de claves únicas de APM__c y Ciclo__c
		List<String> uniqueKeys = new List<String>();
		List<Stock_x_MM__c> existingMMStocks = new List<Stock_x_MM__c>();
		List<StockWrapper> validatedData;
		List<String> headersRow = new List<String>();
		List<String> dataRows = new List<String>();
		Map<String, String> errorMessages = new Map<String, String>();
		Set<String> cyclesId = new Set<String>();
		Set<String> productsId = new Set<String>();
		Set<String> apmsId = new Set<String>();
		Map<Id, Map<Id, List<Stock_x_Ciclo__c>>> stocksByCycle = new Map<Id, Map<Id, List<Stock_x_Ciclo__c>>>();
		Map<Id, Map<Id, List<Stock_x_MM__c>>> stocksByMM = new Map<Id, Map<Id, List<Stock_x_MM__c>>>();
		Map<String, List<Stock_x_MM__c>> mmStocksToAssignId = new Map<String, List<Stock_x_MM__c>>();
		Boolean hasErrors = false;

		if (!String.isEmpty(base64Data)) {
			String data;
			if (!Test.isRunningTest()) {
				data= JSON.deserializeUntyped(base64Data).toString();
			}else{
				data = base64Data;
			}
			system.debug(data);
			dataRows = data.split('\r\n');
			headersRow = dataRows[0].split(',');
			dataRows = getDataRows(dataRows);

			Boolean isValidHeaders = headersRowIsValid(headersRow, errorMessages);
			if (isValidHeaders) {
				validatedData = validateCSVData(dataRows, errorMessages);
                System.debug(validatedData);

				for (StockWrapper wrapper : validatedData) {
					cyclesId.add(wrapper.cycleId);
					apmsId.add(wrapper.contactId);
					productsId.add(wrapper.productId);
				}
				List<Stock_x_Ciclo__c> stocksByCycleList =  [
					SELECT  Ciclo__c,
							APM__c
					FROM    Stock_x_Ciclo__c
					WHERE   Ciclo__c IN :cyclesId
					AND 	APM__c IN :apmsId
				];

				for (Stock_x_Ciclo__c cycleByApm : stocksByCycleList) {
					// if (!stocksByCycle.containsKey(cycleByApm.Ciclo__c)) {
					// 	stocksByCycle.put(cycleByApm.Ciclo__c, new Map <String, List<Stock_x_Ciclo__c>>());
					// }
					// if (!stocksByCycle.containsKey(cycleByApm.APM__c)) {
					// 	stocksByCycle.get(cycleByApm.Ciclo__c).put(cycleByApm.APM__c, new List<Stock_x_Ciclo__c>());
					// }

					// stocksByCycle.get(cycleByApm.Ciclo__c).get(cycleByApm.APM__c).add(cycleByApm);
					Id ciclo = cycleByApm.Ciclo__c;
					Id apm = cycleByApm.APM__c;

					if (!stocksByCycle.containsKey(ciclo)) {
						stocksByCycle.put(ciclo, new Map<Id, List<Stock_x_Ciclo__c>>());
					}

					Map<Id, List<Stock_x_Ciclo__c>> cicloMap = stocksByCycle.get(ciclo);

					if (!cicloMap.containsKey(apm)) {
						cicloMap.put(apm, new List<Stock_x_Ciclo__c>());
					}

					List<Stock_x_Ciclo__c> apmList = cicloMap.get(apm);
					apmList.add(cycleByApm);
				}
				System.debug('stocksByCycle');
				System.debug(stocksByCycle);
				List<Stock_x_MM__c> stocksByMMList = [
					SELECT  Stock_x_Ciclo__r.Ciclo__c,
							Stock_x_Ciclo__r.APM__c,
							Remanente__c,
							Recibido__c,
							Stock_x_Ciclo__c,
							Muestra_Medica__c
					FROM    Stock_x_MM__c
					WHERE   Stock_x_Ciclo__r.Ciclo__c IN :cyclesId
					AND 	Stock_x_Ciclo__r.APM__c IN : apmsId
					AND 	Muestra_Medica__c IN : productsId
				];
				for (Stock_x_MM__c stockByMM : stocksByMMList) {
					// if (!stocksByMM.containsKey(stockByMM.Stock_x_Ciclo__r.Ciclo__c)) {
					// 	stocksByMM.put(stockByMM.Stock_x_Ciclo__r.Ciclo__c, new Map<String, List<Stock_x_MM__c>>());
					// }
					// if (!stocksByMM.containsKey(stockByMM.Stock_x_Ciclo__r.APM__c)) {
					// 	stocksByMM.get(stockByMM.Stock_x_Ciclo__r.Ciclo__c).put(stockByMM.Stock_x_Ciclo__r.APM__c, new List<Stock_x_MM__c>());
					// }

					// stocksByMM.get(stockByMM.Stock_x_Ciclo__r.Ciclo__c).get(stockByMM.Stock_x_Ciclo__r.APM__c).add(stockByMM);
					Id ciclo = stockByMM.Stock_x_Ciclo__r.Ciclo__c.to15();
					Id apm = stockByMM.Stock_x_Ciclo__r.APM__c.to15();

					if (!stocksByMM.containsKey(ciclo)) {
						stocksByMM.put(ciclo, new Map<Id, List<Stock_x_MM__c>>());
					}
					
					Map<Id, List<Stock_x_MM__c>> cicloMap = stocksByMM.get(ciclo);
					
					if (!cicloMap.containsKey(apm)) {
						cicloMap.put(apm, new List<Stock_x_MM__c>());
					}
					
					List<Stock_x_MM__c> apmList = cicloMap.get(apm);
					apmList.add(stockByMM);
					System.debug('stocksByMM');
					System.debug(stocksByMM);
					// System.debug('Recibido');
					// System.debug(stocksByMM.get(stockByMM.Stock_x_Ciclo__r.Ciclo__c+'|'+stockByMM.Stock_x_Ciclo__r.APM__c).Recibido__c);
					// System.debug('Remanente');
					// System.debug(stocksByMM.get(stockByMM.Stock_x_Ciclo__r.Ciclo__c+'|'+stockByMM.Stock_x_Ciclo__r.APM__c).Remanente__c);
				}
				// System.debug('stocksByMM');
				// System.debug(stocksByMM);
				Boolean existStockByMM = false;
				for (StockWrapper wrapper : validatedData) {
					System.debug('wrapper');
					System.debug(wrapper);
					if (!wrapper.hasErrors()) {
						// Id cycleToId = Id.valueOf(wrapper.cycleId);
						// Id cycleId15 = cycleToId.to15();
						// Id contactToId = Id.valueOf(wrapper.contactId);
						// Id contactId15 = contactToId.to15();
						if (stocksByCycle.containsKey(wrapper.cycleId)) {
							if (stocksByCycle.get(wrapper.cycleId).containsKey(wrapper.contactId)) {								
								List<Stock_x_Ciclo__c> stocks = stocksByCycle.get(wrapper.cycleId).get(wrapper.contactId);	
								for (Stock_x_Ciclo__c stock : stocks) {
									System.debug('stocks');
									System.debug(stocks);
									//Map<Id, Stock_x_MM__c> stockPorProducto = new Map<Id, Stock_x_MM__c>();
									if (stocksByMM.containsKey(stock.Ciclo__c) ) {
										if (stocksByMM.get(stock.Ciclo__c).containsKey(stock.APM__c)) {											
											List<Stock_x_MM__c> mmStocks = stocksByMM.get(stock.Ciclo__c).get(stock.APM__c);
											for (Stock_x_MM__c mmStock : mmStocks) {
												Stock_x_MM__c newMMStock = new Stock_x_MM__c(
													Muestra_Medica__c = wrapper.productId,
													Recibido__c = Integer.valueOf(wrapper.quantity),
													Stock_x_Ciclo__c = stock.Id
												);
												//stockPorProducto.put(newMMStock.Muestra_Medica__c, newMMStock);
												// Id productToId = Id.valueOf(wrapper.productId);
												// Id productId15 = productToId.to15();	
												// Id mmToId = Id.valueOf(mmStock.Muestra_Medica__c);
												// Id mmId15 = mmToId.to15();	
												if (wrapper.productId == mmStock.Muestra_Medica__c) {
													existStockByMM = true;
													System.debug('mmStock');
													System.debug(mmStock);
													mmStock.Recibido__c = (mmStock.Recibido__c != null) ? mmStock.Recibido__c + Integer.valueOf(wrapper.quantity) : Integer.valueOf(wrapper.quantity);
													existingMMStocks.add(mmStock);
													//stockPorProducto.remove(wrapper.productId);
												}
											}
											if(!existStockByMM) {
												Stock_x_MM__c newMMStock = new Stock_x_MM__c(
													Muestra_Medica__c = wrapper.productId,
													Recibido__c = Integer.valueOf(wrapper.quantity),
													Stock_x_Ciclo__c = stock.Id
												);
												newMMStocks.add(newMMStock);
											}
											existStockByMM = false;
										}else {
											Stock_x_MM__c newMMStock = new Stock_x_MM__c(
												Muestra_Medica__c = wrapper.productId,
												Recibido__c = Integer.valueOf(wrapper.quantity),
												Stock_x_Ciclo__c = stock.Id
											);
											System.debug('mmStock nuevo que no existia');
											System.debug(newMMStock);
											newMMStocks.add(newMMStock);	
										}
									} else {
										Stock_x_MM__c newMMStock = new Stock_x_MM__c(
											Muestra_Medica__c = wrapper.productId,
											Recibido__c = Integer.valueOf(wrapper.quantity),
											Stock_x_Ciclo__c = stock.Id
										);
										System.debug('mmStock nuevo que no existia');
										System.debug(newMMStock);
										newMMStocks.add(newMMStock);

									}
									//newMMStocks.addAll(stockPorProducto.values());
								}
							}
						} else {
							// Stock_x_Ciclo__c newCycleStock = new Stock_x_Ciclo__c();
							
							// newCycleStock.APM__c = wrapper.contactId;
							// newCycleStock.Ciclo__c = wrapper.cycleId;
							// newCycleStocks.add(newCycleStock);
							// Verificar si la clave única ya existe en la lista
							Id cycleToId = Id.valueOf(wrapper.cycleId);
							Id cycleId15 = cycleToId.to15();
							Id contactToId = Id.valueOf(wrapper.contactId);
							Id contactId15 = contactToId.to15();
							String uniqueKey = contactToId + '-' + contactId15;
							if (!uniqueKeys.contains(uniqueKey)) {
								// Agregar una nueva instancia de Stock_x_Ciclo__c solo si la clave única no existe
								Stock_x_Ciclo__c newCycleStock = new Stock_x_Ciclo__c();
								newCycleStock.APM__c = wrapper.contactId;
								newCycleStock.Ciclo__c = wrapper.cycleId;
								newCycleStocks.add(newCycleStock);
								uniqueKeys.add(uniqueKey);
								System.debug('New cycle stock');
								System.debug(newCycleStock);
							}

							// Agregar una nueva instancia de Stock_x_MM__c a mmStocksToAssignId
							Stock_x_MM__c newMMStock = new Stock_x_MM__c();
							newMMStock.Muestra_Medica__c = wrapper.productId;
							newMMStock.Recibido__c = Integer.valueOf(wrapper.quantity);

							if (!mmStocksToAssignId.containsKey(wrapper.contactId)) {
								mmStocksToAssignId.put(wrapper.contactId, new List<Stock_x_MM__c>());
							}
							mmStocksToAssignId.get(wrapper.contactId).add(newMMStock);

							System.debug('New MM stock');
							System.debug(newMMStock);
							
						}
					}
				}

				// System.debug('existingMMStocks');
				// for(Stock_x_MM__c stockTets : existingMMStocks){
				// 	System.debug(stockTets);
				// }
                
				update existingMMStocks;

				List<Database.SaveResult> newRecordsResult = Database.Insert(newCycleStocks);

				for (Database.SaveResult result : newRecordsResult) {
					if (result.isSuccess()) {
						for (StockWrapper wrapper : validatedData) {
							List<Stock_x_MM__c> mmStocksByAPM = mmStocksToAssignId.get(wrapper.contactId);
							for (Stock_x_Ciclo__c newCycleStock : newCycleStocks) {
								
								if (newCycleStock.Ciclo__c == wrapper.cycleId && wrapper.contactId == newCycleStock.APM__c) {
									for (Stock_x_MM__c mmStock : mmStocksByAPM) {
										if (
											wrapper.productId == mmStock.Muestra_Medica__c 
											&& !newMMStocks.contains(mmStock) 
											&& wrapper.contactId == newCycleStock.APM__c
										) {																					
											mmStock.Stock_x_Ciclo__c = newCycleStock.Id;
											newMMStocks.add(mmStock);
										}
									}
								}
							}
						}
					}
				}
				// System.debug('newMMStocks');
				// for(Stock_x_MM__c stockTets : newMMStocks){
				// 	System.debug(stockTets);
				// }
                
				insert newMMStocks;
			}
		} else {
			errorMessages.put('[Ln: 0, Col: 0]', 'Contenido vacío.');
		}

		response.state = errorMessages.size() > 0 ? 'ERROR' : 'SUCCESS';
		response.data = validatedData;
		response.errors = errorMessages;
		System.debug('response -->'+response);
		return response;
	}

	//APM => APM__c
	//Ciclo => Ciclo__c
	//Recibido => Recibido__c
	//Muestra Medica => Muestra_Medica__c

	private static Boolean headersRowIsValid(
		List<String> headersRow,
		Map<String, String> errorMessages
	) {
		String message = 'Cabecero no válido [Esperado: {0}, Actual: {1}].';
		Integer columnIndex = 0;
		Boolean isValid = true;
		//errorMessages = new Map<String, String>();

		if (headersRow[0] != 'Ciclo') {
			isValid = false;
			System.debug('[Ln: 0, Col: 0]' + String.format(message, new String[] { 'Ciclo', headersRow[0] }));
			errorMessages.put('[Ln: 0, Col: 0]', String.format(message, new String[] { 'Ciclo', headersRow[0] }));
		}

		if (headersRow[1] != 'Producto') {
			isValid = false;
			System.debug('[Ln: 0, Col: 1]' + String.format(message, new String[] { 'Producto', headersRow[1] }));
			errorMessages.put('[Ln: 0, Col: 1]', String.format(message, new String[] { 'Producto', headersRow[1] }));
		}

		if (headersRow[2] != 'APM') {
			isValid = false;
			System.debug('[Ln: 0, Col: 2]' + String.format(message, new String[] { 'APM', headersRow[2] }));
			errorMessages.put('[Ln: 0, Col: 2]', String.format(message, new String[] { 'APM', headersRow[2] }));
		}

		if (headersRow[3] != 'Cantidad') {
			isValid = false;
			System.debug('[Ln: 0, Col: 3]' + String.format(message, new String[] { 'Cantidad', headersRow[3] }));
			errorMessages.put('[Ln: 0, Col: 3]', String.format(message, new String[] { 'Cantidad', headersRow[3] }));
		}
		system.debug(errorMessages);
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

	private static List<StockWrapper> validateCSVData(
		List<String> dataRows,
		Map<String, String> errorMessages
	) {
		List<StockWrapper> validatedData = new List<StockWrapper>();
		Integer rowIndex = 1;
		errorMessages = new Map<String, String>();

		for (String dataRow : dataRows) {
			StockWrapper wrapper = new StockWrapper();
			List<String> dataColumns = dataRow.split(',');
			Integer emptyKeys = 0;
			Integer filledKeys = 0;

			if (dataColumns[0] != null) {
				wrapper.cycleId = dataColumns[0];
			} else {
				wrapper.cycleId = '';
				// errorMessages.put('[Ln: ' + String.valueOf(rowIndex) + ']', 'Debe agregar ciclo.');
				wrapper.addError('[Ln: ' + String.valueOf(rowIndex) + ']', 'Debe agregar ciclo.');
			}

			if (dataColumns[1] != null) {
				wrapper.productId = dataColumns[1];
			} else {
				wrapper.productId = '';
				// errorMessages.put('[Ln: ' + String.valueOf(rowIndex) + ']', 'Debe agregar producto.');
				wrapper.addError('[Ln: ' + String.valueOf(rowIndex) + ']', 'Debe agregar producto.');
			}

			if (dataColumns[2] != null) {
				wrapper.contactId = dataColumns[2];
			} else {
				wrapper.contactId = '';
				// errorMessages.put('[Ln: ' + String.valueOf(rowIndex) + ']', 'Debe agregar APM.');
				wrapper.addError('[Ln: ' + String.valueOf(rowIndex) + ']', 'Debe agregar APM.');
			}

			if (dataColumns[3] != null) {
				String quantity = dataColumns[3];
				if (quantity.isNumeric()) {
					wrapper.quantity = dataColumns[3];
				} else {
					wrapper.quantity = '';
					// errorMessages.put('[Ln: ' + String.valueOf(rowIndex) + ']', String.format('Dato no válido, se esperaba valor númerico. [Actual: {0}]', new String[] { quantity }));
					wrapper.addError('[Ln: ' + String.valueOf(rowIndex) + ']', String.format('Dato no válido, se esperaba valor númerico. [Actual: {0}]', new String[] { quantity }));
				}
			} else {
				wrapper.quantity = '';
				// errorMessages.put('[Ln: ' + String.valueOf(rowIndex) + ']', 'Debe agregar cantidad.');
				wrapper.addError('[Ln: ' + String.valueOf(rowIndex) + ']', 'Debe agregar cantidad.');
			}

			validatedData.add(wrapper);

			rowIndex++;
		}

		return validatedData;
	}

	public class StockWrapper {
		@AuraEnabled
		public String cycleId; // Ciclo

		@AuraEnabled
		public String productId; // Product

		@AuraEnabled
		public String contactId; // APM

		@AuraEnabled
		public String quantity; //Cantidad

		@AuraEnabled
		public String error;

		@AuraEnabled
		public Map<String, String> results;

		public StockWrapper() {
			this.results = new Map<String, String>();
		}

		public void addError(String code, String message) {
			this.results.put(code, message);
		}

		public Boolean hasErrors() {
			return !this.results.isEmpty();
		}
	}
}