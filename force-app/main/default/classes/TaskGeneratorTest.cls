@isTest
public with sharing class TaskGeneratorTest {

    public static Profile psp = [
        SELECT Id 
        FROM Profile 
        WHERE Name
        LIKE '%PSP%'
        LIMIT 1
    ]; 
    public static User userPSP = new User(Alias = 'psptest', Email='psptest@testorg.com', 
                                          EmailEncodingKey='UTF-8', LastName='userPSPTest', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = psp.Id, Title='medico',
                                          TimeZoneSidKey='America/Los_Angeles', UserName='userPSPTest@testorg.com');
    
    static{
        Tareas_de_profesionales__c kinesiologo = new Tareas_de_profesionales__c();
        kinesiologo.Name='Kinesiologo';
        kinesiologo.Titulo_del_profesional__c= 'Kinesiologo';
        kinesiologo.Asunto_de_la_visita__c= 'Visita de kinesiologo';
        kinesiologo.Tareas_del_profesional__c= 12;

        Tareas_de_profesionales__c nutricionista = new Tareas_de_profesionales__c();
        nutricionista.Name='Nutricionista';
        nutricionista.Titulo_del_profesional__c= 'Nutricionista';
        nutricionista.Asunto_de_la_visita__c= 'Visita de nutricionista';
        nutricionista.Tareas_del_profesional__c= 1;

        Tareas_de_profesionales__c enfermero = new Tareas_de_profesionales__c();
        enfermero.Name='Enfermero';
        enfermero.Titulo_del_profesional__c= 'Enfermero';
        enfermero.Asunto_de_la_visita__c= 'Visita de Enfermero';
        enfermero.Tareas_del_profesional__c= 2;

        Tareas_de_profesionales__c medico = new Tareas_de_profesionales__c();
        medico.Name='Medico';
        medico.Titulo_del_profesional__c= 'Medico';
        medico.Asunto_de_la_visita__c= 'Visita de medico';
        medico.Tareas_del_profesional__c= 1;

        insert new List<Tareas_de_profesionales__c>{kinesiologo,nutricionista,enfermero,medico};
        insert userPSP;
    }

    @IsTest
    static void testTaskCreation() {
        List<Account> accounts = new List<Account>();
        
        for(integer i = 0 ;i < 5; i++){
            Account testCuenta = Build.anAccountPacienteBestCare()
                .withLastName('Name Test'+i)
                .withRegimenDeInternacionDomiciliaria('Sí')
                .withEmpresadeinternaciondomiciliaria('Best care')		
                .withDNI('12346789'+i)
                .withCanalParaConsumidorBaby('Farmacias')
                .build();
            testCuenta.Nutricionista_Asignado__c = userPSP.id;
            testCuenta.Kinesiologo_asignado__c = userPSP.id;
            testCuenta.Medico_Asignado__c = userPSP.id;
            testCuenta.Enfermero_Asignado__c = userPSP.id;
            accounts.add(testCuenta);
        }
        
        insert accounts;

        Test.startTest();
        
        TaskGeneratorController.queueTasks(accounts, System.today());
        
        Test.stopTest();
        
        List<Task> tareas = [
            SELECT id, ownerId, Subject,WhatId, paciente__c
            FROM Task
            WHERE createdDate = today
            AND Subject LIKE : '%Visita de%'
        ];
        
        System.assertEquals(80, tareas.size());    
    }

    @IsTest
    static void testGetAccountWrapper() {
        
    Account testCuenta = Build.anAccountPacienteBestCare()
                .withLastName('Name Test')
                .withRegimenDeInternacionDomiciliaria('Sí')
                .withEmpresadeinternaciondomiciliaria('Best care')		
                .withDNI('12346789')
                .withCanalParaConsumidorBaby('Farmacias')
                .build();
        testCuenta.Enfermero_Asignado__c = userPSP.id;
        insert testCuenta;

        Test.startTest();
        
        TaskGeneratorController.accWrapper wrapper = TaskGeneratorController.getAccountWrapper(new List<String>{testCuenta.Id});
        
        Test.stopTest();
        
        System.assertEquals('Name Test', wrapper.accList[0].Name);
        System.assertEquals(1, wrapper.selectedIdSet.size());
    }

    @IsTest
    static void testGetAccounts() {
        
    Account testCuenta = Build.anAccountPacienteBestCare()
                .withLastName('Name Test')
                .withRegimenDeInternacionDomiciliaria('Sí')
                .withEmpresadeinternaciondomiciliaria('Best care')		
                .withDNI('12346789')
                .withCanalParaConsumidorBaby('Farmacias')
                .build();
        testCuenta.Medico_Asignado__c = userPSP.id;
        insert testCuenta;

        Test.startTest();
        Test.setCurrentPage(Page.TaskGenerator);
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(new List<Account>{testCuenta});
        controller.setSelected(new List<Account>{testCuenta});
        TaskGeneratorController extension = new TaskGeneratorController(controller);
        
        Test.stopTest();
        
        System.assertEquals('Name Test', extension.getCuentas().get(0).Name);
    }

    @IsTest
    static void testGetFieldSet() {

        Account testCuenta = Build.anAccountPacienteBestCare()
        .withLastName('Name Test')
        .withRegimenDeInternacionDomiciliaria('Sí')
        .withEmpresadeinternaciondomiciliaria('Best care')		
        .withDNI('12346789')
        .withCanalParaConsumidorBaby('Farmacias')
        .build();

        insert testCuenta;

        Test.startTest();
        Test.setCurrentPage(Page.TaskGenerator);
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(new List<Account>{testCuenta});
        controller.setSelected(new List<Account>{testCuenta});
        TaskGeneratorController extension = new TaskGeneratorController(controller);
       
        TaskGeneratorController.FieldsWrapper wrapperFields = new TaskGeneratorController.FieldsWrapper();
        List<TaskGeneratorController.FieldsWrapper> fields = extension.getFieldsSet();
        Test.stopTest();
        
        System.assertNotEquals(0, fields.size());
    }

}