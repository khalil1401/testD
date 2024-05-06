public with sharing class MatriculaTriggerHelper {
    
    public static void setMatriculaToProfesional (List<Dan360_Matricula__c> matriculas) {
        Id recordTypeNacional = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Nacional').getRecordTypeId();
        Id recordTypeProvincial = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Provincial').getRecordTypeId();
        Set<Id> profesionalesId = new Set<Id>();
        Map<Id, Account> profesionalPorId = new Map<Id, Account>();
        for (Dan360_Matricula__c matricula : matriculas) {
            profesionalesId.add(matricula.Profesional__c);
        }
        List<Account> profesionales = [SELECT Id, Matricula_Nacional__c, Matricula_Provincial__c FROM Account WHERE Id IN :profesionalesId];
        for (Account profesional : profesionales) {
            profesionalPorId.put(profesional.Id, profesional);
        }
        List<Account> profesionalesToUpdate = new List<Account>();
        for (Dan360_Matricula__c matricula : matriculas) {
            Account profesional = profesionalPorId.get(matricula.Profesional__c);
            if (matricula.RecordTypeId == recordTypeNacional) {
               profesional.Matricula_Nacional__c = matricula.Numero_de_matricula__c;
            } else if (matricula.RecordTypeId == recordTypeProvincial) {
                profesional.Matricula_Provincial__c = matricula.Numero_de_matricula__c;
            }            
        }
        System.debug(profesionalPorId.values());
        update profesionalPorId.values();
    }

}