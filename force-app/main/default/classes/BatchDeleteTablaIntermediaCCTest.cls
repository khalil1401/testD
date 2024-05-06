@isTest
public with sharing class BatchDeleteTablaIntermediaCCTest {
    @TestSetup
    static void makeData(){
        Dan360_TablaIntermediaCuentaCorriente__c cuentaCorriente = Build.aTablaIntermediaCuentaCorriente()
            .withName('CC Integracion 1')
            .withCodigoCliente('000012')
            .withFechaDocumento('20210211')
            .withIdRegistro('12345')
            .withImporteDocumento('2000')
            .withMoneda('USD')
            .withOrdenAplicacion('222')
            .withRemito('Rem0000')
            .withSaldo('1500')
            .withTipoDeDocumento('CC')
            .withVencimiento('20220122')
            .build();

        Dan360_TablaIntermediaCuentaCorriente__c cuentaCorriente2 = Build.aTablaIntermediaCuentaCorriente()
            .withName('CC Integracion 2')
            .withCodigoCliente('550074147')
            .withFechaDocumento('20210211')
            .withIdRegistro('98765')
            .withImporteDocumento('2000')
            .withMoneda('USD')
            .withOrdenAplicacion('222')
            .withRemito('Rem0022')
            .withSaldo('1500')
            .withTipoDeDocumento('CC')
            .withVencimiento('20220122')
            .build();
        insert new Dan360_TablaIntermediaCuentaCorriente__c [] {cuentaCorriente,cuentaCorriente2};
    }

    @isTest
    static void deleteTablaIntermediaCuentaCorriente(){
        Test.startTest();
        BatchDeleteTablaIntermediaCC batch = new BatchDeleteTablaIntermediaCC();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Dan360_TablaIntermediaCuentaCorriente__c> listTabla = [SELECT id FROM Dan360_TablaIntermediaCuentaCorriente__c];
        System.assertEquals(0, listTabla.size(), 'No se elimino la tabla intermedia');
    }
   
}