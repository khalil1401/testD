global class GetErrorSyncOrdersSchedule implements Schedulable{
    global void execute (SchedulableContext sc) {

        BatchGetOrderSyncErrors batch = new BatchGetOrderSyncErrors();
		database.executebatch(batch, 200);   

    }
}