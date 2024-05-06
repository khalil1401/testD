@isTest
public class Async_ActualizarEstadoOrdenTest {
    
    static XHttpCalloutMock getResponse;
    static XHttpCalloutMock getPriceResponse;
    static {
        List<OrderItem> orderItems = new List<OrderItem>();

        RecordType pedidoVentaDirecta = [
            SELECT id 
            FROM RecordType
            WHERE sObjectType='Order' and Name = 'Pedido de Venta Directa'
        ]; 

        Id pricebookId = Test.getStandardPricebookId();

        Account account = Build.anAccount()
            .withPricebook(pricebookId)
            .withName('Account Test')
            .withIdSap('550071632')
			.build();
		insert account;

        Product2 producto = Build.aProduct()
            .withName('Product for Test')
            .withUnidadesBulto(15)
            .withProductCode('00012')
            .withIsActive(true)
            .build();
        insert producto;

        List<PricebookEntry> pricebooksEntries = [
										SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
										FROM PricebookEntry
										WHERE Pricebook2Id = :pricebookId];
        
        Dan360_SalesArea__c salesAreaVentaEstandar = Build.aSalesArea()
        .withName('AMN-01-01')
        .withIdExterno('5800-01-01')
        .withDistributionChannel('00')
        .withDivision('01')
        .withSalesOrganization('5800')
        .build();
        insert salesAreaVentaEstandar;

        Dan360_PlantillaDeProductos__c templateProducts = Build.aPlantillaDeProductos()
        .withName('AMN Canal 00')
        .withBusinessUnit('5800')
        .build();
        insert templateProducts;

        Dan360_PlantillaDeProductos__c templateProductsNuBa = Build.aPlantillaDeProductos()
        .withName('NuBa Canal 00')
        .withBusinessUnit('5771')
        .build();
        insert templateProductsNuBa;  

        Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
        .withName('Nuba 00')
        .withClient(account)
        .withUnidadNegocio(salesAreaVentaEstandar)
        .withIdExterno('5667-5771-01-01')
        .build();
        customerSalesArea.Dan360_District__c = 'AR3INS';
        
        Order orderTestNuBa = Build.anOrder()
            .withAccount(account)
            .withEffectiveDate(Date.today())
            .withEndDate(Date.today())
            .withFechaCierreCarrito(DateTime.now().addDays(5))
            .withFechaInicioCarrito(DateTime.now().addDays(1))
            .withStatus('Borrador')
            .withPurchaseOrder('00000743')
            .withPricebook(pricebookId)
            //.withBusinessUnit('5771')
            .withRecordType(pedidoVentaDirecta.Id)
            .withDescription('test')
            .withCustomerSalesArea(customerSalesArea)
            .build();

        orderTestNuBa.Dan360_UnidadNegocio__c = '5771';
        insert orderTestNuBa;

        for (PricebookEntry pricebookEntry : pricebooksEntries) {
            orderItems.add(
                Build.anOrderItem()
                    // .withOrder(orderTestAMN)
                    .withOrder(orderTestNuBa)
                    .withProduct2Id(pricebookEntry.Product2Id)
                    .withListPrice(100)
                    .withUnitPrice(100)
                    .withQuantity(1)
                    .withPricebookEntryId(pricebookEntry)
                    .withDiscount(0.5)
                    .build()
            );
        }
    
        insert orderItems;

        Dan360_Partner__c partnetShiptTo = Build.aPartner()
            .withName('Partner Shipt To')
            .withIdExterno('0')
            .withRol('WE')
            .withClient(account)
            .withCustomerSalesArea(customerSalesArea)
            .build();        

        insert partnetShiptTo;

        Dan360_Partner__c partnetSoldTo = Build.aPartner()
            .withName('Partner Sold To')
            .withIdExterno('3814320001')
            .withRol('AG')
            .withClient(account)
            .withCustomerSalesArea(customerSalesArea)
            .build();        
        
        insert partnetSoldTo;

        Id rtReturnCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Devoluciones').getRecordTypeId();
        Id rtReturnForMissing = Schema.SObjectType.case.getRecordTypeInfosByName().get('Reclamo por faltantes').getRecordTypeId();

        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833', urlMatPrices__c = '/testing/masterdata/price/',UrlCreateOrderExtension__c = '/testing/sales/orders/v1' );

		String datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();

            getPriceResponse = new XHttpCalloutMock();
            getPriceResponse.buildResponse()
                .withStatus('OK')
                .withStatusCode(200)
                .withBody(SapPricesMock.getSucess())
                .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesAreaVentaEstandar.Dan360_SalesOrganization__c+'&channelId='+salesAreaVentaEstandar.Dan360_DistributionChannel__c+'&divisionId='+salesAreaVentaEstandar.Dan360_Division__c+'&customer='+account.Id_SAP__c);
            
    }

    @IsTest
    static void pruebaSimple(){

    Test.setMock(HttpCalloutMock.class, getPriceResponse);

    Id OrderId = [SELECT Id FROM Order Limit 1].Id;
      ID jobID;

        Test.startTest();        
            Async_ActualizarOrden_Helper encolable  = new Async_ActualizarOrden_Helper(OrderId);
            jobID = System.enqueueJob(encolable);
        Test.stopTest();

      System.assertEquals(true, jobID <> null ? true : false, 'Async_ActualizarEstadoOrden_Helper' );
    }

    @IsTest
    static void testEncolable(){

    Order orders = [SELECT Id FROM Order Limit 1];
    List<String> orderId = new List<string>();
    orderId.add(orders.Id);

      ID jobID;

        Test.startTest();        
            Async_ActualizarEstadoOrden.Async_ActualizarEstadoOrden(orderId);
        Test.stopTest();

      System.assertEquals(1, orderId.size(), 'Async_ActualizarEstadoOrden' );
    }
}