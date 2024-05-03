trigger EvitarEliminacionDeArchivos on ContentDocumentLink (before delete) {
    
    if(Trigger.isdelete && Trigger.isBefore){ 

        Id profileId= userinfo.getProfileId();
        
        String profileName=[
            Select Id,Name
            from Profile
            where Id=:profileId].Name;
        
        List<ContentDocumentLink> doclinks = [
            SELECT LinkedEntityId, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE Id IN: Trigger.oldMap.keySet()
        ];
        
        for(ContentDocumentLink doclink : doclinks){
            
            if(profileName == 'Profesional Best Care'){
                
                Trigger.oldMap.get(doclink.Id).addError('Permisos insuficientes para eliminar el archivo.');
                
            }
        }
        
    }
}