global class BatchCiclos implements Database.Batchable<sObject>,Database.Stateful  {
 
    global Database.QueryLocator start (Database.BatchableContext bc) {
        Integer thisMonth = System.today().month();
        Integer thisYear = System.today().year();
        Integer anioDeEjecucionDelBatch = System.today().year();
        Date fechaInicio = date.newInstance(anioDeEjecucionDelBatch, 1, 1);
        String query = 'SELECT Id, Name, Fecha_de_inicio__c, Fecha_de_Fin__c, Numero_de_mes__c, Anio__c' + 
                        ' FROM VisMed_Ciclo__c' +
                        ' WHERE Numero_de_mes__c >= ' + 1 +' ORDER BY Fecha_de_Fin__c DESC LIMIT 24'; // + ' AND Anio__c =' + thisYear;
        
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext BC, list<VisMed_Ciclo__c> ciclos) {
        system.debug('entra');
        Integer anioDeEjecucionDelBatch = System.today().year();
        Date fechaInicio = date.newInstance(anioDeEjecucionDelBatch, 1, 1); //primer dia del año
        Date fechaFin = (fechaInicio.toStartOfMonth()).addMonths(1).addDays(-1); // Fin del mes.
        Map<String, VisMed_Ciclo__c> mesPorAnio = New Map<String, VisMed_Ciclo__c>();

        for (Integer i = 1; i <= 12; i++) {
            VisMed_Ciclo__c newCiclo = New VisMed_Ciclo__c(
                Fecha_de_inicio__c = fechaInicio,
                Fecha_de_Fin__c = fechaFin
            );
            mesPorAnio.put(String.valueOf(i)+'-'+String.valueOf(anioDeEjecucionDelBatch), newCiclo);
            fechaInicio = fechaInicio.addMonths(1);
            fechaFin = fechaInicio.addMonths(1).addDays(-1);
        }
        for (VisMed_Ciclo__c ciclo : ciclos) {
            String clave = String.valueOf(ciclo.Numero_de_mes__c)+'-'+String.valueOf(ciclo.Anio__c);
            if (mesPorAnio.containsKey(clave)){
                mesPorAnio.remove(clave);
            }
        }
        system.debug(mesPorAnio.values());
        database.insert(mesPorAnio.values(),false);
    }

    global void finish (Database.BatchableContext BC) {
        // execute any post-processing operations
    }

}