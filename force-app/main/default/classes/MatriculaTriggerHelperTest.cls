@IsTest public with sharing class MatriculaTriggerHelperTest {
    @testSetup
    private static void testSetup() {
        Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
        Account profesional = Build.aPersonalAccount()
        .withFirstName('Profesional')        
        .withProfesionalActivo(true)
        .build();
        profesional.LastName = 'ProfesionalTest';
        profesional.RecordTypeId = recordTypeProfesional;
        insert profesional;

        Account profesional2 = Build.aPersonalAccount()
        .withFirstName('Profesional2')        
        .withProfesionalActivo(true)
        .build();
        profesional2.LastName = 'ProfesionalTest2';
        profesional2.RecordTypeId = recordTypeProfesional;
        insert profesional2;
        
        List<Dan360_Matricula__c> matriculaList = new List<Dan360_Matricula__c>();
        Id recordTypeNacional = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Nacional').getRecordTypeId();
        Id recordTypeProvincial = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Provincial').getRecordTypeId();
        Dan360_Matricula__c mat1 = new Dan360_Matricula__c(
            Profesional__c = profesional2.Id,
            Numero_de_matricula__c = '777909087979',
            RecordTypeId = recordTypeNacional
        );
        matriculaList.add(mat1);
        Dan360_Matricula__c mat2 = new Dan360_Matricula__c(
            Profesional__c = profesional2.Id,
            Numero_de_matricula__c = '555555',
            RecordTypeId = recordTypeProvincial
        );
        matriculaList.add(mat2);
        insert matriculaList;
    }
    @IsTest
    static void cuandoSeCreaMatriculaNacionalSeDebeAsociarAlProfesional(){
        Account profesional = [SELECT Id FROM Account WHERE LastName = 'ProfesionalTest'];
        List<Dan360_Matricula__c> matriculaList = new List<Dan360_Matricula__c>();
        Id recordTypeNacional = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Nacional').getRecordTypeId();
        Id recordTypeProvincial = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Provincial').getRecordTypeId();
        Dan360_Matricula__c mat1 = new Dan360_Matricula__c(
            Profesional__c = profesional.Id,
            Numero_de_matricula__c = '77794848143',
            RecordTypeId = recordTypeNacional
        );
        matriculaList.add(mat1);
        Dan360_Matricula__c mat2 = new Dan360_Matricula__c(
            Profesional__c = profesional.Id,
            Numero_de_matricula__c = '44092',
            RecordTypeId = recordTypeProvincial
        );
        matriculaList.add(mat2);
        Test.startTest();
            insert matriculaList;
        Test.stopTest();
        Account profToCompare = [SELECT Id, Matricula_Nacional__c FROM Account WHERE Id = :mat1.Profesional__c];
        System.assertEquals('77794848143', profToCompare.Matricula_Nacional__c, 'Error al crear matricula');
        Account profToCompare2 = [SELECT Id, Matricula_Provincial__c FROM Account WHERE Id = :mat2.Profesional__c];
        System.assertEquals('44092', profToCompare2.Matricula_Provincial__c, 'Error al crear matricula');
    }
    @IsTest
    static void cuandoSeModificaMatriculaNacionalOProvincialSeDebeAsociarAlProfesional(){
        Account profesional = [SELECT Id FROM Account WHERE LastName = 'ProfesionalTest2'];
        List<Dan360_Matricula__c> matriculasToUpdate = new List<Dan360_Matricula__c>();
        List<Dan360_Matricula__c> matriculaList = [
            SELECT Id, Numero_de_matricula__c, Profesional__c
            FROM Dan360_Matricula__c
            WHERE Profesional__c = :profesional.Id
        ];
        for (Dan360_Matricula__c matricula : matriculaList) {
            matricula.Numero_de_matricula__c = '333333333';
            matriculasToUpdate.add(matricula);
        }
        
       
        Test.startTest();
            update matriculasToUpdate;
        Test.stopTest();
        Account profToCompare = [SELECT Id, Matricula_Nacional__c, Matricula_Provincial__c FROM Account WHERE Id = :profesional.Id];
        System.assertEquals('333333333', profToCompare.Matricula_Nacional__c, 'Error al crear matricula');        
        System.assertEquals('333333333', profToCompare.Matricula_Provincial__c, 'Error al crear matricula');
    }
    
    @IsTest
    static void cuandoSeCreaMatriculaProvincialSeDebeAsociarAlProfesional(){
        Account profesional = [SELECT Id FROM Account WHERE LastName = 'ProfesionalTest'];
        Id recordTypeProvincial = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Provincial').getRecordTypeId();
        Dan360_Matricula__c mat = new Dan360_Matricula__c(
            Profesional__c = profesional.Id,
            Numero_de_matricula__c = '44092',
            RecordTypeId = recordTypeProvincial
        );
        Test.startTest();
            insert mat;
        Test.stopTest();
        Account profToCompare = [SELECT Id, Matricula_Provincial__c FROM Account WHERE Id = :mat.Profesional__c];
        System.assertEquals('44092', profToCompare.Matricula_Provincial__c, 'Error al crear matricula');
    }
}