@RestResource(urlMapping='/data2/')
global with sharing class WsPrueba {

    @ HttpGet
    global static Respuesta doGet(){

        RestRequest req = RestContext.request;
        Respuesta respuesta = new Respuesta();
        
        Map<String, String> headers = new Map<String, String>();
        
        for(String header : req.headers.keySet()){
            System.debug(header); 
            if(header.toLowerCase() != 'iddeluser'){
                headers.put(header.toLowerCase(),req.headers.get(header).toLowerCase());
            }
            else{
                system.debug(req.headers.get(header));
                headers.put(header.toLowerCase(),req.headers.get(header));
            }
        }
        
        String lastSyncString = headers.containsKey('lastsync') ? headers.get('lastsync') : null;
        String token = headers.containsKey('token') ? headers.get('token') : null;
        String objeto = headers.containsKey('objeto') ? headers.get('objeto') : null; 
        id user = headers.containsKey('iddeluser') ? id.valueOf(headers.get('iddeluser')) : null;

        System.debug('Objeto: ' + objeto);
        System.debug('Id Del User: ' + user);
        Map<Id,SObject> mapa = new Map<Id,SObject>();
        if (objeto == 'institucion') {
            Id recordTypeInstitucion = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Institucion').getRecordTypeId();            
            mapa = new Map<Id,SObject>([SELECT Id, LastName, FirstName, Name, OwnerId
                                  FROM Account
                                  WHERE RecordTypeId = :recordTypeInstitucion]);
        } 
       /* else if (objeto == 'profesional de la salud') {
            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId(); 
            respuesta.sobjects = [SELECT Id, LastName, FirstName, Name, OwnerId, Primera_especialidad__c, Segunda_especialidad__c, Tercera_especialidad__c, VisMed_Areas_Terap_uticas__pc 
                                  FROM Account
                                  WHERE RecordTypeId = :recordTypeProfesional];
        } 
        else if (objeto == 'otro profesional') {
            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Otro_Profesional').getRecordTypeId(); 
            respuesta.sobjects = [SELECT Id, LastName, FirstName, Name, OwnerId, Primera_especialidad__c, Segunda_especialidad__c, Tercera_especialidad__c, VisMed_Areas_Terap_uticas__pc 
                                  FROM Account
                                  WHERE RecordTypeId = :recordTypeProfesional];
        } 
        else if (objeto == 'ciclo') {
            respuesta.sobjects = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, 
                                  Anio__c, Fecha_de_inicio__c, Fecha_de_Fin__c, VisMed_Cmpt_Tiempo_no_promocional__c, Numero_de_mes__c
                                  FROM VisMed_Ciclo__c];
        } 
        else if (objeto == 'efectivdad') {
            respuesta.sobjects = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, 
                                  VisMed_Codigo_de_duplicidad__c, VisMed_Promedio__c, Dias_de_Licencia__c, Tiempo_no_promocional__c, Dias_feriados__c, Fecha_de_inicio__c, Fecha_de_Fin__c, 
                                  Dias_de_campo_efectivo__c, Dias_habiles_transcurridos__c, VisMed_Visitas_restantes__c, VisMed_APM__c, VisMed_Target_Diario__c, Dias_habiles_del_ciclo__c, 
                                  VisMed_Visitas_realizadas__c, VisMed_Ciclo__c, VisMed_Efectividad__c, VisMed_Cmpt_Tiempo_no_promocional__c
                                  FROM Dan360_Efectividad__c
                                  WHERE VisMed_APM__r.OwnerId = :user];
        } 
        else if (objeto == 'interaccion') {
            respuesta.sobjects = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, 
                                  LastReferencedDate, VisMed_Codigo_de_duplicidad__c, Estado__c, VisMed_Profesional__c, VisMed_Domicilio_de_la_Visita__c, VisMed_APM__c, VisMed_Tipo_de_Visita__c, 
                                  VisMed_Motivo__c, VisMed_Efectividad__c, VisMed_Canal__c, VisMed_Comentarios__c, VisMed_Fecha__c
                                  FROM Dan360_Interacciones__c
                                  WHERE VisMed_APM__r.OwnerId = :user];
        } 
        else if (objeto == 'licencia') {
            respuesta.sobjects = [SELECT Id, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, 
                                  LastReferencedDate, Motivo__c, Fecha_de_inicio__c, Fecha_de_Fin__c, VisMed_Codigo_de_duplicidad__c, Estado__c, Comentarios__c, Cantidad_de_Horas__c, Cantidad_de_Dias__c, 
                                  VisMed_Cantidad_de_Horas_Numerico__c, Efectividad__c, Cantidad_de_Horas_Valor__c, VisMed_APM__c
                                  FROM Dan360_Licencia__c
                                  WHERE VisMed_APM__r.OwnerId = :user];
        } 
        else if (objeto == 'seguimiento') {
            respuesta.sobjects = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate,
                                  Institucion__c, Ultima_Visita__c, Visitador__c, Profesional__c, Predeterminada__c
                                  FROM VisMed_Contacto_Cuenta_Usuario__c
                                  WHERE Visitador__r.OwnerId  = :user];
        }
        else if (objeto == 'equipo de cuentas') {
            respuesta.sobjects = [SELECT Id, AccountId, UserId, TeamMemberRole, PhotoUrl, Title, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel, CreatedDate, CreatedById, 
                                  LastModifiedDate, LastModifiedById, SystemModstamp, IsDeleted, Dan360_Areas_Terapeuticas__c
                                  FROM AccountTeamMember
                                  WHERE UserId = :user];
        }
        else if (objeto == 'matricula') {
            respuesta.sobjects = [SELECT Id, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Provincia__c, 
                                  Numero_de_matricula__c, Profesional__c, Municipios__c
                                  FROM Dan360_Matricula__c];
        }
        else if (objeto == 'lugares de trabajo') {
            respuesta.sobjects = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Cargo__c, 
                                  Dias_de_Atencion__c, Visitador__c, Institucion__c, Profesional__c
                                  FROM Dan360_Lugar_de_Trabajo__c];
        }*/
        
        respuesta.registros = new List<lista>();
		if(!mapa.keyset().IsEmpty()){
            system.debug(mapa);
            for(String key : mapa.keyset()){
                lista lis = new lista();
                lis.clave = key;
                lis.objeto = mapa.get(key);
                system.debug(lis);
                respuesta.registros.add(lis);
            }
        }
        return respuesta;
    }
    
    global class Respuesta {
        public Integer status {get; set;}
        public String message {get;set;}
        public String response {get; set;}
        public List<lista> registros {get; set;}
    }
    
    global class lista {
        public String clave {get;set;}
        public SObject objeto {get;set;}
    }

}