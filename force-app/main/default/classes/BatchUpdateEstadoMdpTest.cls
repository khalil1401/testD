@isTest
public with sharing class BatchUpdateEstadoMdpTest {

    @testSetup
    static void setup() {
        List<Modulo_de_paciente__c> mdps = new List<Modulo_de_paciente__c>();

        Account obraSocial = new Account(
            Name = 'Obra Social 1',
            SalesOffice_ObraSocial__c = 'Pruebas 1',
            SalesGroup__c = ' Grupo pruebas 1',
            Actividad_para_ObraSocial_del__c	= 'Economica 1',
            Canal_para_Consumidor_Baby__c = 'Almacen',
            Ubicacion__c = 'Mendoza'
        );
        insert obraSocial;

        Account cuenta2 = new Account(
            LastName = 'Pruebas Danone 1',
            RecordTypeId = '0121I000001BtZPQA0',
            Area_terapeutica__c = 'Oncología',
            DNI__c = '6397302',
            Estado_de_paciente__c = 'Inicio',
            Phone = '5491112345678',
            Canal_para_Consumidor_Baby__c = 'Almacen',
            Direccion_entrega__c = 'Farmacia',
            // Obra_social__c = '001M000001CnCp9IAF',
            Obra_social__c = obraSocial.Id,
            Tipo_de_Obra_Social__c = 'Prepaga',
            Codigo_postal__c = '1834'
        );

        insert cuenta2;
        
        // insert 10 accounts
        
        
            Modulo_de_paciente__c insertarMDP =  new Modulo_de_paciente__c(
                    Renovacion__c	= 'Alta',
                    Duracion_modulo__c = 6,
                    Modulo_desde__c = date.parse('8/10/2023'),
                    Modulo_hasta__c = Date.today(),
                    Valor_total_pesos__c = 1000.00,
                    Estado__c = 'Activo',
                    Cuenta__c = cuenta2.Id
                );    
            
        
        INSERT insertarMDP;

    }

    @isTest static void test() {

        List<Modulo_de_paciente__c> mdps = [SELECT Id FROM Modulo_de_paciente__c];

        List<Modulo_de_paciente__c> mdpsToUpdate = new List<Modulo_de_paciente__c>();

        for(Modulo_de_paciente__c mdp : mdps){

            Modulo_de_paciente__c newmdp = new Modulo_de_paciente__c(
                Id = mdp.Id,
                Modulo_hasta__c =  System.today().addDays(-1)
                // Estado__c = 'Activo'
            );
            
            mdpsToUpdate.add(newmdp);
        }
        update mdpsToUpdate;

        Test.startTest();
        BatchUpdateEstadoMdp uca = new BatchUpdateEstadoMdp();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        Date fechaFutura = System.today().addDays(1);

        // after the testing stops, assert records were updated properly
        System.assertEquals(0, [SELECT count() FROM Modulo_de_paciente__c WHERE Modulo_hasta__c < TODAY AND Estado__c = 'Activo']);
    }
}