@RestResource(urlMapping='/login/*')
global with sharing class WSLoginApp {

    @HttpGet
    global static Respuesta doGet(){

        RestRequest req = RestContext.request;
        Respuesta respuesta = new Respuesta();
        Map<String, String> headers = new Map<String, String>();
        
        for (String header : req.headers.keySet()) {
            System.debug(header); 
            headers.put(header.toLowerCase(),req.headers.get(header).toLowerCase());
        }
        String userName = headers.containsKey('username') ? headers.get('username') : null;
        String token = headers.containsKey('token') ? headers.get('token') : null;
        String lastSyncString = headers.containsKey('lastSyncString') ? headers.get('lastSyncString') : null;

        System.debug('Username: ' + userName);
        System.debug('Token: ' + token);
        
        //Valido el user.
        List<User> users = [SELECT id, VisMed_ContrasenaApp__c, Profile.Name, ContactId, Name, Email FROM User WHERE username = :userName];
        if (users.size()>0 && users.get(0).	VisMed_ContrasenaApp__c == token) {
            respuesta.user = users.get(0);
            respuesta.status = 200;
            respuesta.message = 'Usuario y Password Correctos';
            
            return respuesta;
        }
        else {
            respuesta.status = 401;
            respuesta.message = 'Usuario o Password Incorrectos';
            
            return respuesta;
        }
    }
    
    global class Respuesta {
        public Integer status {get; set;}
        public String message {get;set;}
        public User user {get; set;}
    }

}