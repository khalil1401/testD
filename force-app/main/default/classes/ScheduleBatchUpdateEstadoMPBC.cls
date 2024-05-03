public with sharing class ScheduleBatchUpdateEstadoMPBC implements Schedulable{
    
    public static void execute (SchedulableContext sc) {
        BatchUpdateEstadoMPBC batch = new BatchUpdateEstadoMPBC();
        Database.executeBatch(batch, 50);
    }

    // String CRON_EXP = '0 0 * * * ?'; 
    // ScheduleBatchUpdateEstadoMPBC sch = new ScheduleBatchUpdateEstadoMPBC(); 
    // System.schedule('Prueba 1', CRON_EXP, sch);

}