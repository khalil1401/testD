@isTest
public class BatchCuentaCorrienteTest {
    @testSetup
    public static void makeData(){
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
    private Static void cuandoSeCorreElBatchSeCreanLasCuentasCorrientes(){
        List<Dan360_TablaIntermediaCuentaCorriente__c> tablaIntermediaLista = [SELECT Id,Dan360_Remito__c 
                                                                FROM Dan360_TablaIntermediaCuentaCorriente__c];
        Test.startTest();
            BatchCuentaCorriente batch = new BatchCuentaCorriente();
            Database.executeBatch(batch);
        Test.stopTest();
        
        List<Dan360_DocumentosCuentaCorriente__c> cuentasCorrientesLista = [SELECT Id 
                                                                FROM Dan360_DocumentosCuentaCorriente__c];
        
        System.assertEquals(tablaIntermediaLista.size(), cuentasCorrientesLista.size(), 'No se crearon las cuentas corrientes esperadas.');
    }
    
    /* @isTest 
    private static void cuandoSeCorreElBatchLosRegistrosDeLaTablaIntermediaSeEliminan(){
        Test.startTest();
            BatchCuentaCorriente batch = new BatchCuentaCorriente();
            Database.executeBatch(batch);
        Test.stopTest();
        
        List<Dan360_TablaIntermediaCuentaCorriente__c> tablaIntermediaDespuesDelBatch = [SELECT Id 
                                                                FROM Dan360_TablaIntermediaCuentaCorriente__c];
        
        System.assertEquals(0, tablaIntermediaDespuesDelBatch.size(), 'Los registros de la tabla intermedia no se eliminaron corectamente.');
    } */
}