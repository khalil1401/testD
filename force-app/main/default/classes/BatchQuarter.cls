public class BatchQuarter implements Database.Batchable<sObject> {
	public Database.QueryLocator start(Database.BatchableContext context) {
		Integer currentDay = System.today().day();
		Integer currentMonth = System.today().month();
		Integer currentYear = System.today().year();
		Integer executionBatchYear = System.today().year();
		Date currentDate = date.newInstance(executionBatchYear, currentMonth, currentDay);

		String query = 'SELECT	Id,';
		query += '				Fecha_inicio__c,';
		query += '				Fecha_fin__c';
		query += '		FROM	VisMed_Cuatrimestre__c';
		query += '		WHERE	Fecha_fin__c < :currentDate';
		query += '		ORDER BY';
		query += '				Fecha_inicio__c ASC';

		System.debug('query:::' + query);
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext context, List<VisMed_Cuatrimestre__c> quarters) {
		Integer executionBatchDay = System.today().day();
		Integer executionBatchMonth = System.today().month();
		Integer executionBatchYear = System.today().year();
		Date currentDate = date.newInstance(executionBatchYear, executionBatchMonth, executionBatchDay);
		VisMed_Cuatrimestre__c oldQuarter = (quarters.size() == 9) ? quarters[0] : null;

		VisMed_Cuatrimestre__c newQuarter = new VisMed_Cuatrimestre__c();
		newQuarter.Fecha_inicio__c = currentDate;
		newQuarter.Fecha_fin__c = currentDate.addMonths(3);

		insert newQuarter;
		if(oldQuarter != null){
			delete oldQuarter;
		}
		
	}

	public void finish(Database.BatchableContext context) {
	}
}