trigger InteractionTrigger on Interaccion__c (before insert, after insert)  {
    Map<Id, String> recordTypeDevNameById = new Map<Id, String>();
    for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType 
                         WHERE SobjectType = 'Interaccion__c'
                         AND IsActive = true]){
                             recordTypeDevNameById.put(rt.Id, rt.DeveloperName);
                         }
    
    //Separate interactions by their record type
    Map<String, List<Interaccion__c>> interactionsByRecordType = new Map<String, List<Interaccion__c>>();
    for(Interaccion__c interaction : Trigger.new) {
        String rtName = recordTypeDevNameById.get(interaction.RecordTypeId);
        if(!interactionsByRecordType.containsKey(rtName)) {
            interactionsByRecordType.put(rtName, new List<Interaccion__c>());
        }
        interactionsByRecordType.get(rtName).add(interaction);
    }
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
           
            if(interactionsByRecordType.containsKey('Visita_medica')){
                List<Interaccion__c> visitasMedicas = new List<Interaccion__c>();
                visitasMedicas.addAll(interactionsByRecordType.get('Visita_medica'));
                InteractionTriggerHelper.validateVisitasMedicasInteracciones(visitasMedicas);
            }     
        }
    }
    if(Trigger.isBefore){
        Id profileId= userinfo.getProfileId();
        
        String userLicencieName=[
            SELECT Id,Name,UserLicense.Name 
            FROM Profile 
            WHERE Id=:profileId].UserLicense.Name;

        if(userLicencieName == 'Partner Community'){
            List<Interaccion__c> interactionList = new List<Interaccion__c>();
            for(Interaccion__c interaction : Trigger.new) {
                interactionList.add(interaction);
            }         
            if(!interactionList.isEmpty()){
                InteractionTriggerHelper.validacionParaCargaDeInteracciones(interactionList);
            }
        }
    }
}