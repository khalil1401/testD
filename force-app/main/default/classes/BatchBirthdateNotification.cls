global class BatchBirthdateNotification implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext param1) {
        Id recordTypeProfesionalDeLaSalud = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
        Id recordTypeOtroProfesional= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Otro_Profesional').getRecordTypeId();
        String query = 'SELECT Id, Name, PersonBirthdate' +
            ' FROM Account WHERE (recordTypeId=: recordTypeProfesionalDeLaSalud' +  
            ' OR recordTypeId=: recordTypeOtroProfesional)' +
            ' AND PersonBirthdate = TODAY';
        return Database.getQueryLocator(query);
    }

    global Set<Id> accountIds = new Set<Id>();

    global void execute(Database.BatchableContext param1, List<Account> scope) {
        System.debug(scope);
        List<VisMed_Contacto_Cuenta_Usuario__c> listaSeguimiento = New List<VisMed_Contacto_Cuenta_Usuario__c>();   

        for(Account a : scope){
            accountIds.add(a.Id);
        }

        listaSeguimiento = [SELECT Id, Profesional__c, Profesional__r.Name, VisMed_APM__c FROM VisMed_Contacto_Cuenta_Usuario__c WHERE Profesional__c IN :accountIds AND (Estado__c = 'Activo' OR Estado__c = 'Baja Temporal' OR Estado__c = 'Pendiente')];
        Map<String, VisMed_Contacto_Cuenta_Usuario__c> seguimientoProfesionalXAPM = new Map<String, VisMed_Contacto_Cuenta_Usuario__c>();
        for(VisMed_Contacto_Cuenta_Usuario__c seguimiento : listaSeguimiento) {
            String keyString = seguimiento.Profesional__c + '-' + seguimiento.VisMed_APM__c;
            seguimientoProfesionalXAPM.put(keyString, seguimiento);
        }

        List<Notificacion__c> notificaciones = new List<Notificacion__c>();
        String titulo;
        String cuerpo;
        String redireccion = 'Profesional';

        if (!listaSeguimiento.isEmpty()) {
            for(VisMed_Contacto_Cuenta_Usuario__c seguimiento : seguimientoProfesionalXAPM.values()){    
                    titulo = 'Cuampleaños de un Profesional';
                    cuerpo = 'Hoy es el cumpleaños de ' + seguimiento.Profesional__r.Name + ' no te olvides de felicitarlo.';
                Notificacion__c notificacion = new Notificacion__c(
                    APM__c = seguimiento.VisMed_APM__c,
                    Name = titulo,
                    Cuerpo__c = cuerpo,
                    Leido__c = false,
                    Relacion__c = redireccion,
                    Id_del_Objeto__c = seguimiento.Profesional__c
                );
                notificaciones.add(notificacion);
            }
            insert notificaciones;
        }
    }  

    global void finish(Database.BatchableContext param1) {
        System.debug('Batch Job Birthdate Notification Completed'); 
    }
}