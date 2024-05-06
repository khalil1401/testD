public with sharing class BatchCountLicencias implements Database.Batchable<sObject>, Database.Stateful {

     // Atributo para mantener el estado del mapa entre los lotes
    private Map<Id, List<Dan360_Licencia__c>> licenciasPorEfectividadStateful = new Map<Id, List<Dan360_Licencia__c>>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
        Date fechaActual = System.today();        
        Date fechaInicio = fechaActual.addMonths(-1).toStartOfMonth();
        
        return Database.getQueryLocator([
            SELECT Id, Name, Fecha_de_inicio__c, Fecha_de_Fin__c, Efectividad__c, Motivo__c, Estado__c
            FROM Dan360_Licencia__c
            WHERE Estado__c = 'Aprobada'
            AND Fecha_de_inicio__c >= :fechaInicio
            AND Fecha_de_inicio__c <= :fechaActual
            AND RecordTypeId = :recordTypeLicencia
            order by Efectividad__c ASC
        ]);
    }

    public void execute(Database.BatchableContext BC, list<Dan360_Licencia__c> licencias) {
        System.debug('****licencias: ' + licencias);
        //Map<Id, List<Dan360_Licencia__c>> licenciasPorEfectividad = New Map<Id, List<Dan360_Licencia__c>>();

        for (Dan360_Licencia__c licencia : licencias) {
            List<Dan360_Licencia__c> listLicencias;
            listLicencias = licenciasPorEfectividadStateful.containsKey(licencia.Efectividad__c) ? licenciasPorEfectividadStateful.get(licencia.Efectividad__c) : New List<Dan360_Licencia__c>();
            if (licencia.Estado__c == 'Aprobada') {
                listLicencias.add(licencia);
                licenciasPorEfectividadStateful.put(licencia.Efectividad__c, listLicencias);
            }
        }

        
    }

    public void finish (Database.BatchableContext BC) {
        List<Dan360_Efectividad__c> efectividadesToUpdate = [
            SELECT Id, Name, Dias_de_Licencia_Transcurridos__c, VisMed_Dias_de_Licencia_Unicos__c
            FROM Dan360_Efectividad__c
            WHERE Id IN :licenciasPorEfectividadStateful.keySet()
        ];

        for (Dan360_Efectividad__c efectividad : efectividadesToUpdate) {
            //Cuenta solo las licencias que NO sean Festivos.
            Map<Date, Dan360_Licencia__c> diasPorLicenciaNoFestivo = new Map<Date, Dan360_Licencia__c>();
            //Cuenta solo las licencias que sean Festivos.
            Map<Date, Dan360_Licencia__c> diasPorLicenciaFestivos = new Map<Date, Dan360_Licencia__c>();
            //Cuenta todas las licencias.
            Map<Date, Dan360_Licencia__c> diasPorLicenciaUnicos = new Map<Date, Dan360_Licencia__c>();

            for (Dan360_Licencia__c licencia : licenciasPorEfectividadStateful.get(efectividad.Id)) {
                Integer daysBetweenNew;
                if (licencia.Fecha_de_Fin__c > System.today()) {
                    daysBetweenNew = licencia.Fecha_de_inicio__c.daysBetween(System.today());
                } else {
                    daysBetweenNew = licencia.Fecha_de_inicio__c.daysBetween(licencia.Fecha_de_Fin__c);
                }

                Date auxFechaNew = licencia.Fecha_de_inicio__c;
                for (Integer i = 0; i <= daysBetweenNew; i++) {
                    Datetime dt = (Datetime) auxFechaNew;
                    //Salesforce me toma la zona horaria defasada por 3 horas, asi que los dias se defasaban.
                    String dayOfWeek = dt.format('EEEE', 'Europe/Jersey');

                    if (dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday') {
                        if (licencia.Motivo__c != 'Festivo') {
                            diasPorLicenciaNoFestivo.put(auxFechaNew, licencia);
                        } else {
                            diasPorLicenciaFestivos.put(auxFechaNew, licencia);
                        }
                        diasPorLicenciaUnicos.put(auxFechaNew, licencia);
                    }
                    auxFechaNew = auxFechaNew.addDays(1);
                }
            }

            efectividad.Dias_de_Licencia_Transcurridos__c = diasPorLicenciaNoFestivo.keySet().size();
            efectividad.Dias_feriados_Transcurridos__c = diasPorLicenciaFestivos.keySet().size();
            efectividad.VisMed_Dias_de_Licencia_Unicos__c = diasPorLicenciaUnicos.keySet().size();
        }

        update efectividadesToUpdate;
    }
}