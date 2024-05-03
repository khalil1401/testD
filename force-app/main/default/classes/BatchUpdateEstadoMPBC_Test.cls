@isTest
public with sharing class BatchUpdateEstadoMPBC_Test {

    @TestSetup
    static void makeData(){
        List<Modulo_de_paciente__c> mdps = new List<Modulo_de_paciente__c>();

        Account obraSocial = new Account(
            Name = 'Obra Social 1',
            SalesOffice_ObraSocial__c = 'Pruebas 1',
            SalesGroup__c = ' Grupo pruebas 1',
            Actividad_para_ObraSocial_del__c	= 'Economica 1',
            Canal_para_Consumidor_Baby__c = 'Almacen',
            Ubicacion__c = 'Mendoza'
        );
        INSERT obraSocial;

        Account cuenta2 = new Account(
            LastName = 'Pruebas Danone 1',
            RecordTypeId = '0121I000001BtZPQA0',
            Area_terapeutica__c = 'Oncología',
            DNI__c = '6397302',
            Estado_de_paciente__c = 'Inicio',
            Phone = '5491112345678',
            Canal_para_Consumidor_Baby__c = 'Almacen',
            Direccion_de_entrega__c = 'Farmacia',
            // Obra_social__c = '001M000001CnCp9IAF',
            Obra_social__c = obraSocial.Id,
            Tipo_de_Obra_Social__c = 'Prepaga',
            Codigo_postal__c = '1834'
        );

        INSERT cuenta2;
        
        Modulo_de_paciente__c insertarMDP =  new Modulo_de_paciente__c(
            Renovacion__c	= 'Alta',
            Duracion_modulo__c = 6,
            Modulo_desde__c = System.today(),
            Modulo_hasta__c = Date.today().addDays(20),
            Valor_total_pesos__c = 1000.00,
            Estado__c = 'Activo',
            Estado_de_modulo__c	 = 'Ingresado',
            Cuenta__c = cuenta2.Id
        );

        INSERT insertarMDP;

        Modulo_jitterbit__c mj = new Modulo_jitterbit__c(
            Modulo_de_paciente__c = insertarMDP.Id,
            Estado_Jiterrbit__c = 'Nuevo'
        );
        
        INSERT mj;
    }

    @isTest
    public static void testExecute() {

        List<Modulo_jitterbit__c> mjs = [SELECT Id FROM Modulo_jitterbit__c WHERE Estado_Jiterrbit__c = 'Nuevo'];
        List<Modulo_jitterbit__c> mjs_toUpdate = new List<Modulo_jitterbit__c>();
        for (Modulo_jitterbit__c mj : mjs) {
            Modulo_jitterbit__c newMJ = new Modulo_jitterbit__c(
                Id = mj.Id,
                Estado_Jiterrbit__c = 'Procesado'
            );
            mjs_toUpdate.add(newMJ);
        }
        UPDATE mjs_toUpdate;

        Test.startTest();
        BatchUpdateEstadoMPBC myBatch = new BatchUpdateEstadoMPBC();
            Id batchId = Database.executeBatch(myBatch, 50);
        Test.stopTest();
        
        List<Modulo_de_paciente__c> list_result_mdp = [SELECT Id FROM Modulo_de_paciente__c WHERE Estado_de_modulo__c = 'Procesado'];

        System.assertEquals(1, list_result_mdp.size());
    }

}