@isTest
public class CreateFormulario_TEST {

    @TestSetup
    static void makeData(){

        Account newAccount = build.anAccountPacienteBestCare()
                                    .withTelefono('462134')
                                    .withLastName('value')
                                    .withAreaTerapeutica('Alergia')
                                    .withEstadoDePaciente('En tratamiento')
                                    .withSubestadoDePaciente('Tratamiento Efectivo')
                                    .withDNI('32589456')
                                    .withCanalParaConsumidorBaby('Farmacias')
                                    .build();
        insert newAccount;

        Task newTask = build.aTaskLlamadodeseguimiento()
                            .withWhatId(newAccount)
                            .withPriority('Baja')
                            .build();
        insert newTask;

        Task secondTask = build.aTaskLlamadodeseguimiento()
                            .withPriority('Alta')
                            .build();
        insert secondTask;
    }

    @IsTest
    static void alPasarUnIdDeLaTareaSeDebeGenerarUnFormularioConElRecordTypeElegidoYRelacionarloALaTarea() {

        Task originTask = [
            SELECT Id, WhatId, WhoId
            FROM Task
            WHERE priority = 'Baja'
            LIMIT 1
        ];

        RecordType rt = [
            SELECT Id, Name, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'Formulario_MarketingCloud__c'
            AND IsActive = true
            AND Name = 'Dieta Cetogenica - INICIO'
            LIMIT 1
        ];

        Test.startTest();
        FormularioController formController = new FormularioController();
        formController.recordTypeSelected=rt.Id;
        System.currentPageReference().getParameters().put('taskId', originTask.Id);
        formController.doSubmit();
        Test.stopTest();
            
        Formulario_MarketingCloud__c form = [
            SELECT Id, Cuenta__c, recordTypeId
            FROM Formulario_MarketingCloud__c
            LIMIT 1
        ];

        Account acc = [
            SELECT Id, PersonContactId 
            FROM Account 
            WHERE Id=:originTask.WhatId 
            LIMIT 1
        ];


        system.assertEquals(rt.Id, form.RecordTypeId, 'No es correcto el recordtype');
        system.assertEquals(acc.Id, form.Cuenta__c, 'No es correcto el accountId');
        
    }
    
    @IsTest
    static void getFromList_Test(){

        Task originTask = [
            SELECT Id, WhatId, WhoId
            FROM Task
            WHERE priority = 'Baja'
            LIMIT 1
        ];

        RecordType rt = [
            SELECT Id, Name, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'Formulario_MarketingCloud__c'
            AND IsActive = true
            AND Name = 'Dieta Cetogenica - INICIO'
            LIMIT 1
        ];
        
        Test.startTest();
        FormularioController formController = new FormularioController();
        formController.recordTypeSelected=rt.Id;
        System.currentPageReference().getParameters().put('taskId', originTask.Id);
        formController.getFormList();
        Test.stopTest();

        Integer getFromListRt = [
            SELECT COUNT() 
            FROM RecordType 
            WHERE SObjectType = 'Formulario_MarketingCloud__c'
            AND IsActive = true
        ];

        system.assertEquals(formController.getFormList().size(), getFromListRt, 'Los tamaños de los recordtypes son distintos');
    }

    @IsTest
    static void testFatalMessage(){
        
        Task originTask = [
            SELECT Id, WhatId, WhoId
            FROM Task
            WHERE priority = 'Alta'
            LIMIT 1
        ];

        RecordType rt = [
            SELECT Id, Name, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'Formulario_MarketingCloud__c'
            AND IsActive = true
            AND Name = 'Dieta Cetogenica - INICIO'
            LIMIT 1
        ];

        Test.startTest();
        FormularioController formController = new FormularioController();
        formController.recordTypeSelected=rt.Id;
        System.currentPageReference().getParameters().put('taskId', originTask.Id);
        formController.doSubmit();
        Test.stopTest();

        System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.FATAL));
        
    }
}