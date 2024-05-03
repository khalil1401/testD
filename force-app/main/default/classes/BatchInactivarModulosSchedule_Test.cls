@isTest
public class BatchInactivarModulosSchedule_Test {
    @TestSetup
    static void setup(){
        Account ac1 = Build.anAccountPacienteBestCare()
                            .withLastName('BestCare 1')
                            .withAreaTerapeutica('Alergia')
                            .withEstadoDePaciente('En tratamiento')
                            .withSubestadoDePaciente('Tratamiento Efectivo')
                            .build();
        insert ac1;

        Account ac2 = Build.anAccountPacienteBestCare()
                            .withLastName('BestCare 2')
                            .withAreaTerapeutica('Alergia')
                            .withEstadoDePaciente('En tratamiento')
                            .withSubestadoDePaciente('Tratamiento Efectivo')
                            .build();
        insert ac2;

        Modulo_de_paciente__c mdp1= Build.aModulodepaciente()
                                        .withDuracion(5)
                                        .withModulodesde(Date.newInstance(2020, 2, 13))
                                        .withEstado('Activo')
                                        .withCuenta(ac1)
                                        .build();
        insert mdp1;

        Modulo_de_paciente__c mdp2 = Build.aModulodepaciente()
                                        .withDuracion(5)
                                        .withModulodesde(Date.newInstance(2100, 2, 13))
                                        .withEstado('Activo')
                                        .withCuenta(ac2)
                                        .build();
        insert mdp2;
    }

   	@isTest
    public static void setSchedule()
    {
        string cron_exp = '0 0 0 1/1 * ? *';
        System.debug(cron_exp);
        
        Test.startTest();
        string jobId = System.schedule('Inactivar modulos '+System.now(), cron_exp, new BatchInactivarModulosSchedule());
        List<Modulo_de_paciente__c> mdp = [SELECT Id FROM Modulo_de_paciente__c WHERE Estado__c = 'Inactivo'];
        System.assertEquals(0, mdp.size(), 'Se inactivaron antes de tiempo');
        Test.stopTest();
        
        mdp = [SELECT Id FROM Modulo_de_paciente__c WHERE Estado__c = 'Activo'];
        System.assertNotEquals(1, mdp.size(), 'No se inactivaron');
        
    }
}