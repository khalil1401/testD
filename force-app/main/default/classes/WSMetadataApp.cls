@RestResource(urlMapping='/metadata/*')
global with sharing class WSMetadataApp {

    @HttpGet
    global static Respuesta doGet(){

        Id recordTypeFuncionalidad = Schema.SObjectType.VisMed_ConfigApp__c.getRecordTypeInfosByDeveloperName().get('Funcionalidad').getRecordTypeId();
        Id recordTypeObjeto = Schema.SObjectType.VisMed_ConfigApp__c.getRecordTypeInfosByDeveloperName().get('Objeto').getRecordTypeId();

        RestRequest req = RestContext.request;
        Respuesta respuesta = new Respuesta();
        
        Map<String, String> headers = new Map<String, String>();
        
        for(String header : req.headers.keySet()){
            headers.put(header.toLowerCase(),req.headers.get(header).toLowerCase());
        }
        
        String recordType = headers.containsKey('recordtype') ? headers.get('recordtype') : null;
        
        respuesta.forms = new List<Formulario>();

        if (recordType == 'funcionalidad') {
            for (VisMed_ConfigApp__c conf :[SELECT id, Name, Objeto_Principal__c, VisMed_Vista_Compacta__c, VisMed_Vista_Detalle__c,VisMed_Vista_Formulario__c FROM VisMed_ConfigApp__c WHERE VisMed_Activa__c = true AND RecordTypeId = :recordTypeFuncionalidad]) {
                respuesta.forms.add(new Formulario(conf));
            }
        } else if (recordType == 'objeto') {
            for (VisMed_ConfigApp__c conf :[SELECT id, Name, Objeto_Principal__c, VisMed_Vista_Compacta__c, VisMed_Vista_Detalle__c,VisMed_Vista_Formulario__c FROM VisMed_ConfigApp__c WHERE VisMed_Activa__c = true AND RecordTypeId = :recordTypeObjeto]) {
                respuesta.forms.add(new Formulario(conf));
            }
        }

        respuesta.status = 200;
        respuesta.message = 'OK';
        System.debug('Respuesta > '+ JSON.serialize(respuesta) );
        return respuesta;

    }
    
    global class Formulario {
        public String nombre {get;set;}
        public String id {get;set;}
        public String objetoPrincipal {get;set;}
        public String vistaCompacta {get;set;}
        public String vistaDetalle {get;set;}
        public String vistaFormulario {get;set;}
        
        public Formulario(VisMed_ConfigApp__c conf) {
        	this.nombre = conf.Name;
            this.id = conf.id;
            this.objetoPrincipal = conf.Objeto_Principal__c;
            this.vistaCompacta = conf.VisMed_Vista_Compacta__c;
            this.vistaDetalle = conf.VisMed_Vista_Detalle__c; 
            this.vistaFormulario = conf.VisMed_Vista_Formulario__c;
        }
    }
    
    global class Respuesta {
        public Integer status {get; set;}
        public String message {get;set;}
        public List<Formulario> forms {get; set;}
    }

}