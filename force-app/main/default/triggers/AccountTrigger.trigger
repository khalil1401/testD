trigger AccountTrigger on Account(before insert, before update,after update,after insert) {
    
    If (Trigger.isBefore && Trigger.isInsert) {
        //ActualizarDomicilioObraSocialPaciente INICIO
        Id pacienteMendozaId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Paciente Partner').getRecordTypeId();
            List<Account> pacientesPartner = new List<Account>();
            for(Account acc : Trigger.new) {
                if(acc.RecordTypeId == pacienteMendozaId && acc.Obra_social__pc != null){
                    pacientesPartner.add(acc);
                }
            }
            AccountTriggerHelper.ActualizarDomicilioObraSocialPaciente(pacientesPartner);
        //ActualizarDomicilioObraSocialPaciente FIN
        
        //SETTEAR EL TIPO DE REGISTRO SEGUN EL TIPO DE SUCURSAL INGRESADO, 
        //EN CASO DE QUE TENGA EL CAMPO CUSTOMER ID, SE PONE EL TIPO DE REGISTRO CLIENTE
        
        Account clientePrincipal;
        
        for (Account cuenta : Trigger.New) {
            if (cuenta.Tipo_sucursal__c != null) {
                if (cuenta.Tipo_sucursal__c == 'SHIP_TO') {
                    
                    cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal de envío').getRecordTypeId();
                    
                } else if (cuenta.Tipo_sucursal__c == 'BILL_TO') {
                    
                    cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal de facturación').getRecordTypeId();
                    
                }
                
            } else if (cuenta.Id_customer_oracle__c != null) {
                
                cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
                
            }
        }
        
    }
    
    if (Trigger.isAfter) {
        
        
        //Esto tiene que ir en un before
        /*
List<Id> accountsIds = new List<id> ();
for (Account accIter : Trigger.New) {

id propNicho = trigger.oldMap.get(accIter.Id).Propietario_Nicho__c;
id propAd = trigger.oldMap.get(accIter.Id).Propietario_adulto__c;
id prop3 = trigger.oldMap.get(accIter.Id).Propietario_3__c;
id prop4 = trigger.oldMap.get(accIter.Id).Propietario_4__c;
id prop5 = trigger.oldMap.get(accIter.Id).Propietario_5__c;
id ownerID = trigger.oldMap.get(accIter.Id).OwnerId;

AccountTriggerHelper.validaQueEnLacuentaNoExistanDuplicados(accountsIds, accIter, propNicho, propAd, prop3, prop4, prop5, ownerID);

}
*/
    }
    
    if (Trigger.isAfter) {
        if(Trigger.IsUpdate){
            AccountTriggerHelper.insertaOactualizarEquipo(Trigger.new, Trigger.oldMap);
        }
       // AccountTriggerHelper.validaOperadoresPartner(Trigger.new);   // Falta pruebas de usuarios en UAT para pasar a Prod
    }
    if(Trigger.IsBefore){
        AccountTriggerHelper.validaQueEnLacuentaNoExistanDuplicados(Trigger.New);
        if(Trigger.isUpdate){
            //ActualizarDomicilioObraSocialPaciente INICIO
            Id pacienteMendozaId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Paciente Partner').getRecordTypeId();
            List<Account> pacientesPartner = new List<Account>();
            for(Account acc : Trigger.new) {
                if(acc.RecordTypeId == pacienteMendozaId && acc.Obra_social__pc != null && Trigger.oldMap.get(acc.Id).Obra_social__pc != acc.Obra_social__pc){
                    pacientesPartner.add(acc);
                }
            }
            AccountTriggerHelper.ActualizarDomicilioObraSocialPaciente(pacientesPartner);
            //ActualizarDomicilioObraSocialPaciente FIN
        }
    }
}