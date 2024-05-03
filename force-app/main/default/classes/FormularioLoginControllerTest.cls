@IsTest
public class FormularioLoginControllerTest {

    @IsTest
    static void testSiExisteUnaCuentaRegistradaConElDNISeDebeDevolver() {
        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .withDNI('12345678')
            .build();
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert account;

        Test.startTest();
            List<Account> pacientes = FormularioLoginController.getPacientes(account.DNI__c);
        Test.stopTest();

        List<Account> cuentasDePacientes = [
            SELECT Id, DNI__c
            FROM Account
            WHERE Id =: account.Id
        ];

        System.assertEquals(cuentasDePacientes.get(0).DNI__c, account.DNI__c, 
            'No se encontro el paciente con el dni logeado');
    }

    @IsTest
    static void testSiExisteUnaCuentaRelacionadaConUnContactoSeDebeDevolver() {
        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert account;

        List<Contact> contactosDePaciente = new List<Contact>();
        Contact contact = Build.aContact()
            .withLastName('Last Name Contact')
            .build();
        contact.Relacion__c = 'Madre';
        contact.DNI__c = '1234';
        contact.Principal__c = true;
        contact.Es_de_Community__c	= true;
        contact.RecordTypeId = XappiaHelper.getRecordType('Contact', 'Contacto de paciente').Id;
        
        contactosDePaciente.add(contact);
        FormularioRegistroController.saveContacts(contactosDePaciente, account.Id);

        Test.startTest();
            List<Account> pacientes = FormularioLoginController.getPacientes(contact.DNI__c);
        Test.stopTest();

        List<Account> cuentasDePacientes = [
            SELECT Id, LastName
            FROM Account
            WHERE Id =: account.Id
        ];

        System.assertEquals(cuentasDePacientes.get(0).LastName, account.LastName, 
            'No se encontro el paciente con el dni del contacto a cargo');
    }

    @IsTest
    static void testSiExistePacienteConUsuarioSeDebeDevolverUserName() {
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert paciente; 

        Account pacienteDB = [
            SELECT  PersonContactId
            FROM    Account
            WHERE   Id =: paciente.Id
        ];

        Profile profile = [
            SELECT Id
            FROM Profile
            WHERE Name =: 'Paciente Oncología'
            LIMIT 1
        ];

        User usuarioDePaciente = new User();
        usuarioDePaciente.ProfileId = profile.Id;
        usuarioDePaciente.Username = paciente.PersonEmail;
        usuarioDePaciente.Alias = '3243';
        usuarioDePaciente.Email = 'test@test.com';
        usuarioDePaciente.EmailEncodingKey = 'UTF-8';
        usuarioDePaciente.FirstName = paciente.FirstName;
        usuarioDePaciente.Lastname = paciente.LastName;
        usuarioDePaciente.LanguageLocaleKey = 'es';
        usuarioDePaciente.LocaleSidKey = 'es';
        usuarioDePaciente.TimeZoneSidKey = 'America/Argentina/Buenos_Aires';
        usuarioDePaciente.ContactId = pacienteDB.PersonContactId;
        insert usuarioDePaciente;

        Test.startTest();
            User user = FormularioLoginController.getUser(paciente.Id); 
        Test.stopTest();

        System.assertEquals(paciente.PersonEmail, user.UserName,
            'No se encontró el usuario correcto para el paciente');
    }

    @IsTest
    static void testSiExistePacienteSinUsuarioSeDebeDevolverNull() {
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert paciente; 

        Test.startTest();
            User user = FormularioLoginController.getUser(paciente.Id); 
        Test.stopTest();

        System.assertEquals(null, user,
            'Se encontró algún usuario un paciente que no lo tiene');
    }

    @IsTest
    static void testSiExisteUsuarioSeDebeDevolverSuEmail() {
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert paciente; 

        Account pacienteDB = [
            SELECT  PersonContactId
            FROM    Account
            WHERE   Id =: paciente.Id
        ];

        Profile profile = [
            SELECT Id
            FROM Profile
            WHERE Name =: 'Paciente Oncología'
            LIMIT 1
        ];

        User usuarioDePaciente = new User();
        usuarioDePaciente.ProfileId = profile.Id;
        usuarioDePaciente.Username = paciente.PersonEmail;
        usuarioDePaciente.Alias = '3243';
        usuarioDePaciente.Email = 'test@test.com';
        usuarioDePaciente.EmailEncodingKey = 'UTF-8';
        usuarioDePaciente.FirstName = paciente.FirstName;
        usuarioDePaciente.Lastname = paciente.LastName;
        usuarioDePaciente.LanguageLocaleKey = 'es';
        usuarioDePaciente.LocaleSidKey = 'es';
        usuarioDePaciente.TimeZoneSidKey = 'America/Argentina/Buenos_Aires';
        usuarioDePaciente.ContactId = pacienteDB.PersonContactId;
        insert usuarioDePaciente;

        Test.startTest();
            String emailUsuarioDePaciente = FormularioLoginController.getEmailUsuario(usuarioDePaciente.UserName);
        Test.stopTest();

        System.assertNotEquals(null, emailUsuarioDePaciente,
            'No se devolvió el email con el username');
    }

    @IsTest
    static void testSiSeConsultaUsuarioPorSuIdSeDebeDevolverSuInformacion() {
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert paciente; 

        Account pacienteDB = [
            SELECT  PersonContactId
            FROM    Account
            WHERE   Id =: paciente.Id
        ];

        Profile profile = [
            SELECT Id
            FROM Profile
            WHERE Name =: 'Paciente Oncología'
            LIMIT 1
        ];

        User usuarioDePaciente = new User();
        usuarioDePaciente.ProfileId = profile.Id;
        usuarioDePaciente.Username = paciente.PersonEmail;
        usuarioDePaciente.Alias = '3243';
        usuarioDePaciente.Email = 'test@test.com';
        usuarioDePaciente.EmailEncodingKey = 'UTF-8';
        usuarioDePaciente.FirstName = paciente.FirstName;
        usuarioDePaciente.Lastname = paciente.LastName;
        usuarioDePaciente.LanguageLocaleKey = 'es';
        usuarioDePaciente.LocaleSidKey = 'es';
        usuarioDePaciente.TimeZoneSidKey = 'America/Argentina/Buenos_Aires';
        usuarioDePaciente.ContactId = pacienteDB.PersonContactId;
        insert usuarioDePaciente;

        Test.startTest();
            User user = FormularioLoginController.getDataUser(usuarioDePaciente.Id);
        Test.stopTest();

        System.assertNotEquals(null, user,
            'No se devolvió el usuario correspondiente con el Id');
    }

    @IsTest
    static void testLoginDeUsuarioPortalPacientes() {
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert paciente; 

        Account pacienteDB = [
            SELECT  PersonContactId
            FROM    Account
            WHERE   Id =: paciente.Id
        ];

        Profile profile = [
            SELECT Id
            FROM Profile
            WHERE Name =: 'Paciente Oncología'
            LIMIT 1
        ];

        User usuarioDePaciente = new User();
        usuarioDePaciente.ProfileId = profile.Id;
        usuarioDePaciente.Username = paciente.PersonEmail;
        usuarioDePaciente.Alias = '3243';
        usuarioDePaciente.Email = 'test@test.com';
        usuarioDePaciente.EmailEncodingKey = 'UTF-8';
        usuarioDePaciente.FirstName = paciente.FirstName;
        usuarioDePaciente.Lastname = paciente.LastName;
        usuarioDePaciente.LanguageLocaleKey = 'es';
        usuarioDePaciente.LocaleSidKey = 'es';
        usuarioDePaciente.TimeZoneSidKey = 'America/Argentina/Buenos_Aires';
        usuarioDePaciente.ContactId = pacienteDB.PersonContactId;
        insert usuarioDePaciente;

        Test.startTest();
            String login = FormularioLoginController.site(usuarioDePaciente.Username, 'Danone123');
        Test.stopTest();

        System.assertNotEquals(null, login);
    }
}