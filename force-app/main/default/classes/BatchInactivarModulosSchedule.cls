global class BatchInactivarModulosSchedule implements Schedulable {

	global void execute(SchedulableContext sc) {

		BatchInactivarModulos batch = new BatchInactivarModulos();
		database.executebatch(batch, 200);        
	}
}