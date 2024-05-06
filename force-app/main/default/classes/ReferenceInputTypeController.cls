public with sharing class ReferenceInputTypeController {
	@AuraEnabled
	public static List<SObject> find(
		String objectName,
		List<String> fields,
		String keyword
	) {
		System.debug('Primer Find');
		Map<Id, Object> result = new Map<Id, Object>();
		String returningQuery = '';
		String query = '';
		keyword = '%' + keyword + '%';

		returningQuery = 'Id, ' + String.join(fields, ', ');
		query = 'SELECT ' + returningQuery + ' FROM ' + objectName + ' WHERE Name LIKE :keyword LIMIT 5';

		List<SObject> records = Database.query(query);
		return records;
	}

	@AuraEnabled
	public static List<SObject> find(
		String objectName,
		List<String> fields,
		String keyword,
		List<String> RecordTypeId
	) {
		System.debug('Second Find');
		Map<Id, Object> result = new Map<Id, Object>();
		String returningQuery = '';
		String query = '';
		keyword = '%' + keyword + '%';

		returningQuery = 'Id, ' + String.join(fields, ', ');

		if (ObjectName == 'Dan360_Remito__c') {
			query = 'SELECT ' + returningQuery + ' FROM ' + objectName + ' WHERE Dan360_Remito__c LIKE :keyword';
			
		}
		else {
			query = 'SELECT ' + returningQuery + ' FROM ' + objectName + ' WHERE Name LIKE :keyword';
		}
		
		if (RecordTypeId.size() > 0) {
			query += ' AND RecordTypeId IN :RecordTypeId';
		}

		query += ' LIMIT 5';

		List<SObject> records = Database.query(query);

		system.debug(records);
		system.debug(objectName);
		

		return records;
	}

	@AuraEnabled
	public static List<SObject> findRemitoSucursal(
		String objectName,
		List<String> fields,
		String keyword,
		String recordId
	) {
		System.debug(recordId);
		String returningQuery = '';
		String query = '';
		keyword = '%' + keyword + '%';

		if (objectName == 'Dan360_Remito__c') {
			returningQuery = 'Id, ' + String.join(fields, ', ');

			query = 'SELECT ' + returningQuery + ' FROM Dan360_DocumentosCuentaCorriente__c WHERE Dan360_Remito__r.Dan360_Remito__c LIKE :keyword AND Dan360_Cliente__c =:recordId AND Dan360_Remito__c != null';
		
			system.debug(query);
			List<String> listaRemito1 = new List<String>();
			for(Dan360_DocumentosCuentaCorriente__c prueba : Database.query(query)){
					listaRemito1.add (prueba.Dan360_Remito__c);
				}

			system.debug(listaRemito1);

			List<Dan360_Remito__c> listaRemito2 = [Select Id, Dan360_Remito__c FROM Dan360_Remito__c WHERE Id IN :listaRemito1];
			System.debug(listaRemito2);
			return listaRemito2;

		} else if (objectName == 'Account') {
			returningQuery = 'Id, Dan360_Sucursal__c' ;
			query = 'SELECT ' + returningQuery + ' FROM Dan360_DocumentosCuentaCorriente__c WHERE Dan360_Sucursal__r.Name LIKE :keyword AND Dan360_Cliente__c =:recordId AND Dan360_Sucursal__c != null';
		
			system.debug(query);
			List<String> listaSucursal = new List<String>();
			for(Dan360_DocumentosCuentaCorriente__c prueba : Database.query(query)){
					listaSucursal.add (prueba.Dan360_Sucursal__c);
				}

			system.debug(listaSucursal);

			List<Account> listaSucursal2 = [Select Id, Name, BillingStreet FROM Account WHERE Id IN :listaSucursal];
			System.debug(listaSucursal2);
			return listaSucursal2;
		}

		return new List<sObject>();
	}

	@AuraEnabled
	public static String getIconInfo(String sobjectName){
		return Danone360Helper.getSObjectIcon(sobjectName);
	}

	// @AuraEnabled
	// public static List<SObject> findRemitosCCFilter(
	// 	String objectName,
	// 	List<String> fields,
	// 	String keyword
	// ){
	// 	String returningQuery = '';
	// 	String query = '';
	// 	keyword = '%' + keyword + '%';

	// 	returningQuery = 'Id, ' + String.join(fields, ', ');
	// 	query = 'SELECT ' + returningQuery + ' FROM ' + objectName + ' WHERE Dan360_Remito__c = ';

	// 	List<SObject> records = Database.query(query);
	// 	return records;
	// } 

	@AuraEnabled
	public static List<String> getRemitosFromCC(){
		List<String> listets = new List<String>();
		for(Dan360_DocumentosCuentaCorriente__c listCC : [SELECT Id, Name, Dan360_NroComprobante__c,Dan360_Remito__c 
															FROM Dan360_DocumentosCuentaCorriente__c 
															WHERE Dan360_CodigoCliente__c = '11111']){
			if(listCC.Dan360_Remito__c != null){
				listets.add(listCC.Dan360_Remito__c);
			}
								
		}
		System.debug(listets);
		return listets;
	}
}