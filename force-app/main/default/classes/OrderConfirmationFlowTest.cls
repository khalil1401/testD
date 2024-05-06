@isTest
public with sharing class OrderConfirmationFlowTest {
    @TestSetup
    static void makeData(){
        Plantillas__c metadataPlantilla = new Plantillas__c(NuBa_00__c = 'Plantilla BULTOS - NUBA');
        insert metadataPlantilla;

        ApiDanone__c api = new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/', User_Key_Price__c='c3366a9f16190d9efda328ecec6f6833');
        insert api;

        RecordType pedidoVentaDirecta = [SELECT id FROM RecordType where sObjectType='Order' and Name = 'Pedido de Venta Directa'];

        String datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
		
        List<Order> orders = new List<Order>();
		List<OrderItem> orderItems = new List<OrderItem>();
		List<Product2> products = new List<Product2>();

		Id pricebookId = Test.getStandardPricebookId();

		Account account = Build.anAccount()
			.withName('Test Account')
			.withPriceBook(pricebookId)
            .withIdSap('550071632')
			.build();
		insert account;

        Product2 producto1 = Build.aProduct()
            .withName('Producto 106959')
            .withIdSap('106959')
            .withUnidadesBulto(5)
            .withIsActive(true)
            .build();
        insert producto1;

        Product2 producto2 = Build.aProduct()
            .withName('Producto 166578')
            .withIdSap('166578')
            .withUnidadesBulto(10)
            .withIsActive(true)
            .build();
        insert producto2;
         
        Dan360_SalesArea__c salesArea = Build.aSalesArea()
                                                .withName('5771-00-00')
                                                .withDistributionChannel('00')
                                                .withDivision('00')
                                                .withSalesOrganization('5771')
                                                .withIdExterno('5771-00-00')
                                                .build();
        insert salesArea;

        Dan360_PlantillaDeProductos__c plantilla = Build.aPlantillaDeProductos()
                                                        .withName('Plantilla BULTOS - NUBA')
                                                        .withBusinessUnit('5771')
                                                        .build();
        insert plantilla;

        Dan360_Cuota__c cuota = Build.aCuota()
            .withProducto(producto1)
            .withCuota(1)
            .withCuotaActiva('Activa')
            .withVigenciaDesde(Date.today())
            .withVigenciaHasta(Date.today().addDays(2))
            .build();
        insert cuota;
    }

    @isTest
    public static void ifAOrderHaveAProductDisabledReturnThatProduct(){
        Test.setMock(HttpCalloutMock.class, new priceMockCallout());
        String recordTypeVentaDirecta = [SELECT ID FROM RecordType WHERE developerName = 'Dan360_PedidoVentaDirecta'].id;

        Account cuenta = [SELECT id, Name, Id_SAP__c FROM Account LIMIT 1];
        Dan360_SalesArea__c salesArea = [SELECT Name, Dan360_DistributionChannel__c, Dan360_Division__c, Dan360_Id_Externo__c, Dan360_SalesOrganization__c FROM Dan360_SalesArea__c LIMIT 1];
        List<Product2> products = [SELECT Name, Id_SAP__c, ProductCode, Dan360_UnidadesPorBulto__c FROM Product2];

        Dan360_CustomerSalesArea__c customerSalesArea1 = Build.aCustomerSalesArea()
                                                            .withName('550071632-5771-00-00')
                                                            .withClient(cuenta)
                                                            .withUnidadNegocio(salesArea)
                                                            .withIdExterno('550071632-5771-00-00')
                                                            .build();
        Order orderTOInsert = Build.anOrder()
            .withAccount(cuenta)
            .withStatus('Borrador')
            .withRecordType(recordTypeVentaDirecta)
            .withEffectiveDate(Date.today())
            .withPurchaseOrder('')
            .withBusinessUnit('5771')
            .build();
        insert customerSalesArea1;
        insert orderTOInsert;
    
        Test.startTest();
        Test.stopTest();

        Id listaPrecioId = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Lista 550071632-5771-00-00'].Id;
        List<PricebookEntry> entradaListaPrecios = [SELECT Id, Product2Id,UnitPrice,isActive FROM PricebookEntry WHERE Pricebook2Id = :listaPrecioId];
        
        
        Order pedido = [SELECT OrderNumber,Pricebook2Id,Dan360_CustomerSalesArea__c,Dan360_PlantillaProductos__c FROM Order LIMIT 1];
        pedido.Pricebook2Id = listaPrecioId;
        update pedido;

        

        List<OrderItem> orderItems = new List<OrderItem>();
        for(PricebookEntry pbe : entradaListaPrecios){
            OrderItem productoPedido = Build.anOrderItem()
                .withOrder(pedido)
                .withProduct2Id(pbe.Product2Id)
                .withUnitPrice(pbe.UnitPrice)
                .withQuantity(2)
                .withPricebookEntryId(pbe)
                .withUnidadMedida('Trade Unit')
                .build();   
            orderItems.add(productoPedido);
        }
        insert orderItems;
        entradaListaPrecios[0].isActive = false;
        update entradaListaPrecios;
        //Empieza el test
        List<OrderItem> orderItems2 = [SELECT id, Product2Id, UnitPrice, Dan360_UnidadMedida__c,OrderId,PricebookEntryId, Quantity FROM OrderItem];
        
        List<List<OrderItem>> orderitemsToPass = new List<List<OrderItem>>();
        orderitemsToPass.add(orderItems2);
       
        List<List<OrderItem>> confirmTradeUnit = OrderConfirmationFlow.checkIfProductIsNotAvailable(orderitemsToPass);
        //Termina el test

        System.assertEquals(confirmTradeUnit[0].size(), 1);
    }
}