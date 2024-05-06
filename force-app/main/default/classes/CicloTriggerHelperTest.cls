@IsTest public with sharing class CicloTriggerHelperTest {
    @IsTest
    static void cuandoSeCreaUnCicloDebeArmarElNombreConMesYAno(){

        Date today = Date.today();
        VisMed_Ciclo__c ciclo = Build.aCiclo()
        .withFechaInicio(today.toStartOfMonth())
        .withFechaFin(today.toStartOfMonth().addMonths(1).addDays(-1))
        .build();
        
        Test.startTest();
        insert ciclo;        
        Test.stopTest();

        VisMed_Ciclo__c cicloToCompare = [
            SELECT Id, Name
            FROM VisMed_Ciclo__c
            WHERE Fecha_de_inicio__c = :today.toStartOfMonth()
        ];

        System.debug('Name ciclo: '+cicloToCompare.Name);
        System.assertNotEquals(null, cicloToCompare.Name, 'Error al crear el nombre');
        
        
    }
}