trigger AccountTrigger on Account (after insert, after update, before update) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            List<Account> accounts = new List<Account>();
            for(Account acc : Trigger.new){
                if(Trigger.oldMap.get(acc.Id).KOL__c != acc.KOL__c ||
                    Trigger.oldMap.get(acc.Id).PAC_0_12_MESES_SEM_C_COB_SOC__c != acc.PAC_0_12_MESES_SEM_C_COB_SOC__c ||
                    Trigger.oldMap.get(acc.Id).PAC_0_12_MESES_SEM_SIN_COB_SOC__c != acc.PAC_0_12_MESES_SEM_SIN_COB_SOC__c ||
                    Trigger.oldMap.get(acc.Id).Promedio_de_pacientes_Nicho__c != acc.Promedio_de_pacientes_Nicho__c ||
                    Trigger.oldMap.get(acc.Id).Trabaja_en_Institucion_Top__c != acc.Trabaja_en_Institucion_Top__c ||
                    Trigger.oldMap.get(acc.Id).Como_trabaja__c != acc.Como_trabaja__c){
                        accounts.add(acc);
                    }
            }
            if(accounts.size() >0){
                AccountTriggerHelper.guardarCategoriaAnterior(accounts);
            }
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            //Si es Profesional de la salud y cambia un campo relacionado a la frecuencia, chequea si hay q blanquear la frecuencia en la segmentacion.
            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
            List<Account> accounts = new List<Account>();
            for(Account acc : Trigger.new){
                if(acc.RecordTypeId == recordTypeProfesional){
                    accounts.add(acc);
                }
            }
            if(accounts.size() >0){
                AccountTriggerHelper.blanquearFrecuencia(accounts,Trigger.oldMap);
            }
            //Si cambia la marca EDI en el padre, se translada a todas las sucursales.
            List<Account> ediAccounts = new List<Account>();
            for(Account acc: Trigger.new){
                if(Trigger.oldMap.get(acc.Id).Cliente_EDI__c != acc.Cliente_EDI__c){
                    ediAccounts.add(acc);
                }
            }
            if(ediAccounts.size() > 0){
                AccountTriggerHelper.cambiarCheckEnSucursales(ediAccounts);
            }
        }
    }
}