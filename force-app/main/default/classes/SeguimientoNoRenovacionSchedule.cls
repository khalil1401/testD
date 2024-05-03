public class SeguimientoNoRenovacionSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        // BatchSendEmailCC batch = new BatchSendEmailCC();
        BatchCrearCasoNoRenovacion batch = new BatchCrearCasoNoRenovacion();
        Database.executeBatch(batch);
    }
}