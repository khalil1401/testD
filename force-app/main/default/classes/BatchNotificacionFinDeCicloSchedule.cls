Global with sharing class BatchNotificacionFinDeCicloSchedule implements Schedulable {
    public static void execute (SchedulableContext sc) {
        BatchNotificacionFinDeCiclo batch = new BatchNotificacionFinDeCiclo();
        Database.executeBatch(batch);
    }
}