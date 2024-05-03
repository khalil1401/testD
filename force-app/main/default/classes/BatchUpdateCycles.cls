global class BatchUpdateCycles implements Database.Batchable<SObject> {

	global Database.QueryLocator start(Database.BatchableContext ciclosSearch) {

		Id recordTypeId = XappiaHelper.getRecordType('Contact', 'Visitador médico').Id;
		return Database.getQueryLocator(
			'SELECT Id,Cantidad_de_dias_habiles__c,Dias_de_campo_efectivo_transcurridos__c,' +
			'Fecha_de_inicio__c,Fecha_de_fin__c,Cantidad_de_dias_en_el_mes__c,Actualizar__c,' +
			'(SELECT Id,Cantidad_de_dias__C,Ciclo__c,Aprobado__c,Dia_decimal__c,' +
			'Cantidad_de_dias_de_la_licencia__c,' +
			'Fecha_de_inicio__c,Fecha_de_fin__c FROM Licencias__r) ' +
			'FROM Ciclo__c');

	}

   	global void execute(Database.BatchableContext ciclosSearch, List<Ciclo__c> scope) {

		List<Ciclo__c> results = DiasHabilesTranscurridosHelper.calcularDiasHabilesTranscurridos(scope);

		if (results != null && results.size() > 0) { 
			update results;
		}
	
	}
	
	global void finish(Database.BatchableContext ciclosSearch) {
		
	}
}