trigger CycleForContactsTrigger on User (after insert) {

	if (Trigger.isAfter && Trigger.isInsert) {
        Id recordTypeId = XappiaHelper.getRecordType('Contact', 'Visitador médico').Id;
        Map<Id,User> mapUsuarios = new Map<Id,User>([
            SELECT Id, Contact.RecordTypeId
            FROM User
            WHERE Id in :Trigger.new
        ]);
        for (User usuario : Trigger.new) {
            if(mapUsuarios.containsKey(usuario.id) && mapUsuarios.get(usuario.id).Contact.RecordTypeId == recordTypeId){
                CycleForContactsHelper.cyclesForContactTrigger(usuario.Id);                
            }
        }
    }

}