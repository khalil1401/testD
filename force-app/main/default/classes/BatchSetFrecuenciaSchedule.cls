global with sharing class BatchSetFrecuenciaSchedule implements Schedulable {
	global static void execute(SchedulableContext context) {
		BatchSetFrecuencia batch = new BatchSetFrecuencia();
		Database.executeBatch(batch);
	}
}