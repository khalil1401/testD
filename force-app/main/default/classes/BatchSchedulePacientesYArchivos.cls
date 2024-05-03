global class BatchSchedulePacientesYArchivos implements Schedulable{
    global void execute(SchedulableContext SC) {
        BatchRelacionarPacientesYArchivos batchArchivosYTareas = new BatchRelacionarPacientesYArchivos();
        database.executebatch(batchArchivosYTareas);
     }
}