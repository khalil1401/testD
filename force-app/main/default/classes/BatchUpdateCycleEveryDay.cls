global class BatchUpdateCycleEveryDay implements Schedulable {

	global void execute(SchedulableContext sc) {

		BatchUpdateCycles batch = new BatchUpdateCycles();
		database.executebatch(batch, 200);
        System.debug('Se ejecuto batch?');
		
	}
}