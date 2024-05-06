public with sharing class LugarDeTrabajoTriggerHelper {
    public static void updateInstitucionTopOnProfessionals(Dan360_Lugar_de_Trabajo__c[] lugares) {
        Id[] institucionIds = new List<Id>();
        Set<Account> profesionalesTopToUpdate = new Set<Account>();
        List<Id> contactIds = new List<Id>();
        for(Dan360_Lugar_de_Trabajo__c lugar : lugares) {
            if(String.isNotBlank(lugar.Institucion__c)) {
                institucionIds.add(lugar.Institucion__c);
                contactIds.add(lugar.Profesional__c);
            }
        }
        Map<Id, Id> mapPersonalAccount = new Map<Id, Id>();
        for(Account cuentaPersonal : [SELECT Id, PersonContactId FROM Account WHERE PersonContactId IN :contactIds]){
            if(!mapPersonalAccount.containsKey(cuentaPersonal.PersonContactId)){
                mapPersonalAccount.put(cuentaPersonal.PersonContactId, cuentaPersonal.Id);
            }
        }
        System.debug(mapPersonalAccount);

        if(!institucionIds.isEmpty()) {
            Map<Id, Account> institucionesTopById = new Map<Id, Account>([
                SELECT Id FROM Account WHERE Id IN :institucionIds AND INSTITUCION_TOP__c = true
            ]);
            System.debug(institucionesTopById);
            for(Dan360_Lugar_de_Trabajo__c lugar : lugares) {
                if(institucionesTopById.keySet().contains(lugar.Institucion__c)
                    && String.isNotBlank(lugar.Profesional__c)
                ) {
                    Id idProfesional = mapPersonalAccount.get(lugar.Profesional__c);
                    Account profesionalTop = new Account(Id = idProfesional);
                    //Account profesionalTop = new Account(Id = lugar.Profesional__c);
                    profesionalTop.Trabaja_en_Institucion_Top__c = true;
                    
                    profesionalesTopToUpdate.add(profesionalTop);
                }
            }
            System.debug(profesionalesTopToUpdate);
            update new List<Account>(profesionalesTopToUpdate);
        }
    }

    public static void duplacateCheck(List<Dan360_Lugar_de_Trabajo__c> lugares){
        List<Id> profesionales = new List<Id>();
        Map<Id, List<Dan360_Lugar_de_Trabajo__c>> mapProfesionalLugares = new Map<Id, List<Dan360_Lugar_de_Trabajo__c>>();
        for(Dan360_Lugar_de_Trabajo__c lugar : lugares){
            if(!mapProfesionalLugares.containsKey(lugar.Profesional__c)){
                mapProfesionalLugares.put(lugar.Profesional__c, new List<Dan360_Lugar_de_Trabajo__c>());
            }
            mapProfesionalLugares.get(lugar.Profesional__c).add(lugar);
            profesionales.add(lugar.Profesional__c);
        }
        List<Dan360_Lugar_de_Trabajo__c> lugaresSalesforce = [SELECT id, Profesional__c,Institucion__c FROM Dan360_Lugar_de_Trabajo__c WHERE Profesional__c IN :profesionales];
        if(lugaresSalesforce.size() > 0){
            for(Dan360_Lugar_de_Trabajo__c lugar : lugaresSalesforce){
                if(mapProfesionalLugares.containsKey(lugar.Profesional__c)){
                    List<Dan360_Lugar_de_Trabajo__c> lugaresProfesionales = mapProfesionalLugares.get(lugar.Profesional__c);
                    for(Dan360_Lugar_de_Trabajo__c lugarToCheck : lugaresProfesionales){
                        if(lugarToCheck.Institucion__c == lugar.Institucion__c){
                            lugarToCheck.addError('Este lugar de trabajo ya existe. Duplicado:'+lugar.Id);
                        }
                    }
                }
            }
        }
        
    }
}