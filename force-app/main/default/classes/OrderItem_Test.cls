@isTest
Public class OrderItem_Test {

    @isTest(seeAllData=True)
    Public static void agregoProductoAPedidoDescuentaStock(){
        
        Product2 producto = New Product2();
        producto.Name = 'Un producto';
        producto.Stock__c = 5;
        producto.IsActive = True;
        
        insert producto;
        
        PriceBookEntry entradaStandard = New PriceBookEntry();
        entradaStandard.IsActive = True;
        entradaStandard.Product2Id = producto.Id;
        entradaStandard.Pricebook2Id = standardPricebook.Id;
        entradaStandard.UnitPrice = 0;
        
        insert entradaStandard;
        
        PriceBook2 listaPrecios = New PriceBook2();
        listaPrecios.IsActive = True;
        listaPrecios.Name = 'Lista de prueba';
        
        insert listaPrecios;
        
        Order pedido = New Order();
        pedido.Status = 'Borrador';
        pedido.AccountId = cuenta.Id;
        pedido.EffectiveDate = Date.today();
        
        insert pedido;
        
        OrderItem productoDePedido = New OrderItem();
        productoDePedido.OrderId = pedido.Id;
        productoDePedido.Product2Id = producto.Id;
        productoDePedido.UnitPrice = 10;
        productoDePedido.Quantity = 2;
        productoDePedido.PricebookEntryId = entradaStandard.Id;
        
        test.startTest();
        insert productoDePedido;
        test.stopTest();
        
        Product2 productoNuevo = [SELECT Stock__c FROM Product2 WHERE Id = :producto.Id];
        System.assertEquals(3, productoNuevo.Stock__c);
    }
    
    @isTest(seeAllData=True)
    Public static void agregoProductoAPedidoSinStock(){
        
        Product2 producto = New Product2();
        producto.Name = 'Un producto';
        producto.Stock__c = 0;
        producto.IsActive = True;
        
        insert producto;
        
        PriceBookEntry entradaStandard = New PriceBookEntry();
        entradaStandard.IsActive = True;
        entradaStandard.Product2Id = producto.Id;
        entradaStandard.Pricebook2Id = standardPricebook.Id;
        entradaStandard.UnitPrice = 0;
        
        insert entradaStandard;
        
        PriceBook2 listaPrecios = New PriceBook2();
        listaPrecios.IsActive = True;
        listaPrecios.Name = 'Lista de prueba';
        
		insert listaPrecios;

        Order pedido = New Order();
        pedido.Status = 'Borrador';
        pedido.AccountId = cuenta.Id;
        //pedido.Pricebook2Id = standardPricebook.Id;
        pedido.EffectiveDate = Date.today();
        
        insert pedido;
        
        OrderItem productoDePedido = New OrderItem();
        productoDePedido.OrderId = pedido.Id;
        productoDePedido.Product2Id = producto.Id;
        productoDePedido.UnitPrice = 10;
        productoDePedido.Quantity = 2;
        productoDePedido.PricebookEntryId = entradaStandard.Id;
        
        test.startTest();
        insert productoDePedido;
        test.stopTest();
        
        OrderItem productoPedidoNuevo = [SELECT Id, Estado_stock__c  FROM OrderItem WHERE id = :productoDePedido.Id];
        System.assertEquals('Sin stock', productoPedidoNuevo.Estado_stock__c);
    }
    
            @isTest(seeAllData=True)
    Public static void updateDeProductoDePedidoActualizaStock(){
        
        Product2 producto = New Product2();
        producto.Name = 'Un producto';
        producto.Stock__c = 5;
        producto.IsActive = True;
        
        insert producto;
        
        PriceBookEntry entradaStandard = New PriceBookEntry();
        entradaStandard.IsActive = True;
        entradaStandard.Product2Id = producto.Id;
        entradaStandard.Pricebook2Id = standardPricebook.Id;
        entradaStandard.UnitPrice = 0;
        
        insert entradaStandard;
        
        PriceBook2 listaPrecios = New PriceBook2();
        listaPrecios.IsActive = True;
        listaPrecios.Name = 'Lista de prueba';
        
        insert listaPrecios;
        
        Order pedido = New Order();
        pedido.Status = 'Borrador';
        pedido.AccountId = cuenta.Id;
        //pedido.Pricebook2Id = standardPricebook.Id;
        pedido.EffectiveDate = Date.today();
        
        insert pedido;
        
        OrderItem productoDePedido = New OrderItem();
        productoDePedido.OrderId = pedido.Id;
        productoDePedido.Product2Id = producto.Id;
        productoDePedido.UnitPrice = 10;
        productoDePedido.Quantity = 2;
        productoDePedido.PricebookEntryId = entradaStandard.Id;
        
        insert productoDePedido;
        
        
        //Stock debe ser 3.
        Product2 productoNuevo = [SELECT Stock__c FROM Product2 WHERE Id = :producto.Id];
        System.assertEquals(3, productoNuevo.Stock__c);
        
        //Actualizo productoDePedido, debería actualizar el stock
        
        //Aumento en 1 la cantidad. El stock debería ser 2.
        productoDePedido.Quantity = 3;
        
        Test.startTest();
        update productoDePedido;
        Test.stopTest();
        
        Product2 productoFinal = [SELECT Stock__c FROM Product2 WHERE Id = :producto.Id];
        System.assertEquals(2, productoFinal.Stock__c);
        
    }
    
                @isTest(seeAllData=True)
    Public static void deleteDeProductoDePedidoAumentaStock(){
        
        Product2 producto = New Product2();
        producto.Name = 'Un producto';
        producto.Stock__c = 5;
        producto.IsActive = True;
        
        insert producto;
        
        PriceBookEntry entradaStandard = New PriceBookEntry();
        entradaStandard.IsActive = True;
        entradaStandard.Product2Id = producto.Id;
        entradaStandard.Pricebook2Id = standardPricebook.Id;
        entradaStandard.UnitPrice = 0;
        
        insert entradaStandard;
        
        PriceBook2 listaPrecios = New PriceBook2();
        listaPrecios.IsActive = True;
        listaPrecios.Name = 'Lista de prueba';
        
        insert listaPrecios;
		        
        Order pedido = New Order();
        pedido.Status = 'Borrador';
        pedido.AccountId = cuenta.Id;
        //pedido.Pricebook2Id = standardPricebook.Id;
        pedido.EffectiveDate = Date.today();
        
        insert pedido;
        
        OrderItem productoDePedido = New OrderItem();
        productoDePedido.OrderId = pedido.Id;
        productoDePedido.Product2Id = producto.Id;
        productoDePedido.UnitPrice = 10;
        productoDePedido.Quantity = 2;
        productoDePedido.PricebookEntryId = entradaStandard.Id;
        
        insert productoDePedido;
        
        
        //Stock debe ser 3.
        Product2 productoNuevo = [SELECT Stock__c FROM Product2 WHERE Id = :producto.Id];
        System.assertEquals(3, productoNuevo.Stock__c);
        

		//Borro el producto de pedido, debería volver el stock al original.        
        Test.startTest();
        delete productoDePedido;
        Test.stopTest();
        
        Product2 productoFinal = [SELECT Stock__c FROM Product2 WHERE Id = :producto.Id];
        System.assertEquals(5, productoFinal.Stock__c);
        
    }

	static Account cuenta;
	static PriceBook2 standardPricebook;

	static {

		standardPricebook = [SELECT Name, Id, IsStandard, isActive 
                                        FROM PriceBook2 
                                        WHERE isStandard=True];

		Account parent = Build.anAccountCliente().withName('Name').withStatus('#').build();
		insert parent;
		cuenta = Build.anAccountSucursaldeenvio()
							.withStatus('#')
							.withListaDePrecios(standardPricebook.Id)
							.withIdSucursalOracle('idTest')
							.withName('Prueba')
							.withTipoDeSucursal('SHIP_TO')						   				   
							.build();
        cuenta.ParentId = parent.Id;
        cuenta.DISTRIBUTIONCHANNELID__c = '00';
        insert cuenta;	
	}
    
}