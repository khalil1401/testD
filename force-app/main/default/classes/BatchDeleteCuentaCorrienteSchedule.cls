public with sharing class BatchDeleteCuentaCorrienteSchedule implements Schedulable{
    public static void execute (SchedulableContext sc) {
        BatchDeleteCuentaCorriente batch = new BatchDeleteCuentaCorriente();
        Database.executeBatch(batch);
    }
}