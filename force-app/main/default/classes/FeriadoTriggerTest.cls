@isTest
public class FeriadoTriggerTest {
    
    @testSetup
    public static void setup()
    {	Contact contactTest = Build.aContact()
        .withLastName('Test')
        .withFirstName('Contact')
        .Build();
     
     insert contactTest;
     
     integer year = DateTime.now().year();
     Ciclo__c ciclo = Build.aCiclo()
         .withName('New Ciclo')
         .withFechaDeInicio(Date.newInstance(year,12,01))
         .withFechaDeFin(Date.newInstance(year,12,31))
         .build();
     ciclo.ContactId__c =contactTest.id;
     insert ciclo;
    }
    @isTest
    public static void insertoFeriado_CalculaDiasHabiles()
    {
        integer year = DateTime.now().year();
        Ciclo__c ciclo = [SELECT Id, Cantidad_de_dias_habiles__c FROM Ciclo__c];
        Decimal diasHabiles = ciclo.Cantidad_de_dias_habiles__c;
        System.debug(diasHabiles);

        Feriado__c feriado1 = Build.aFeriado().withFecha(Date.newInstance(year,12,12)).build();
        Test.startTest();		
        insert feriado1;
        Test.stopTest();
        ciclo = [SELECT Id, Cantidad_de_dias_habiles__c FROM Ciclo__c];
        System.assertNotEquals(diasHabiles, ciclo.Cantidad_de_dias_habiles__c, 'No se actualizo correctamente');
    }
    @isTest
    public static void eliminoFeriado_CalculaDiasHabiles()
    {
        integer year = DateTime.now().year();
        
        Feriado__c feriado1 = Build.aFeriado().withFecha(Date.newInstance(year,12,12)).build();
        insert feriado1;
        Ciclo__c ciclo = [SELECT Id, Cantidad_de_dias_habiles__c FROM Ciclo__c];
        Decimal diasHabiles = ciclo.Cantidad_de_dias_habiles__c;
        Test.startTest();		
        delete feriado1;
        Test.stopTest();
        ciclo = [SELECT Id, Cantidad_de_dias_habiles__c FROM Ciclo__c];
        System.assertNotEquals(diasHabiles, ciclo.Cantidad_de_dias_habiles__c, 'No se actualizo correctamente');
    }
}