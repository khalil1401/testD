global class SchedulerCuentaCorriente implements Schedulable {
    global void execute(SchedulableContext sc){
        try {
            BatchCuentaCorriente batch = new BatchCuentaCorriente();
            ID batchId = Database.executeBatch(batch);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}