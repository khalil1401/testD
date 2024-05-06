@isTest
public with sharing class BatchDeleteCuentaCorrienteTest {
    @testSetup
    private static void testSetup() {
        Account account = Build.anAccount()
            .withName('Account 1')
            .withIdSap('000012')
			.build();
		insert account;
        System.debug(account.Id);

        Account account2 = Build.anAccount()
            .withName('Account 2')
            .withIdSap('550074147')
			.build();
		insert account2;
        System.debug(account.Id);

        Order order = Build.anOrder()
			.withAccount(account)
			.withStatus('Borrador')
            .withBusinessUnit('5771')
            .withEffectiveDate(Date.today())
			.build();
		insert order;

        Order order2 = Build.anOrder()
			.withAccount(account2)
			.withStatus('Borrador')
            .withBusinessUnit('5771')
            .withEffectiveDate(Date.today())
			.build();
		insert order2;

        Dan360_Remito__c remito = Build.aRemito()
            .withPedido(order)
            .withSucursal(account)
            .withDelivery('Rem0000')
            .build();
        insert remito;

        Dan360_Remito__c remito2 = Build.aRemito()
            .withPedido(order2)
            .withSucursal(account2)
            .withDelivery('Rem0022')
            .build();
        insert remito2;

        Dan360_Factura__c factura = Build.aFactura()
            .withClient(account)
            .withRemito(remito)
            .withPedido(order)
            .withSucursal(account)
            .build();
            factura.Dan360_Id_Externo__c = '12345';
            factura.Dan360_NroComprobante__c = '00001';
        insert factura;

        Dan360_Factura__c factura2 = Build.aFactura()
            .withClient(account2)
            .withRemito(remito2)
            .withPedido(order2)
            .withSucursal(account2)
            .build();
            factura2.Dan360_Id_Externo__c = '98765';
            factura2.Dan360_NroComprobante__c = '00002';
        insert factura2;

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
        insert cuentaCorriente;

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
        insert cuentaCorriente2;
    }
    @isTest
    private static void deleteCuentaCorriente() {
        // Test data setup
        List<Dan360_TablaIntermediaCuentaCorriente__c> tablaIntermediaList = [
            SELECT Id, Name, Dan360_CodigoCliente__c, 
                                Dan360_CodigoEmpresaGrupo__c,
                                Dan360_FechaDocumento__c,
                                Dan360_IdRegistro__c,
                                Dan360_ImporteDocumento__c,
                                Dan360_Moneda__c,
                                Dan360_OrdenAplicacion__c,
                                Dan360_Saldo__c,
                                Dan360_TipoDocumento__c,
                                Dan360_Vencimiento__c,
                                Dan360_Remito__c
            FROM Dan360_TablaIntermediaCuentaCorriente__c];

        List<Dan360_DocumentosCuentaCorriente__c> cuentasCorrientesLista = CheckingAccountHelper.armarCuentaCorriente(tablaIntermediaList);
        insert cuentasCorrientesLista;
        System.debug('Tamaño: '+cuentasCorrientesLista.size());
        // Actual test
        Test.startTest();
        BatchDeleteCuentaCorriente batch = new BatchDeleteCuentaCorriente();
        Database.executeBatch(batch);
        Test.stopTest();
        List<Dan360_DocumentosCuentaCorriente__c> cuentasCorrientesToCompare = [
            SELECT Id
            FROM Dan360_DocumentosCuentaCorriente__c
        ];
        // Asserts
        System.assertEquals(0, cuentasCorrientesToCompare.size(), 'Error No se eliminaron las cuentas corrientes');
    }
}