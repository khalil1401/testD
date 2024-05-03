trigger TratamientoTrigger on Tratamiento__c (before insert, before update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        
        TratamientoTriggerHelper.updateAccountsAndTratamientos(Trigger.new);
        
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        
        List<Tratamiento__c> tratamientoList = new List<Tratamiento__c>(); 
        for(Tratamiento__c trat : Trigger.new){            
            Tratamiento__c oldTrat = Trigger.oldMap.get(trat.Id);        
            if(trat.Obra_social__c!= oldTrat.Obra_social__c){
                
                tratamientoList.add(trat);
            }
        }     
        if(!tratamientoList.isEmpty()){

            TratamientoTriggerHelper.updateAccount(tratamientoList);
        }
    }
}