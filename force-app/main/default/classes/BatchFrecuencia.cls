public with sharing class BatchFrecuencia /*implements Database.Batchable<sObject>*/ {
    /*
    public Database.QueryLocator start (Database.BatchableContext bc) {
        Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId(); 
        Id recordTypeOtroProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Otro_Profesional').getRecordTypeId(); 
        return Database.getQueryLocator([SELECT Id, AccountId, UserId, User.Segmenta_Por__C, Ultima_Visita__c, Dan360_Areas_Terapeuticas__c, Frecuencia__c, Inicio_de_Frecuencia__c, Aun_Quedan_Meses__c, Visitas_Realizadas__c, Visitas_Restantes__c FROM AccountTeamMember WHERE Account.RecordTypeId = :recordTypeProfesional OR Account.RecordTypeId = :recordTypeOtroProfesional]);
    }

    public void execute (Database.BatchableContext BC, list<AccountTeamMember> accountsTeam) {
        //String recordTypeName = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosById().get(segmentacion.RecordTypeId).getName();
        Set<Id> usersId = new Set<Id>();
        Set<Id> profesionalesId = new Set<Id>();
        List<VisMed_Segmentacion__c> segmentaciones;
        List<AccounTeamWrapper> accountsTeamWrapperList = new List<AccounTeamWrapper>();
        List<Frecuencia_por_Categoria__mdt> mdtList = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Categoria__c, Frecuencia__c, Equipo__c FROM Frecuencia_por_Categoria__mdt];
        List<AccountTeamMember> accountsTeamsToUpsert = new List<AccountTeamMember>();
        Map<Id,Set<Id>> profesionalesXapm = new Map<Id,Set<Id>>();
        Map<Id,String> segmentacionDelAPM = new Map<Id,String>();
        Map<Id,AccountTeamMember> mapAccountTeam = new Map<Id,AccountTeamMember>();

        for (AccountTeamMember accountTeam : accountsTeam) {
            Set<Id> profesionalesAUX;
            usersId.add(accountTeam.UserId);
            profesionalesId.add(accountTeam.AccountId);
            profesionalesAUX = profesionalesXapm.containsKey(accountTeam.UserId) ? profesionalesXapm.get(accountTeam.UserId) : new Set<Id>();
            profesionalesAUX.add(accountTeam.AccountId);
            profesionalesXapm.put(accountTeam.UserId, profesionalesAUX);
            segmentacionDelAPM.put(accountTeam.UserId, accountTeam.User.Segmenta_Por__C);
            mapAccountTeam.put(accountTeam.Id, accountTeam);   
            AccounTeamWrapper accounTeamWraper = new AccounTeamWrapper(
                accountTeam.UserId,
                accountTeam.AccountId,
                accountTeam.User.Segmenta_Por__C,
                accountTeam
            );
            accountsTeamWrapperList.add(accounTeamWraper);
        }

        segmentaciones = [SELECT Id, Categoria__c, RecordTypeId, RecordType.Name FROM VisMed_Segmentacion__c WHERE Profesional__c IN :profesionalesId];

        for (VisMed_Segmentacion__c segmentacion : segmentaciones) {
            for (AccounTeamWrapper accountTeamWrapper : accountsTeamWrapperList) {
                if (profesionalesXapm.get(accountTeamWrapper.user).contains(segmentacion.Profesional__c)) {
                    if (accountTeamWrapper.account == segmentacion.Profesional__c && accountTeamWrapper.segmentacion == segmentacion.RecordType.Name) {
                        AccountTeamMember upsertAccountTeam = mapAccountTeam.get(accountTeamWrapper.accountTeam.Id);
                        for (Frecuencia_por_Categoria__mdt mdt : mdtList) {
                            if (accountTeamWrapper.segmentacion == mdt.Equipo__C && segmentacion.Categoria__c == mdt.Categoria__c) {
                                upsertAccountTeam.Frecuencia__c = mdt.Frecuencia__c;
                            }
                        }
                        if (string.ValueOf(upsertAccountTeam.Frecuencia__c).endsWith('.0')) {
                            upsertAccountTeam.Visitas_Realizadas__c = 0;
                            upsertAccountTeam.Aun_Quedan_Meses__c = false;
                            upsertAccountTeam.Inicio_de_Frecuencia__c = System.today().toStartOfMonth().addMonths(1);
                        } else if (upsertAccountTeam.Inicio_de_Frecuencia__c.month() == System.today().month()) {
                            upsertAccountTeam.Aun_Quedan_Meses__c = true;
                            upsertAccountTeam.Visitas_Realizadas__c = 0;
                        } else if (upsertAccountTeam.Inicio_de_Frecuencia__c.month() != System.today().month()) {
                            upsertAccountTeam.Aun_Quedan_Meses__c = false;
                            upsertAccountTeam.Inicio_de_Frecuencia__c = System.today().toStartOfMonth().addMonths(1);
                        }
                        accountsTeamsToUpsert.add(upsertAccountTeam);
                    }
                }
            }
        }
        upsert accountsTeamsToUpsert;
    }

    public void finish (Database.BatchableContext BC) {
        // execute any post-processing operations
    }

    public class AccounTeamWrapper {
        public Id user;
        public Id account;
        String segmentacion;
        public AccountTeamMember accountTeam;

        public AccounTeamWrapper (Id user, Id account, String segmentacion, AccountTeamMember accountTeam) {
            this.user = user;
            this.account = account;
            this.segmentacion = segmentacion;
            this.accountTeam = accountTeam;
        }
    }*/

}