public without sharing class FormularioLoginController {

    @AuraEnabled(cacheable=true)
    public static User getDataUser(Id userId){
        String queryUsers = 'SELECT Id, FirstName, LastName, Profile.Name FROM User WHERE Id = \'' + String.escapeSingleQuotes(userId) + '\'';
        List<User> users = Database.query(queryUsers);

        if(!users.isEmpty()) {
            return users.get(0);
        }
        else {
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getPacientes(String dni) {
        Id recordTypeIdPacienteRegular= XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        Id recordTypeIdPacienteBestCare = XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id;
        List<Account> pacientes = new List<Account>();
        Set<Id> contactosDeDNI = new Map<Id, Contact>([
            SELECT  Id
            FROM    Contact
            WHERE   DNI__c =: dni
                AND Principal__c =: true
        ]).keySet();
        String queryAccounts = 'SELECT Id, FirstName, Lastname, DNI__c FROM Account WHERE (RecordTypeId =: recordTypeIdPacienteRegular OR RecordTypeId =: recordTypeIdPacienteBestCare) AND DNI__c = \'' + String.escapeSingleQuotes(dni) + '\'';
        List<Account> pacienteDeDNI = Database.query(queryAccounts);

        if (!pacienteDeDNI.isEmpty()) {
            pacientes.add(pacienteDeDNI.get(0));
        }

        if (!contactosDeDNI.isEmpty()) {
            Set<Id> idsPacientesDeContactos = new Set<Id>();
            List<Contacto_de_paciente__c> contactosDePaciente = [
                SELECT  Id, Paciente__c
                FROM    Contacto_de_paciente__c
                WHERE   Contacto__c in : contactosDeDNI
                    AND Principal__c =: true
            ];
            for (Contacto_de_paciente__c contactoDePaciente : contactosDePaciente) {
                idsPacientesDeContactos.add(contactoDePaciente.Paciente__c);
            }
            
            List<Account> pacientesDeContactos = [
                SELECT  Id, FirstName, Lastname, DNI__c
                FROM    Account
                WHERE   Id in : idsPacientesDeContactos
                AND (RecordTypeId =: recordTypeIdPacienteRegular
                    OR RecordTypeId =: recordTypeIdPacienteBestCare)
            ];
            
            if (!pacientesDeContactos.isEmpty()) {
                for (Account pacienteDeContacto : pacientesDeContactos) {
                    pacientes.add(pacienteDeContacto);
                }
            }
        }

        return pacientes;
    }

    @AuraEnabled(cacheable=true)
    public static User getUser(Id idPaciente) {
        String queryPacientes = 'SELECT Id, PersonContactId FROM Account WHERE Id = \'' + String.escapeSingleQuotes(idPaciente) + '\'';
        List<Account> pacientes = Database.query(queryPacientes);

        if(!pacientes.isEmpty()){
            List<User> usuarioPaciente = [
                SELECT  Id, UserName
                FROM    User
                WHERE   ContactId =: pacientes.get(0).PersonContactId
                LIMIT 1
            ];
    
            if (!usuarioPaciente.isEmpty()) {
                return usuarioPaciente.get(0);
            }
            else {
                return null;
            }
        }

        return null;
    }
 
    @AuraEnabled
    public static String site(String username, String pass) {
        String un = String.escapeSingleQuotes(username);
        String p = String.escapeSingleQuotes(pass);

        try {
            ApexPages.PageReference lgn = Site.login(un, p, '');
            aura.redirect(lgn);
            return 'Login success';
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getEmailUsuario(String username) {
        String correo = '';
        String queryUsers = 'SELECT Id, Email FROM User WHERE UserName = \'' + String.escapeSingleQuotes(username) + '\'';
        List<User> users = Database.query(queryUsers);

        if(!users.isEmpty()){
            List<String> emails = users.get(0).Email.split('@');
            String primeraParte = emails[0];
            String segundaParte = emails[1];
    
            correo = primeraParte.substring(0,3);
            
            for (Integer j = 3; j < primeraParte.length(); j++) {
                correo = correo + '*';
            }
    
            correo += '@' + segundaParte;
    
            return correo;
        }
        else {
            return null;
        }
    }

    @AuraEnabled
    public static String restablecerPass(String username) {
        try {
            String queryUsers = 'SELECT Id FROM User WHERE UserName = \'' + String.escapeSingleQuotes(username) + '\'';
            List<User> users = Database.query(queryUsers);    

            if(!users.isEmpty()){
                System.resetPasswordWithEmailTemplate(users.get(0).Id, true, 'Portal_Pacientes_Cambio_de_contrase_a_de_miembro');                
                return 'reset correcto';
            }
            else {
                return null;                
            }
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }
}