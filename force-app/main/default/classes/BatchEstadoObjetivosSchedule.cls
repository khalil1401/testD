public with sharing class BatchEstadoObjetivosSchedule implements Schedulable{ 
    public static String CRON_EXP = '0 0 0 ? * * *'; 
        public static void execute (SchedulableContext sc) { 
            Database.executeBatch(new BatchEstadoObjetivos()); 
        } 
}