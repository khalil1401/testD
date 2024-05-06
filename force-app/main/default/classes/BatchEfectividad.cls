public class BatchEfectividad implements Database.Batchable<sObject> {
  
    public Database.QueryLocator start (Database.BatchableContext bc) {
        Integer thisMonth = System.today().month();
        Id recordTypeVisitadorMedico = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId();
        return Database.getQueryLocator([SELECT Id, Name, ContactId, Contact.Name, IsActive, IsPortalEnabled
                                         FROM User
                                         WHERE IsActive = true 
                                            AND IsPortalEnabled = true 
                                            AND ContactId != null 
                                            AND Contact.RecordTypeId = :recordTypeVisitadorMedico 
                                            ]);
        }
    //0030300000ZQITyAAP
    public void execute (Database.BatchableContext BC, list<User> apms) {
        //Mapas para completar el ID externo del stock x Ciclo
        Map<String, String> mapClicloIdClicloName = new Map<String, String>();
        Map<String, String> mapApmIdApmName = new Map<String, String>();

        Integer thisMonth = System.today().month();
        Integer thisYear = System.today().year();
        List<Dan360_Efectividad__c> newEfectividades = New List<Dan360_Efectividad__c>();   
        List<VisMed_Ciclo__c> ciclos = [SELECT Id, VisMed_Cmpt_Tiempo_no_promocional__c, Fecha_de_inicio__c, Fecha_de_Fin__c, Name
                                        FROM VisMed_Ciclo__c
                                        WHERE Numero_de_mes__c = :thisMonth 
                                        AND Anio__c = :thisYear];  

        for(VisMed_Ciclo__c ciclo : ciclos) {
            if(!mapClicloIdClicloName.containsKey(ciclo.Id)) {
                mapClicloIdClicloName.put(ciclo.Id, ciclo.Name);
            }
        }

        for(User apm : apms){
            if(!mapApmIdApmName.containsKey(apm.Id)){
                mapApmIdApmName.put(apm.ContactId, apm.Name);
            }
        }

        // System.debug('mapApmIdApmName >>> '  + JSON.serialize(mapApmIdApmName));
        DateTime fecha = DateTime.now();
        String monthName = fecha.format('MMMMM');
        String yearName = fecha.format('YYYY');   
        if (!ciclos.isEmpty()) { // Chequeo que haya metadata parametrizada para este ciclo.
            for (VisMed_Ciclo__c ciclo : ciclos) {
                for (User apm : apms) {
                    Dan360_Efectividad__c newEfectividad = New Dan360_Efectividad__c(
                        //name = monthName + ' - ' + yearName + ' - ' + apm.Contact.Name,
                        Fecha_de_inicio__c = ciclo.Fecha_de_inicio__c,
                        Fecha_de_Fin__c = ciclo.Fecha_de_Fin__c,
                        VisMed_APM__c = apm.ContactId,
                        VisMed_Ciclo__c = ciclo.Id
                    );
                    newEfectividades.add(newEfectividad);
                }
            }
        } else { // Si no hay metadata parametrizada para el mes calendario entonces se crea la efectividad con el inicio y fin del mes.
            for (User apm : apms) {
                // System.debug(apm.Id);
                Dan360_Efectividad__c newEfectividad = New Dan360_Efectividad__c(
                        //name = monthName + ' - ' + yearName + ' - ' + apm.Contact.Name,
                        Fecha_de_inicio__c = System.today().toStartOfMonth(), // Inicio del mes.
                        Fecha_de_Fin__c = (System.today().toStartOfMonth()).addMonths(1).addDays(-1), // Fin del mes.
                        VisMed_APM__c = apm.ContactId
                    );
                    newEfectividades.add(newEfectividad);
            }
        }
        Database.insert(newEfectividades,false);   
        
        //creacion del Stock x Ciclo
        List<Stock_x_Ciclo__c> stocks = new List<Stock_x_Ciclo__c>();
        for (Dan360_Efectividad__c efectividad : newEfectividades) {
            String idExterno = mapApmIdApmName.get(efectividad.VisMed_APM__c)+ ' - ' + mapClicloIdClicloName.get(efectividad.VisMed_Ciclo__c);
            Stock_x_Ciclo__c stock = new Stock_x_Ciclo__c(
                Ciclo__c = efectividad.VisMed_Ciclo__c,
                APM__c = efectividad.VisMed_APM__c,
                ID_Externo__c = idExterno
            );
            stocks.add(stock);
        }

        Schema.SObjectField externalId = Stock_x_Ciclo__c.Fields.ID_Externo__c;
        Database.upsert(stocks,externalId,false);
    }

    public void finish (Database.BatchableContext BC) {
        // execute any post-processing operations
    }

}