@isTest public with sharing class SegmentacionTriggerHelperTest {
   @testSetup
   private static void testSetup() {
    Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
    Account profesional = Build.aPersonalAccount()
    .withFirstName('Profesional')
    .withProfesionalActivo(true)
    .build();
    profesional.RecordTypeId = recordTypeProfesional;

    insert profesional;
   }
   
   @isTest
   private static void cuandoSeCreaSegmentacionMetabolicosSeDebeSetearLaCategoriaYLaFrecuencia() {
    // Test data setup
    Account profesional = [ 
        SELECT Id, KOL__c
        FROM Account
        WHERE FirstName = 'Profesional'
        LIMIT 1
    ]; 

    profesional.KOL__c = 'KOL Nicho	';
    profesional.Promedio_de_pacientes_Nicho__c = 'Más de 5';
    update profesional;
    Id tipoSegmentacion = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByName().get('Metabolicos').getRecordTypeId();
    VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
            recordTypeId = tipoSegmentacion,
            Profesional__c = profesional.Id
        );
    // Actual test
    Test.startTest();
    insert segmentacionNueva;
    Test.stopTest();
    
    // Asserts
    VisMed_Segmentacion__c segmentacionToCompare = [
        SELECT Id, Frecuencia__c, Categoria__c
        FROM VisMed_Segmentacion__c
        WHERE Id = :segmentacionNueva.Id
    ];
    System.assertEquals('KOL', segmentacionToCompare.Categoria__c, 'Error al crear categoria');
    System.assertEquals(2.50, segmentacionToCompare.Frecuencia__c, 'Error al crear frecuencia');
   }
   @isTest
   private static void cuandoSeCreaSegmentacionPediatricosGeneralSeDebeSetearLaCategoriaYLaFrecuencia() {
    // Test data setup
    Account profesional = [ 
        SELECT Id 
        FROM Account
        WHERE FirstName = 'Profesional'
        LIMIT 1
    ]; 
    
    Id tipoSegmentacion = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByName().get('Pediatricos General').getRecordTypeId();
    VisMed_Segmentacion__c segmentacionNueva = new VisMed_Segmentacion__c(
            recordTypeId = tipoSegmentacion,
            Profesional__c = profesional.Id
        );
    // Actual test
    Test.startTest();
    insert segmentacionNueva;
    Test.stopTest();
    
    // Asserts
    VisMed_Segmentacion__c segmentacionToCompare = [
        SELECT Id, Frecuencia__c, Categoria__c
        FROM VisMed_Segmentacion__c
        WHERE Id = :segmentacionNueva.Id
    ];
    System.assertEquals('D', segmentacionToCompare.Categoria__c, 'Error al crear categoria');
    System.assertEquals(0.50, segmentacionToCompare.Frecuencia__c, 'Error al crear frecuencia');
   }
}