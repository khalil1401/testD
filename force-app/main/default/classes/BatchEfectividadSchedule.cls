Global with sharing class BatchEfectividadSchedule implements Schedulable {

    public static void execute (SchedulableContext sc) {
        BatchEfectividad batch = new BatchEfectividad();
        Database.executeBatch(batch);
    }

    // PARA TESTERAR EN LA CONSOLA ANONIMA //
    /*BatchEfectividadSchedule m = new BatchEfectividadSchedule();
    String cronExp1= '0 01 * * * ?';
    System.schedule('Creacion de Efectividades TEST', cronExp1, m);*/


}