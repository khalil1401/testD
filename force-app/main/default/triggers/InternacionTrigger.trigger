trigger InternacionTrigger on Internacion__c (before insert, after update,after insert) {
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            Map<Id, Internacion__c> internaciones = new  Map<Id, Internacion__c>();
            List<Internacion__c> internacionesClosedOrChangedDomiciliaria = new List<Internacion__c>();
            
            for(Internacion__c aInt : Trigger.new){
                Boolean isChangeDate = aInt.Fecha_de_Fin_Internaci_n__c != Trigger.oldMap.get(aInt.Id).Fecha_de_Fin_Internaci_n__c;
                Boolean isChangeInternacionDom = aInt.Paciente_Aguarda_Internaci_n_domiciliari__c!= Trigger.oldMap.get(aInt.Id).Paciente_Aguarda_Internaci_n_domiciliari__c ;
                if(isChangeDate && aInt.Fecha_de_Fin_Internaci_n__c!= null){
                    internaciones.put(aInt.Id, aInt);
                }
                if((aInt.Fecha_de_Fin_Internaci_n__c!=null && isChangeDate) ||
                   (isChangeInternacionDom && aInt.Paciente_Aguarda_Internaci_n_domiciliari__c))
                {
                    internacionesClosedOrChangedDomiciliaria.add(aInt);
                }
            }
            if(!internaciones.isEmpty()){
                InternacionTriggerHelper.closeProductsDate(internaciones);
            }
            if(!internacionesClosedOrChangedDomiciliaria.isEmpty()){
                InternacionTriggerHelper.updateAccountStatus(internacionesClosedOrChangedDomiciliaria);
            }
        }
        if(Trigger.isInsert){
            InternacionTriggerHelper.updateAccountStatus(Trigger.new);
        }
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            InternacionTriggerHelper.validateActiveInternacion(Trigger.new);
        }
    }
}