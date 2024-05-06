@isTest
public class BatchPriceBookEntriesTest {
    static XHttpCalloutMock getPriceResponse;
    static string datee;

    static{
        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/	');
        Id pricebookId = Test.getStandardPricebookId();
        
        Account account = Build.anAccount()
        .withPricebook(pricebookId)
        .withName('Account Test')
        .withIdSap('1234')
        .build();
		insert account;

        Product2 producto = Build.aProduct()
            .withName('Producto Test')
            .withUnidadesBulto(15)
            .withProductCode('00012')
            .build();
        insert producto;
        
        Product2 productoTwo = Build.aProduct()
            .withName('Producto Test2')
            .withUnidadesBulto(15)
            .withProductCode('00013')
            .build();
        insert productoTwo;

        Dan360_SalesArea__c salesArea = Build.aSalesArea()
            .withName('AMN-01-01')
            .withIdExterno('5800-01-01')
            .withDistributionChannel('01')
            .withDivision('01')
            .withSalesOrganization('5800')
            .build();
        insert salesArea;

        Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesArea)
            .withIdExterno('5678-5800-01-01')
            .build();
        insert customerSalesArea;
        
        Pricebook2 pricebookCustomer = Build.aPricebook().withName('CustomerPriceBook').withCustomerSalesArea(customerSalesArea).isActive(true).build();
        insert pricebookCustomer;

        PricebookEntry pricebookEntryCustomer1 = Build.aPricebookEntry()
			.withPricebook2Id(pricebookCustomer.id)
			.withProduct2Id(productoTwo)
			.withUnitPrice(50)
			.withIsActive(true)
			.withDiscount(0.5)
			.withUnitOfMeasure('Unidad')
			.build();
		insert pricebookEntryCustomer1;

        PricebookEntry pricebookEntryCustomer2 = Build.aPricebookEntry()
			.withPricebook2Id(pricebookCustomer.id)
			.withProduct2Id(producto)
			.withUnitPrice(100)
			.withIsActive(true)
			.withDiscount(0.5)
			.withUnitOfMeasure('Unidad')
			.build();
		insert pricebookEntryCustomer2;

		Order orderTestAMN = Build.anOrder()
			.withAccount(account)
			.withEffectiveDate(Date.today())
			.withEndDate(Date.today())
			.withFechaCierreCarrito(DateTime.now().addDays(5))
			.withFechaInicioCarrito(DateTime.now().addDays(1))
			.withStatus('Borrador')
			.withPurchaseOrder('00000742')
			.withBusinessUnit('5800')
			//.withRecordType(pedidoVentaDirecta.Id)
			.withDescription('test')
			.withCustomerSalesArea(customerSalesArea)
            .withPricebook(pricebookCustomer.id)
			.build();
		insert orderTestAMN;

		OrderItem item = Build.anOrderItem()
			.withOrder(orderTestAMN)
			.withProduct2Id(producto)
			.withListPrice(pricebookEntryCustomer1.UnitPrice)
			.withUnitPrice(pricebookEntryCustomer1.UnitPrice)
			.withPricebookEntryId(pricebookEntryCustomer1)
			.withQuantity(1)
			.withDiscount(0.5)
			.build();
		insert item;

		OrderItem otherItem = Build.anOrderItem()
			.withOrder(orderTestAMN)
			.withProduct2Id(productoTwo)
			.withListPrice(pricebookEntryCustomer2.UnitPrice)
			.withUnitPrice(pricebookEntryCustomer2.UnitPrice)
			.withPricebookEntryId(pricebookEntryCustomer2)
			.withQuantity(2)
			.withDiscount(0.5)
			.build();
		insert otherItem;

        datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getPriceResponse = new XHttpCalloutMock();
        getPriceResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(SapPricesMock.getSucess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
    }

    @isTest
    private Static void whenAPriceBookEntryHasChangeTHeUnitPrice_TheItemsOfDraftOrderShuldChangeToTheNewPrice(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        OrderItem item = [
            SELECT Id, PricebookEntryId
            FROM OrderItem
            LIMIT 1
        ];
        
        PricebookEntry entry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Id = :item.PricebookEntryId LIMIT 1];
        entry.UnitPrice = 200;
        update entry;

        Test.startTest();
            BatchPriceBookEntries batch = new BatchPriceBookEntries();
            Database.executeBatch(batch);
        Test.stopTest();

        OrderItem itemToCompare = [SELECT id, Dan360_ListPrice__c, PricebookEntryId FROM OrderItem WHERE PricebookEntryId = :entry.Id LIMIT 1];

        System.assertEquals(entry.UnitPrice, itemToCompare.Dan360_ListPrice__c, 'El nuevo precio no se reflejo en el item de pedido');
    }

    @isTest
    private Static void whenAPriceBookEntryHasChangeTHeUnitPrice_IfTheOrderIsConfirmed_TheUnitPriceShuldNOTChange(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        Order order = [SELECT id, Status, Pricebook2Id FROM Order LIMIT 1];
        order.Status = 'Confirmado';
        order.Dan360_PedidoConfirmado__c = true;
        update order;

        PricebookEntry entry = [SELECT id, UnitPrice, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id = :order.Pricebook2Id LIMIT 1];
        entry.UnitPrice = 200;
        update entry;

        Test.startTest();
            BatchPriceBookEntries batch = new BatchPriceBookEntries();
            Database.executeBatch(batch);
        Test.stopTest();

        OrderItem itemToCompare = [SELECT id, Dan360_ListPrice__c, PricebookEntryId FROM OrderItem WHERE PricebookEntryId = :entry.Id LIMIT 1];

        System.assertNotEquals(entry.UnitPrice, itemToCompare.Dan360_ListPrice__c, 'El nuevo precio se reflejo en el item de pedido');
    }

    @isTest
    private Static void whenAPriceBookEntryTurnToInactive_TheItemsOfDraftOrderShuldBeDeleted(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        List<OrderItem> items = [
            SELECT Id, PricebookEntryId
            FROM OrderItem            
        ];
        
        PricebookEntry entry = [SELECT Id, IsActive FROM PricebookEntry WHERE Id = :items[0].PricebookEntryId LIMIT 1];
        entry.IsActive = false;
        update entry;

        Test.startTest();
            BatchPriceBookEntries batch = new BatchPriceBookEntries();
            Database.executeBatch(batch);
        Test.stopTest();

        List<OrderItem> itemsToCompare = [SELECT id, Dan360_ListPrice__c, PriceBookEntryId FROM OrderItem WHERE PricebookEntryId = :entry.id LIMIT 1];

        System.assertEquals(true, itemsToCompare.isEmpty(), 'Los items no se removieron de las ordenes');
    }
}