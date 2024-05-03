public with sharing class BatchUpdateEMDPSchedule implements Schedulable{
    
    public static void execute (SchedulableContext sc) {
        BatchUpdateEstadoMdp batch = new BatchUpdateEstadoMdp();
        Database.executeBatch(batch, 50);
    }
}