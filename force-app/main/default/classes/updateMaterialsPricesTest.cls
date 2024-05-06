@isTest
public with sharing class updateMaterialsPricesTest {
    static XHttpCalloutMock getResponse = new XHttpCalloutMock();
    static XHttpCalloutMock getResponseError = new XHttpCalloutMock();
    static String datee;
    static {
        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/	');

        datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
      
    List<OrderItem> orderItems = new List<OrderItem>();   

    Id pricebookId = Test.getStandardPricebookId();

    Account account = Build.anAccount()
        .withIdSap('550071632')
        .withName('Account Test')
		.build();
	insert account;

    Product2 producto = Build.aProduct()
        .withName('Producto Test')
        .withUnidadesBulto(15)        
        .withIdSap('106959')
        .build();
    insert producto;

    Product2 productoTwo = Build.aProduct()
        .withName('Producto Test2')
        .withUnidadesBulto(15)
        .withIdSap('166578')        
        .build();
    insert productoTwo;

    Dan360_PlantillaDeProductos__c templateProductsAMN05 = Build.aPlantillaDeProductos()
        .withName('AMN Canal 05')
        .withBusinessUnit('5800')
        .build();
    insert templateProductsAMN05;

    insert new Plantillas__c( AMN_05__C = 'AMN Canal 05');


     Dan360_SalesArea__c salesArea = Build.aSalesArea()
            .withName('AMN-01-01')
            .withIdExterno('5800-01-01')
            .withDistributionChannel('05')
            .withDivision('01')
            .withSalesOrganization('5800')
            .build();
        insert salesArea;
      
        Dan360_CustomerSalesArea__c customerSalesAreaSinListaPrecios = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesArea)
            .withIdExterno('5678-5800-01-01')
            .build();
        insert customerSalesAreaSinListaPrecios;

        Dan360_CustomerSalesArea__c customerSalesAreaConListaPrecios = Build.aCustomerSalesArea()
            .withName('AMN 05')
            .withClient(account)
            .withUnidadNegocio(salesArea)
            .withIdExterno('5678-5800-00-01')
            .build();
        insert customerSalesAreaConListaPrecios;

        Pricebook2 pricebookCustomer = Build.aPricebook()
            .withName('Lista Precios Customer')
            .withCustomerSalesArea(customerSalesAreaConListaPrecios)
            .isActive(true)
            .build(); 
        insert pricebookCustomer;
        id pedidoVentaDirecta = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Dan360_PedidoVentaDirecta').getRecordTypeId();
        Order orderTestSinListaPrecios = Build.anOrder()
            .withAccount(account)
            .withEffectiveDate(Date.today())
            .withEndDate(Date.today())
            .withFechaCierreCarrito(DateTime.now().addDays(5))
            .withFechaInicioCarrito(DateTime.now().addDays(1))
            .withStatus('Borrador')
            .withPurchaseOrder('00000742')
            .withBusinessUnit('5800')
            .withPricebook(pricebookId)
            .withRecordType(pedidoVentaDirecta)
            .withDescription('test')
            .withCustomerSalesArea(customerSalesAreaSinListaPrecios)
            .build();
        insert orderTestSinListaPrecios;

        Order orderTestConListaPrecios = Build.anOrder()
            .withAccount(account)
            .withEffectiveDate(Date.today())
            .withEndDate(Date.today())
            .withFechaCierreCarrito(DateTime.now().addDays(5))
            .withFechaInicioCarrito(DateTime.now().addDays(1))
            .withStatus('Borrador')
            .withPurchaseOrder('00000743')
            .withBusinessUnit('5800')
            .withPricebook(pricebookCustomer.Id)
            .withRecordType(pedidoVentaDirecta)
            .withDescription('test')
            .withCustomerSalesArea(customerSalesAreaConListaPrecios)
            .build();
        insert orderTestConListaPrecios;

        List<PricebookEntry> pricebooksEntries = [
										SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
										FROM PricebookEntry
										WHERE Pricebook2Id = :pricebookId];
        
        PricebookEntry pricebookPrice = Build.aPricebookEntry()
            .withPricebook2Id(pricebookCustomer.Id)
            .withProduct2Id(producto)
            .withUnitPrice(100)
            .withIsActive(true)
            .withExternalId('5678-5800-00-01-106959')
            .withDiscount(0.5)
            .withUnitOfMeasure('Unidad')
            .build();
        insert pricebookPrice;

        PricebookEntry pricebookPrice2 = Build.aPricebookEntry()
            .withPricebook2Id(pricebookCustomer.Id)
            .withProduct2Id(productoTwo)
            .withUnitPrice(50)
            .withIsActive(true)
            .withExternalId('5678-5800-00-01-166578')
            .withDiscount(0.5)
            .withUnitOfMeasure('Unidad')
            .build();
        insert pricebookPrice2;
    
        OrderItem item = Build.anOrderItem()
            .withOrder(orderTestConListaPrecios)
            .withProduct2Id(producto)
            .withListPrice(pricebookPrice.UnitPrice)
            .withUnitPrice(pricebookPrice.UnitPrice)
            .withPricebookEntryId(pricebookPrice)
            .withQuantity(1)
            .withDiscount(0.5)
            .build();
        insert item;

        OrderItem otherItem = Build.anOrderItem()
            .withOrder(orderTestConListaPrecios)
            .withProduct2Id(productoTwo)
            .withListPrice(pricebookPrice2.UnitPrice)
            .withUnitPrice(pricebookPrice2.UnitPrice)
            .withPricebookEntryId(pricebookPrice2)
            .withQuantity(2)
            .withDiscount(0.5)
            .build();
        insert otherItem;
        
        getResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(SapPricesMock.getSucess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);

        getResponseError.buildResponse()
            .withStatus('OK')
            .withStatusCode(500)
            .withBody(SapPricesMock.getSucess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
    }

    @isTest
    static void updatePricesFromSap(){
        Order pedido = [SELECT Id FROM Order WHERE Orden_de_compra__c = '00000743'];
        String pedidoId= pedido.Id;
        Test.setMock(HttpCalloutMock.class, getResponse);
        Test.startTest();
           String response = updateMaterialsPrices.updateMaterials(pedidoId);
        Test.stopTest();
        System.debug('response test------>'+response);

        List<String> idExternos = new List<String>{'5678-5800-00-01-106959','5678-5800-00-01-166578'};
        System.assertEquals('Se actualizacion los precios correctamente', response, ' No se actualizaron los precios correctamente');
        for(PricebookEntry pbEntryTest : [SELECT Id, Product2.Name, UnitPrice,Dan360_IDExterno__c FROM PricebookEntry WHERE Dan360_IDExterno__c IN : idExternos]){
           if(pbEntryTest.Dan360_IDExterno__c == '5678-5800-00-01-106959'){
            System.assertEquals(1249.50, pbEntryTest.UnitPrice, 'El precio del material 106959 no cambio correctamente');
           } else {
            System.assertEquals(7290.00, pbEntryTest.UnitPrice, 'El precio del material 166578 no cambio correctamente');
           }
        }

    }

    // @isTest
    // static void ifCustomerSalesAreaPriceBookEmptyCreateOne(){
    //     Order pedido = [SELECT Id FROM Order WHERE Orden_de_compra__c = '00000742'];
    //     String pedidoId= pedido.Id;
    //     Test.setMock(HttpCalloutMock.class, getResponse);
    //     Test.startTest();
    //         String response = updateMaterialsPrices.updateMaterials(pedidoId);
    //     Test.stopTest();
    //         System.debug('response test------>'+response);

    //     List<Pricebook2> newPriceBook = [SELECT Id FROM Pricebook2 WHERE Name = 'Lista Prueba Insert'];
    //     System.assertEquals(1, newPriceBook.size(), 'La lista de precios nueva no fue creada');
    //     System.assertEquals('Se actualizacion los precios correctamente', response, ' No se actualizaron los precios correctamente');

    //     for(PricebookEntry pbEntryTest : [SELECT Id, Product2.Name, UnitPrice,Dan360_IDExterno__c FROM PricebookEntry WHERE Pricebook2Id = : newPriceBook[0].Id]){
            
    //         System.debug(pbEntryTest);
    //         if(pbEntryTest.Dan360_IDExterno__c == '5678-5800-01-01-106959'){
    //          System.assertEquals(1249.50, pbEntryTest.UnitPrice, 'El precio del material 106959 no se agrego correctamente');
    //         } else {
    //          System.assertEquals(7290.00, pbEntryTest.UnitPrice, 'El precio del material 166578 no se agrego correctamente');
    //         }
    //     }
    // }


    @isTest
    static void ifupdatePricesFromSapFailDoNothing(){
        Test.setMock(HttpCalloutMock.class, getResponseError);
        Order pedido = [SELECT Id FROM Order WHERE Orden_de_compra__c = '00000743'];
        String pedidoId= pedido.Id;
        Test.startTest();
            String response = updateMaterialsPrices.updateMaterials(pedidoId);
        Test.stopTest();
              
        System.assertEquals('Fallo la actualizacion de los Precios', response, ' No fallo la actualizacion de los precios');

    }

    @isTest
    static void updatePricesFromSapFlow(){
        Order pedido = [SELECT Id FROM Order WHERE Orden_de_compra__c = '00000743'];
        List<String> pedidoId = new List<String>{pedido.Id};
        Test.setMock(HttpCalloutMock.class, getResponse);
        Test.startTest();
            updateMaterialsPrices.updateMaterialsFlow(pedidoId);
        Test.stopTest();

        List<String> idExternos = new List<String>{'5678-5800-00-01-106959','5678-5800-00-01-166578'};
        for(PricebookEntry pbEntryTest : [SELECT Id, Product2.Name, UnitPrice,Dan360_IDExterno__c FROM PricebookEntry WHERE Dan360_IDExterno__c IN : idExternos]){
           if(pbEntryTest.Dan360_IDExterno__c == '5678-5800-00-01-106959'){
            System.assertEquals(1249.50, pbEntryTest.UnitPrice, 'El precio del material 106959 no cambio correctamente');
           } else {
            System.assertEquals(7290.00, pbEntryTest.UnitPrice, 'El precio del material 166578 no cambio correctamente');
           }
        }

    }

    // @isTest
    // static void ifCustomerSalesAreaPriceBookEmptyCreateOneFlow(){
    //     Order pedido = [SELECT Id FROM Order WHERE Orden_de_compra__c = '00000742'];
    //     List<String> pedidoId = new List<String>{pedido.Id};
    //     Test.setMock(HttpCalloutMock.class, getResponse);
    //     Test.startTest();
    //         updateMaterialsPrices.updateMaterialsFlow(pedidoId);
    //     Test.stopTest();

    //     List<Pricebook2> newPriceBook = [SELECT Id FROM Pricebook2 WHERE Name = 'Lista Prueba Insert'];
    //     System.assertEquals(1, newPriceBook.size(), 'La lista de precios nueva no fue creada');
    
    //     for(PricebookEntry pbEntryTest : [SELECT Id, Product2.Name, UnitPrice,Dan360_IDExterno__c FROM PricebookEntry WHERE Pricebook2Id = : newPriceBook[0].Id]){
            
    //         System.debug(pbEntryTest);
    //         if(pbEntryTest.Dan360_IDExterno__c == '5678-5800-01-01-106959'){
    //          System.assertEquals(1249.50, pbEntryTest.UnitPrice, 'El precio del material 106959 no se agrego correctamente');
    //         } else {
    //          System.assertEquals(7290.00, pbEntryTest.UnitPrice, 'El precio del material 166578 no se agrego correctamente');
    //         }
    //     }
    // }
}