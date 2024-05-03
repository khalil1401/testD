@RestResource(urlMapping='/editRemoto/*')
global with sharing class WSEditRemoto {

    @HttpGet
    global static Respuesta doGet(){
        
        Respuesta respuesta = new Respuesta();
        RestRequest req = RestContext.request;
        String userName = req.headers.get('Username');
        
        List<ModApp__c> mods = [select id, id_app__c, Tipo__c, Estado__c, Usuario__c, Valor__c, Campo__c, Actual__c, Eliminar__c, Original__c from ModApp__c where usuario__c = :userName and enviado__c  = false];
        
        if (mods.size()>0) {
            respuesta.status = 200;
            respuesta.message = 'OK';
            respuesta.mods = mods;
            
            for (ModApp__c mod :mods) {
                mod.enviado__c = true;
            }
            
            update mods;
        }
        else {
            respuesta.status = 508;
            respuesta.message = 'Vacio';    
        }
        
        return respuesta;    
    }
    
    global class Respuesta {
        public Integer status {get; set;}
        public String message {get;set;}
        public List<ModApp__c> mods {get; set;}
    }
    
}