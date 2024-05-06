@RestResource(urlMapping='/info/*')
    global with sharing class WSValidateData {
        
        @HttpGet
        global static Respuesta doGet(){
            RestRequest req = RestContext.request;
            Respuesta respuesta = new Respuesta();
            Map<String, String> headers = new Map<String, String>();

            for(String header : req.headers.keySet()){
                headers.put(header.toLowerCase(),req.headers.get(header));
            }
            
            String sObjeto = headers.containsKey('objeto') ? headers.get('objeto') : null;
            String sName = headers.containsKey('name') ? headers.get('name') : null;
            String sCalle = headers.containsKey('calle') ? headers.get('calle') : null;
            String sLocalidad = headers.containsKey('localidad') ? headers.get('localidad') : null; 
            String sCP = headers.containsKey('codigoPostal') ? headers.get('codigoPostal') : null; 
            String sProvincia = headers.containsKey('provincia') ? headers.get('provincia') : null; 
            String sNumeroDeMatricula = headers.containsKey('matricula') ? headers.get('matricula') : null; 
            String sDni = headers.containsKey('dni') ? headers.get('dni') : null; 
            //comentarios para borrar
            System.debug('sObjeto::: ' + sObjeto);
            System.debug('sName::: ' + sName);
            System.debug('sCalle::: ' + sCalle);
            System.debug('sLocalidad::: ' + sLocalidad);
            System.debug('sNumeroDeMatricula::: ' + sNumeroDeMatricula);
            System.debug('sDni::: ' + sDni);

            if (sObjeto == 'institucion') {
                Id recordTypeInstitucion = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Institucion').getRecordTypeId();
                String condicion = 'RecordTypeId = \'' + recordTypeInstitucion + '\''; 
                condicion += (String.isNotBlank(sName) ? ' AND Name = \'' + sName + '\'' : '');
                condicion += (String.isNotBlank(sCalle) ? ' AND BillingStreet = \'' + sCalle + '\'' : ''); //BillingStreet
                condicion += (String.isNotBlank(sLocalidad) ? ' AND BillingCity = \'' + sLocalidad + '\'' : '');//BillingCity
                condicion += (String.isNotBlank(sCP) ? ' AND BillingPostalCode = \'' + sCP + '\'' : '');//BillingPostalCode
                condicion += (String.isNotBlank(sProvincia) ? ' AND BillingState = \'' + sProvincia + '\'' : '');//BillingState

                String query = 'SELECT Id, LastName, FirstName, Name, OwnerId, Calle__c, Codigo_postal__c, Numero__c, Piso__c, Departamento__c, Localidad__c, Provincia__c, Phone, RecordType.Name, BillingStreet, BillingCity, BillingPostalCode, BillingState FROM Account WHERE ' +
                condicion;
                System.debug('query:::' + query);
                List<Account> accounts  = Database.query(query);
                if (accounts.size()>0) {
                    respuesta.rObject = accounts.get(0);
                    respuesta.status = 200;
                } else {
                    respuesta.status = 401;
                }
            }  else if (sObjeto == 'profesional de la salud') {
                Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId(); 
                List<Dan360_Matricula__c> professionals = [SELECT Profesional__r.LastName, Profesional__r.FirstName, Profesional__r.Primera_especialidad__c, Profesional__r.Segunda_especialidad__c, Profesional__r.Tercera_especialidad__c 
                            FROM Dan360_Matricula__c 
                            WHERE Numero_de_matricula__c = :sNumeroDeMatricula AND Profesional__r.RecordTypeId = :recordTypeProfesional];
                if (professionals.size()>0) {
                    respuesta.rObject = professionals.get(0);
                    respuesta.status = 200;
                } else {
                    respuesta.status = 401;
                }
            } 
            else if (sObjeto == 'otro profesional') {
                Id recordTypeOtroProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Otro_Profesional').getRecordTypeId(); 
                List<Account> accounts = [SELECT Id, LastName, FirstName, Name, OwnerId, Primera_especialidad__c, Segunda_especialidad__c, Tercera_especialidad__c, VisMed_Areas_Terap_uticas__pc
                            FROM Account
                            WHERE DNI__c =: sDni AND RecordTypeId = :recordTypeOtroProfesional];
                if (accounts.size()>0) {
                    respuesta.rObject = accounts.get(0);
                    respuesta.status = 200;
                } else {
                    respuesta.status = 401;
                }
            } 
        return respuesta;
    }
    
    global class Respuesta {
        public Integer status {get; set;}
        public SObject rObject {get; set;}
    }
    
}