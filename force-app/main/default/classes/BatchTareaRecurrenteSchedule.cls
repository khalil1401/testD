global class BatchTareaRecurrenteSchedule implements Schedulable {
 
	global void execute(SchedulableContext sc) {
		BatchTareaRecurrente batch = new BatchTareaRecurrente();
		database.executebatch(batch, 200);
	}
}