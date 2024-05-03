@isTest
public class BatchCrearCasosDeSeguimiento_Test {

    
    @isTest
    static void SiSeCumplenLasCondicionesEnCuentaSeDebeInsertarUnCasoDeSeguimiento() {   
                List<Account> accList = new List<Account>();
        for (Integer i=0;i<5;i++) {
            accList.add(Build.anAccountPacienteBestCare()
                        .withLastName('BestCare '+i)
                        .withAreaTerapeutica('Alergia')
                        .withEstadoDePaciente('En seguimiento')
                        .withRelacionamiento('Alto')
                        .build()
                       );
        }
        insert accList;

        for(Account acc : accList){
            acc.Fecha_de_cambio_de_estado__c = System.today().addDays(-5);
        }
        update accList;
        
  		Test.startTest();
        BatchCrearCasosDeSeguimiento batchToExecute = new BatchCrearCasosDeSeguimiento();
        Id batchId = Database.executeBatch(batchToExecute);
        Test.stopTest();
        
        List<Case> casesDb =[
            SELECT id,Subtipo__c
            FROM Case
        ];
        
        System.assertEquals(5, casesDb.size());
        System.assertEquals('Seguimiento no renovacion', casesDb[0].Subtipo__c);
    }
    @isTest
    static void SiyaTieneUnCasoDeSeguimientoNoDebeGenerarleOtro() {
        
        Account anAccount = Build.anAccountPacienteBestCare()
            .withLastName('BestCare')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En seguimiento')
            .withRelacionamiento('Alto')
            .build();
        
        insert anAccount;
        
        Case aCase = Build.aCase()
            .forAccount(anAccount)
            .withType('Consulta')
            .withStatus('Abierto')
            .withSubtipo('Seguimiento no renovacion')
            .build();

        insert aCase;
        
        Test.startTest();
        anAccount.Fecha_de_cambio_de_estado__c = System.today().addDays(-5);
        
        update anAccount;
        BatchCrearCasosDeSeguimiento batchToExecute = new BatchCrearCasosDeSeguimiento();
        Id batchId = Database.executeBatch(batchToExecute);
        Test.stopTest();
        
        List<Case> casesDb =[
            SELECT id,Subtipo__c
            FROM Case
        ];

        System.assertEquals(1, casesDb.size());
    }
}