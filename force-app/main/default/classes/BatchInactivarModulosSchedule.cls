global class BatchInactivarModulosSchedule implements Schedulable {

	global void execute(SchedulableContext sc) {

		BatchInactivarModulos batch = new BatchInactivarModulos();
		database.executebatch(batch, 200);
        
        string cron_exp = '0 0 3 1/1 * ? *';
        string jobId = System.schedule('Inactivar modulos', cron_exp, new BatchInactivarModulosSchedule());
        
	}
}