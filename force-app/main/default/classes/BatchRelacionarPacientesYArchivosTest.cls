@IsTest
public class BatchRelacionarPacientesYArchivosTest {

    @testSetup
    static void setup() {

        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .build();
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        account.DNI__c = '12345678';
        insert account;

        ContentVersion contentVersion = new ContentVersion(
            Title          = 'test',
            PathOnClient   = 'test.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            dni_fileupload__c = 'Nombre Apellido' + '-' + account.DNI__c);
        insert contentVersion;

    }

    @IsTest
    static void testSiExisteDocYPacienteConElMismoDNISeDebeGenerarUnContentDocumentLink() {

        Account paciente = [
            SELECT Id
            FROM Account
            WHERE DNI__c =: '12345678'
            LIMIT 1
        ];

        ContentVersion doc = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE dni_fileupload__c =: 'Nombre Apellido-12345678'
            LIMIT 1
        ];

        Test.startTest();
            BatchRelacionarPacientesYArchivos batch = new BatchRelacionarPacientesYArchivos();
            Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        List<ContentDocumentLink> linksDB = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId =: paciente.Id
        ];

        ContentVersion docDB = [
            SELECT  Id, dni_fileupload__c
            FROM    ContentVersion
            WHERE   Id =: doc.Id
            LIMIT 1
        ];

        System.assertEquals(1, linksDB.size(),
            'No se encontro la cantidad de contentDocumentLink esperada');
        System.assertEquals(doc.ContentDocumentId, linksDB.get(0).ContentDocumentId,
            'El contentdocumentLink no se relaciona con el doc del contentDocument generado');
        System.assertEquals(paciente.Id, linksDB.get(0).LinkedEntityId,
            'El contentdocumentLink no se relaciona con el paciente del contentDocument generado');
        System.assertEquals(null, docDB.dni_fileupload__c,
            'El ContentVersion no fue editado con el dni en null');

    }

    @IsTest
    static void testSiExistePacienteSinDocSeDebeGenerarUnContentDocumentLinkConELDNIDelContacto() {

        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Juan')
            .withLastName('Perez')
            .withEmail('nombreapellido@testdanone.com')
            .build();
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert account;

        List<Contact> contacts = new List<Contact>();

        Contact contact = Build.aContact()
            .withFirstName('Madre')
            .withLastName('Madre')
            .build();
        contact.Relacion__c = 'Madre';
        contact.DNI__c = '1234';
        contact.Principal__c = true;
        contacts.add(contact);
        
        Id contactPaciente = FormularioRegistroController.saveContacts(contacts, account.Id);
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'test',
            PathOnClient   = 'test.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            dni_fileupload__c = 'Juan Perez' + '-' + contact.DNI__c);
        insert contentVersion;

        Test.startTest();
            BatchRelacionarPacientesYArchivos batch = new BatchRelacionarPacientesYArchivos();
            Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        List<ContentDocumentLink> linksDB = [
            SELECT  Id, LinkedEntityId, ContentDocumentId
            FROM    ContentDocumentLink
            WHERE   LinkedEntityId =: account.Id
        ];

        ContentVersion docDB = [
            SELECT  Id, dni_fileupload__c, ContentDocumentId
            FROM    ContentVersion
            WHERE   Id =: contentVersion.Id
            LIMIT 1
        ];

        System.assertEquals(1, linksDB.size(),
            'No se encontro la cantidad de contentDocumentLink esperada con el Contacto');
        System.assertEquals(docDB.ContentDocumentId, linksDB.get(0).ContentDocumentId,
            'El contentdocumentLink no se relaciona con el doc del contentDocument generado con el Contacto');
        System.assertEquals(account.Id, linksDB.get(0).LinkedEntityId,
            'El contentdocumentLink no se relaciona con el paciente del contentDocument generado con el Contacto');
        System.assertEquals(null, docDB.dni_fileupload__c,
            'El ContentVersion no fue editado con el dni en null con el Contacto');

    }

    @IsTest
    static void testSiExistePacienteYContactoPrincipalACargoConMismoDNISeDebenGenerarlosDosContentDocumentLinkCorrespondientes() {

        Account paciente = [
            SELECT Id
            FROM Account
            WHERE DNI__c =: '12345678'
            LIMIT 1
        ];

        Account pacienteHijo = Build.anAccountCuentacommunity()
            .withFirstName('Juan')
            .withLastName('Perez')
            .withEmail('nombreapellido@testdanone.com')
            .build();
        pacienteHijo.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert pacienteHijo;

        List<Contact> contacts = new List<Contact>();

        Contact contact = Build.aContact()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .build();
        contact.Relacion__c = 'Padre';
        contact.DNI__c = '12345678';
        contact.Principal__c = true;
        contacts.add(contact);
        
        Id contactPaciente = FormularioRegistroController.saveContacts(contacts, pacienteHijo.Id);
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'test',
            PathOnClient   = 'test.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            dni_fileupload__c = 'Juan Perez' + '-' + contact.DNI__c);
        insert contentVersion;

        Test.startTest();
            BatchRelacionarPacientesYArchivos batch = new BatchRelacionarPacientesYArchivos();
            Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        List<ContentDocumentLink> linkPacienteDB = [
            SELECT  Id, LinkedEntityId, ContentDocumentId
            FROM    ContentDocumentLink
            WHERE   LinkedEntityId =: paciente.Id
        ];

        List<ContentDocumentLink> linkContactoDB = [
            SELECT  Id, LinkedEntityId, ContentDocumentId
            FROM    ContentDocumentLink
            WHERE   LinkedEntityId =: pacienteHijo.Id
        ];

        System.assertEquals(1, linkPacienteDB.size(),
            'No se encontro la cantidad de contentDocumentLink esperada con un paciente con mismo DNI que contacto');
        System.assertEquals(1, linkContactoDB.size(),
            'No se encontro la cantidad de contentDocumentLink esperada con un contacto con mismo DNI que paciente');

    }

    @IsTest
    static void testSiExisteDocYPacienteConElMismoDNISeDebeGenerarLaTareaParaLaRevisionDelPSP() {

        Account paciente = [
            SELECT Id
            FROM Account
            WHERE DNI__c =: '12345678'
            LIMIT 1
        ];

        ContentVersion doc = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE dni_fileupload__c =: 'Nombre Apellido-12345678'
            LIMIT 1
        ];

        Test.startTest();
            BatchRelacionarPacientesYArchivos batch = new BatchRelacionarPacientesYArchivos();
            Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        
        List<Task> tareasDePacientesDB = [
            SELECT Id, OwnerID, WhatId, Type
            FROM Task
        ];

        Group psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
                AND NAME = 'PSP'
            LIMIT 1
        ];

        System.assertEquals(1, tareasDePacientesDB.size(),
            'No se genero la tarea esperada de alta de paciente via web');
        System.assertEquals(paciente.Id, tareasDePacientesDB.get(0).WhatId,
            'La tarea generada no esta relacionada con el paciente esperado');
        System.assertEquals(psp.Id, tareasDePacientesDB.get(0).OwnerId,
            'La tarea generada no esta relacionada con el PSP');
        System.assertEquals('Alta paciente via web', tareasDePacientesDB.get(0).Type,
            'La tarea generada no tiene el tipo Alta de paciente via web');
        
    }

    @IsTest
    static void testSiExistePacienteSinDocSeDebeGenerarLaTareaParaLaRevisionDelPSPconElDNIDelContacto() {

        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Juan')
            .withLastName('Perez')
            .withEmail('nombreapellido@testdanone.com')
            .build();
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert account;

        List<Contact> contacts = new List<Contact>();

        Contact contact = Build.aContact()
            .withFirstName('Madre')
            .withLastName('Madre')
            .build();
        contact.Relacion__c = 'Madre';
        contact.DNI__c = '1234';
        contact.Principal__c = true;
        contacts.add(contact);
        
        Id contactPaciente = FormularioRegistroController.saveContacts(contacts, account.Id);
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'test',
            PathOnClient   = 'test.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            dni_fileupload__c = 'Juan Perez' + '-' + contact.DNI__c);
        insert contentVersion;

        Test.startTest();
            BatchRelacionarPacientesYArchivos batch = new BatchRelacionarPacientesYArchivos();
            Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        
        List<Task> tareasDePacientesDB = [
            SELECT  Id, OwnerID, WhatId, Type
            FROM    Task
            WHERE   WhatId =: account.Id
        ];

        Group psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
                AND NAME = 'PSP'
            LIMIT 1
        ];

        System.assertEquals(1, tareasDePacientesDB.size(),
            'No se genero la tarea esperada de alta de paciente via web con el Contacto');
        System.assertEquals(account.Id, tareasDePacientesDB.get(0).WhatId,
            'La tarea generada no esta relacionada con el paciente esperado  con el Contacto');
        System.assertEquals(psp.Id, tareasDePacientesDB.get(0).OwnerId,
            'La tarea generada no esta relacionada con el PSP  con el Contacto');
        System.assertEquals('Alta paciente via web', tareasDePacientesDB.get(0).Type,
            'La tarea generada no tiene el tipo Alta de paciente via web  con el Contacto');
        
    }

    @IsTest
    static void testSiIngresoUnNombreDePacienteConEspaciosDemasSeDebeCorregir() {

        String nombreCompleto = ' PrimerNombre  SegundoNombre  Apellido ';
        
        Test.startTest();
            String nombreCompletoCorregido = BatchRelacionarPacientesYArchivos.returnValidName(nombreCompleto);
        Test.stopTest();

        System.assertEquals('PrimerNombre SegundoNombre Apellido', nombreCompletoCorregido,
            'El nombre no se corrigió como se esperaba');

    }

    @IsTest
    static void testSiIngresoUnNombreDePacienteSinEspaciosDemasNoSeDebeCorregirNada() {

        String nombreCompleto = 'PrimerNombre SegundoNombre Apellido ';
        
        Test.startTest();
            String nombreCompletoCorregido = BatchRelacionarPacientesYArchivos.returnValidName(nombreCompleto);
        Test.stopTest();

        System.assertEquals('PrimerNombre SegundoNombre Apellido', nombreCompletoCorregido,
            'El nombre no se corrigió como se esperaba');

    }

}