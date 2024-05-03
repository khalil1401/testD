@isTest
public class BatchInactivarModulos_Test {
    @testSetup 
    static void setup() {
        List<Account> accList = new List<Account>();
        List<Modulo_de_paciente__c> mdpList = new List<Modulo_de_paciente__c>();
        // insert 10 accounts
        for (Integer i=0;i<2;i++) {
            accList.add(Build.anAccountPacienteBestCare()
                        .withLastName('BestCare '+i)
                        .withAreaTerapeutica('Alergia')
                        .withEstadoDePaciente('En tratamiento')
                        .withSubestadoDePaciente('Tratamiento Efectivo')
                        .build()
                       );
        }
        accList[0].Fecha_de_obito__c =system.today();
        
        insert accList;
        
        for (Account acc : accList) {
            mdpList.add(Build.aModulodepaciente()
                        .withDuracion(5)
                        .withModulodesde(Date.newInstance(
                            System.today().year(),
                            System.today().month(),
                            System.today().day() - 5))
                        .withEstado('Activo')
                        .withCuenta(acc)
                        .build()
                       );
        }
        insert mdpList;
    }
    
    static testmethod void testSiSeInactivanLosModulos() {        
        Test.startTest();
        BatchInactivarModulos batchToExecute = new BatchInactivarModulos();
        Id batchId = Database.executeBatch(batchToExecute);
        Test.stopTest();
        System.assertEquals(2, [SELECT count() FROM Modulo_de_paciente__c WHERE Estado__c = 'Inactivo']);
    }
}