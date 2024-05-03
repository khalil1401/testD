global class BatchCrearCasosDeSeguimiento_Schedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        BatchCrearCasosDeSeguimiento batch = new BatchCrearCasosDeSeguimiento();
        database.executebatch(batch, 50);        
    }
}