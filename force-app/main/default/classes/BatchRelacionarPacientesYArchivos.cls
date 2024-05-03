public class BatchRelacionarPacientesYArchivos implements Database.Batchable<sObject>, Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
		system.debug('query');
        return Database.getQueryLocator(
            'SELECT Id, ContentDocumentId, dni_fileupload__c ' +
            'FROM ContentVersion '+
            'WHERE dni_fileupload__c != null'
        );

    }

    public void execute(Database.BatchableContext bc, List<ContentVersion> scope){
		system.debug(scope);
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        List<Task> tareasPSP = new List<Task>();
        Map<String, ContentVersion> mapDocs = new Map<String, ContentVersion>();
        Map<Id, List<ContentVersion>> mapContentDocIdContVersion = new Map<Id, List<ContentVersion>>();
        List<String> nombresCuentas = new List<String>();
        Id pacienteRegularId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        //Map de campo personalizado en contectVersion y el contentVersion correspondiente
        Map<String, ContentVersion> mapFileUpload = new Map<String, ContentVersion>();

        //Se agregan los dni y atchivos a un map
        //Se agregan los ContentDocumentId y sus contentVersion a otro Map
        for (ContentVersion doc : scope) {
            List<String> datos = doc.dni_fileupload__c.split('-');
            mapDocs.put(datos.get(1), doc);
            mapFileUpload.put(doc.dni_fileupload__c, doc);
            nombresCuentas.add(returnValidName(datos.get(0)));
            if(!mapContentDocIdContVersion.containsKey(doc.ContentDocumentId)){
                mapContentDocIdContVersion.put(doc.ContentDocumentId,new List<ContentVersion>{doc});
            }
            else{
                List<ContentVersion> listita = mapContentDocIdContVersion.get(doc.ContentDocumentId);
                listita.add(doc);
                mapContentDocIdContVersion.put(doc.ContentDocumentId,listita);
            }
            
        }

        //Se buscan los pacientes que esten relacionados con el nombre y apellido y DNI del archivo
        List<Account> pacientes = [
            SELECT  Id, DNI__c, Name
            FROM    Account
            WHERE   DNI__c IN : mapDocs.keySet()
                AND Name IN: nombresCuentas
                AND RecordTypeId =: pacienteRegularId
        ];

        System.debug('pacientes');
        System.debug(pacientes);

        List<Contact> contactos = [
            SELECT  Id, DNI__c
            FROM    Contact
            WHERE   DNI__c IN: mapDocs.keySet()
                AND Principal__c =: true
        ];

        List<Contacto_de_paciente__c> contactosDePaciente = [
            SELECT  Id, Paciente__c, Contacto__r.DNI__c, Paciente__r.Name
            FROM    Contacto_de_paciente__c
            WHERE   Contacto__c in : contactos
                AND Paciente__r.Name IN: nombresCuentas
        ];

        if (!contactosDePaciente.isEmpty()) {
            for (Contacto_de_paciente__c contactoDePaciente : contactosDePaciente) {
                pacientes.add(new Account(  Id = contactoDePaciente.Paciente__c,
                                            Name = contactoDePaciente.Paciente__r.Name,
                                            DNI__c = contactoDePaciente.Contacto__r.DNI__C));
            }
        }

        Group psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
                AND NAME = 'PSP'
            LIMIT 1
        ];

        Set<Id> cuentasTareas = new Set<Id>();
        //Se agregan los links de los archivos y los pacientes y se crean las tareas para el PSP
        for (Account paciente : pacientes) {
            if(!cuentasTareas.contains(paciente.Id)) {
                //Relaciono el documento y el paciente
                ContentDocumentLink newLink = new ContentDocumentLink();
                newLink.LinkedEntityId = paciente.Id;
                newLink.ContentDocumentId = mapDocs.get(paciente.DNI__c).ContentDocumentId;
                newLink.ContentDocumentId = mapFileUpload.get(paciente.Name + '-' + paciente.DNI__c).ContentDocumentId;
                newLink.ShareType = 'v';
                links.add(newLink);
                //Genero la tarea para el PSP
                Task tareaPacienteWeb = new Task();
                tareaPacienteWeb.Type = 'Alta paciente via web';
                tareaPacienteWeb.Status = 'Abierta';
                tareaPacienteWeb.Subject = 'Alta Paciente Via Web';
                tareaPacienteWeb.WhatId = paciente.Id;
                tareaPacienteWeb.RecordTypeId = XappiaHelper.getRecordType('Task', 'Tarea').Id;
                tareaPacienteWeb.OwnerId = psp.Id;
                tareasPSP.add(tareaPacienteWeb);

                cuentasTareas.add(paciente.Id);
            }
        }

        if(!links.isEmpty()) {
            insert links;

            //Limpio el nombre, apellido y DNI del contentVersion
            List<ContentVersion> cvToUpdate = new List<ContentVersion>();

            for(ContentDocumentLink cdl : links){
                if(mapContentDocIdContVersion.containsKey(cdl.ContentDocumentId)){
                    cvToUpdate.addAll(mapContentDocIdContVersion.get(cdl.ContentDocumentId));
                }
            }
            
            if(!cvToUpdate.isEmpty()){
                for(ContentVersion cv : cvToUpdate){
                    cv.dni_fileupload__c = null;
                }
            }
            
            update cvToUpdate;
        }
        if(!tareasPSP.isEmpty()) {
            insert tareasPSP;
        }

    }
    
    public static String returnValidName(String nombreCompleto){
        
        String nombreToReturn = '';
        for(String partName : nombreCompleto.split(' ')){
            if(String.isNotBlank(partName)){
                nombreToReturn += partName.trim()+' ';
            }
        }
        return nombreToReturn.trim();
        
    }
    
    public void finish(Database.BatchableContext bc){
    }

}