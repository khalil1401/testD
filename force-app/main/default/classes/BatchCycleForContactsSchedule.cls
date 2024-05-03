global class BatchCycleForContactsSchedule implements Schedulable {

	global void execute(SchedulableContext sc) {

		BatchCycleForContacts batch = new BatchCycleForContacts();
		database.executebatch(batch, 200);
        
        string year = '' + (DateTime.now().year() + 1);
        string code = ' ' + DateTime.now().second() + DateTime.now().minute() + DateTime.now().hour() + DateTime.now().day() + DateTime.now().month();
        string cron_exp = '0 0 0 1 1 ? ' + year;
        string jobId = System.schedule('Crear ciclos para ' + year + code, cron_exp, new BatchCycleForContactsSchedule());

		
	}
}