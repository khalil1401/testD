@IsTest
public class OrderItemTriggerHandlerTest {
    static XHttpCalloutMock getPriceResponse;
    static string datee;

    static{
        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/	');
        RecordType pedidoVentaDirecta = [SELECT id FROM RecordType where sObjectType='Order' and Name = 'Pedido de Venta Directa'];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Date todayDate = Date.Today();

        Account account = Build.anAccount()
            .withName('Cuenta Prueba')
            .withIdSap('000012')
            .withSalesDistric('Licitaciones;E-Commerce;Others')
			.withDistributionChannel('00')
            .build();
        insert account;

        Dan360_SalesArea__c salesArea = Build.aSalesArea()
            .withName('AMN-01-01')
            .withIdExterno('5800-01-01')
            .withDistributionChannel('00')
            .withDivision('01')
            .withSalesOrganization('5800')
            .build();
        insert salesArea;

        Dan360_PlantillaDeProductos__c templateProducts = Build.aPlantillaDeProductos()
            .withName('AMN Canal 00')
            .withBusinessUnit('5800')
            .build();
        insert templateProducts;

        insert new Plantillas__c(AMN_00__c = 'AMN Canal 00');

        Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesArea)
            .withIdExterno('5678-5800-01-01')
            .build();
        insert customerSalesArea;

        Pricebook2 pricebook = Build.aPricebook()
            .withName('Lista Precios Customer')
            .withCustomerSalesArea(customerSalesArea)
            .isActive(true)
            .build();
        insert pricebook;

        Product2 producto = Build.aProduct()
            .withName('Producto Test')
            .withUnidadesBulto(6)
            .withProductCode('0000012')
            .withIsActive(true)
            .withIdSap('106959')
            .build();
        insert producto;
        
        Product2 producto2 = Build.aProduct()
            .withName('Producto Test 2')
            .withUnidadesBulto(12)
            .withProductCode('0000013')
            .withIsActive(true)
            .withIdSap('166578')
            .build();
        insert producto2;

        PricebookEntry pricebookEntry = Build.aPricebookEntry()
            .withPricebook2Id(pricebook.Id)
            .withProduct2Id(producto)
            .withUnitPrice(100)
            .withIsActive(true)
            .withExternalId('5678-5800-00-01-106959')
            .withDiscount(0.5)
            .withUnitOfMeasure('Unidad')
            .build();
        insert pricebookEntry;

        PricebookEntry pricebookEntry2 = Build.aPricebookEntry()
            .withPricebook2Id(pricebook.Id)
            .withProduct2Id(producto2)
            .withUnitPrice(100)
            .withIsActive(true)
            .withExternalId('5678-5800-00-01-166578')
            .withDiscount(0.5)
            .withUnitOfMeasure('Unidad')
            .build();
        insert pricebookEntry2;
        
        Order order = Build.anOrder()
            .withAccount(account)
            .withEffectiveDate(Date.today())
            .withEndDate(Date.today())
            .withFechaCierreCarrito(DateTime.now().addDays(5))
            .withFechaInicioCarrito(DateTime.now().addDays(1))
            .withStatus('Borrador')
            .withPurchaseOrder('00000742')
            .withBusinessUnit('5800')
            .withRecordType(pedidoVentaDirecta.Id)
            .withDescription('test')
            .withCustomerSalesArea(customerSalesArea)
            .withPricebook(pricebook.Id)
            .withIdExterno('9876')
            .withProductsTemplate(templateProducts)
            .build();
        insert order;

        OrderItem orderItem = Build.anOrderItem()
            .withOrder(order)
            .withPricebookEntryId(pricebookEntry)
            .withProduct2Id(pricebookEntry.Product2Id)
            .withProduct2Id(producto)
            .withListPrice(pricebookEntry.UnitPrice)
            .withUnitPrice(pricebookEntry.UnitPrice)
            .withQuantity(2)
            .withDiscount(0.5)
            .withUnidadMedida('Trade Unit')
            .build();
        insert orderItem;

        OrderItem orderItem2 = Build.anOrderItem()
            .withOrder(order)
            .withPricebookEntryId(pricebookEntry2)
            .withProduct2Id(pricebookEntry2.Product2Id)
            .withProduct2Id(producto2)
            .withListPrice(pricebookEntry2.UnitPrice)
            .withUnitPrice(pricebookEntry2.UnitPrice)
            .withQuantity(2)
            .withDiscount(0.5)
            .withUnidadMedida('Trade Unit')
            .build();
        insert orderItem2;
        
        datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getPriceResponse = new XHttpCalloutMock();
        getPriceResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(SapPricesMock.getSucess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
    }
    @IsTest
    static void cuandoSeActualizaLaCantidadDeUnOrderItemConUnidadDeMedidaTradeUnitSeHaceUnCalculoDeRedondeo(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        List<OrderItem> orderItemTest = [SELECT Quantity FROM OrderItem];
        orderItemTest[0].Quantity = 8;
        orderItemTest[1].Quantity = 20;

        Test.startTest();
           update orderItemTest;
        Test.stopTest();

        List<OrderItem> orderItemAfterUpdate = [SELECT Quantity FROM OrderItem];
        
        System.assertEquals(12, orderItemAfterUpdate[0].Quantity, 'La cantidad no se actualizó correctamente.');
        System.assertEquals(24, orderItemAfterUpdate[1].Quantity, 'La cantidad no se actualizó correctamente.');
    }

    @IsTest
    static void cuandoSeConfirmaUnPedidoYLaCantidadDelOrderItemNoCambiaNoSeDebeActualizarLaCantidad(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        Order orderTest = [SELECT Id,Status FROM Order LIMIT 1];
        orderTest.Status = 'Confirmado';
		orderTest.Dan360_PedidoConfirmado__c = true;

        List<OrderItem> orderItemBeforeUpdate = [SELECT Quantity FROM OrderItem];

        Test.startTest();
        update orderTest;
        Test.stopTest();

        List<OrderItem> orderItemAfterUpdate = [SELECT Quantity FROM OrderItem];
        
        System.assertEquals(true, orderItemAfterUpdate[0].Quantity == orderItemBeforeUpdate[0].Quantity, 'Se actualizó la cantidad aun cuando no debería');
        System.assertEquals(true, orderItemAfterUpdate[1].Quantity == orderItemBeforeUpdate[1].Quantity, 'Se actualizó la cantidad aun cuando no debería');
    }
}