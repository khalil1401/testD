public with sharing class AccountTriggerHelper {
   
    public static void guardarCategoriaAnterior (List<Account> listAccount){
        List<String> idsAccounts = new List<String>();
        
        for(Account acc : listAccount){
            idsAccounts.add(acc.Id);
        }

        List<VisMed_Segmentacion__c> segmentacionesToUpdate = new List<VisMed_Segmentacion__c>();
        for(VisMed_Segmentacion__c segmentacion : [SELECT Name, Categoria__c, Categoria_Anterior__c, Categoria_Auxiliar__c, RecordTypeId FROM VisMed_Segmentacion__c WHERE Profesional__c IN : idsAccounts]){
            segmentacion.Categoria_Auxiliar__c = segmentacion.Categoria__c;
            segmentacionesToUpdate.add(segmentacion);
        }
        if(!segmentacionesToUpdate.isEmpty()){
            Database.update(segmentacionesToUpdate, false);
        }
        

    }


    public static void blanquearFrecuencia(List<Account> listAccount, Map<Id,Account> oldMap){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        List<Schema.FieldSetMember> apisName = SObjectType.Account.FieldSets.categoria.getFields();
        List<String> fieldsToCheck = new List<String>();
        List<String> idsAccounts = new List<String>();
        List<VisMed_Segmentacion__c> segmentacionesToUpdate = new List<VisMed_Segmentacion__c>();

        //Guardo los ApiName de los campos que esta en el fieldset 'categoria'
        for(Schema.FieldSetMember f : apisName){
            fieldsToCheck.add(f.getFieldPath());
        }

        //Por cada cuenta me traigo los campos que estan en el fieldset y comparo si los valores cambiaron.
        for(Account acc : listAccount){
            Account oldAccount = oldMap.get(acc.id);
            for(String fieldName: fieldMap.keySet()){
                for(String field : fieldsToCheck){
                    if(fieldName == field && oldAccount.get(fieldName) != acc.get(fieldName)){
                        idsAccounts.add(acc.id);
                        break;
        	        }
                }
            }
        }  

        //Si algun valor cambio, se agrega (la cuenta) a la lista y se procede a poner null la frencuencia si la categoria esta vacia.
        if(!idsAccounts.isEmpty()){
            for(VisMed_Segmentacion__c segmentacion : [SELECT Name, Categoria__c, Categoria_Anterior__c, Categoria_Auxiliar__c, RecordTypeId FROM VisMed_Segmentacion__c WHERE Profesional__c IN : idsAccounts]){
                if(String.isEmpty(segmentacion.Categoria__c)){
                    segmentacion.Frecuencia__c = null;
                }
                segmentacionesToUpdate.add(segmentacion);
            }
        }
        
        if(!segmentacionesToUpdate.isEmpty()){
            Database.update(segmentacionesToUpdate, false);
        }
    }


    public static void cambiarCheckEnSucursales(List<Account> listAccounts){
        Map<String,Boolean> accountsSF = new Map<String,Boolean>();

        for(Account acc : listAccounts){
            System.debug(acc.Cliente_EDI__c);
            if(!accountsSF.containsKey(acc.Id)){
                accountsSF.put(acc.Id,acc.Cliente_EDI__c);
            }
        }

        List<Account> accountsToUpdate = new List<Account>();
        for(Account accountSF : [SELECT id, Cliente_EDI__c, ParentId FROM Account WHERE ParentId IN: accountsSF.keySet()]){
            System.debug(accountSF.Cliente_EDI__c);
            Boolean ediCheck = accountsSF.get(accountSF.ParentId);

            accountSF.Cliente_EDI__c = ediCheck;
            accountsToUpdate.add(accountSF);
        }
        System.debug(accountsToUpdate);
        if(accountsToUpdate.size()>0){
            Database.update(accountsToUpdate,false);
        }
    }

}