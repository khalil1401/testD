global with sharing class BatchQuarterSchedule implements Schedulable {
	global static void execute(SchedulableContext context) {
		BatchQuarter batch = new BatchQuarter();
		Database.executeBatch(batch);
	}
}