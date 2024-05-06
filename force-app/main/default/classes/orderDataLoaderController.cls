public with sharing class orderDataLoaderController {
    
    @AuraEnabled(cacheable=true)
    public static List<WrapperTipoVentaOpc> getTipoVenta(){
       
        List<WrapperTipoVentaOpc> listValues = new List<WrapperTipoVentaOpc>();
        
        List<PermissionSetAssignment> sinCargoPermissionSetUser = [SELECT PermissionSetId, PermissionSet.Name, Assignee.Name 
                                            FROM PermissionSetAssignment 
                                                WHERE PermissionSet.Name = 'Dan360_CrearPedidoSinCargo'
                                                AND AssigneeId = :UserInfo.getUserId()
                                                LIMIT 1
                                            ];
        
        if(sinCargoPermissionSetUser.size() > 0){
            WrapperTipoVentaOpc sinCargoValue = new WrapperTipoVentaOpc(
                'Sin Cargo',
                '05'
            ); 
            listValues.add(sinCargoValue);
        }

        WrapperTipoVentaOpc standardValue = new WrapperTipoVentaOpc(
            'Venta Directa',
            '00'
        );
        listValues.add(standardValue);
        System.debug(listValues);
        return listValues;
    }

    @AuraEnabled
    public static List<WrapperOrder> saveFile(String base64Data,String tipoVenta, Boolean isSave) {

        Id orderRecordType;
        Id standardPricebookId;
        if(tipoVenta == '00'){
            orderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Pedido de Venta Directa').getRecordTypeId();
        } else {
            orderRecordType =Schema.SObjectType.Order.getRecordTypeInfosByName().get('Pedido sin Cargo').getRecordTypeId();
            // standardPricebookId = [SELECT Id FROM Pricebook2 WHERE isStandard = true].id;
            if(Test.IsRunningTest()){
                System.debug('test1');
                standardPricebookId = Test.getStandardPricebookId();
            }else{
                System.debug('test2');
                standardPricebookId = [
                    SELECT Id 
                    FROM PriceBook2 
                    WHERE isStandard = true 
                    LIMIT 1].Id;
            }
        } 

        System.debug('orderRecordType');
        System.debug(orderRecordType);
        String data = JSON.deserializeUntyped(base64Data).toString();
        Map<String, List<String>> clientProductsToSold = new Map<String, List<String>>();
        
        Order orderToInsert ;
        Map<String,List<String>> mapShiptoProductCode = new Map<String,List<String>>();
        Map<String, List<Order>> mapOrdersToInsert = new Map<String, List<Order>>();
        Map<String,String> mapProductPriceBook = new Map<String, String>();
        Map<String, List<WrapperItems>> productWhitOrders = new Map<String, List<WrapperItems>>();
        List<String> listProductsCode = new List<String>();
        list<String> lstCSVLines = data.split('\r\n');

        System.debug(lstCSVLines);
        Boolean ordenCargada;
        List<String> dataHeader = lstCSVLines[0].split(',');
        
        Integer indexHeader = 0;
        for (Integer i = 0; i < dataHeader.size(); i++) {
            switch on indexHeader {
                when 0 {
                    if(dataHeader[0] != 'Sucursal'){ throw new AuraHandledException('Cabecera: '+dataHeader[1]+' invalida. Por favor reemplazar por: Sucursal');}
                }
                when 1 {
                    if(dataHeader[1] != 'Orden de Compra'){ throw new AuraHandledException('Cabecera: '+dataHeader[2]+' invalida. Por favor reemplazar por: Orden de Compra');}
                }
                when 2 {
                    if(dataHeader[2] != 'Codigo Producto'){ throw new AuraHandledException('Cabecera: '+dataHeader[4]+' invalida. Por favor reemplazar por: Código Producto');}
                }
                when 3 {
                    if(dataHeader[3] != 'Nombre Producto'){ throw new AuraHandledException('Cabecera: '+dataHeader[5]+' invalida. Por favor reemplazar por: Nombre Producto');}
                }
                when 4 {
                    if(dataHeader[4] != 'Cantidad Solicitada'){ throw new AuraHandledException('Cabecera: '+dataHeader[6]+' invalida. Por favor reemplazar por: Cantidad Solicitada');}
                }
            }
            indexHeader += 1;
        }

        List<WrapperOrder> wrapperOrderList = new List<WrapperOrder>();
        Map<String, Map<String,List<String>>> mapClientOrderProducts = new Map<String, Map<String,List<String>>>();
        Map<String, Map<String, Map<String,Integer>>> mapClienProductQuantity = new Map<String, Map<String, Map<String,Integer>>>();
        Map<String, Map<String, PricebookEntry>> ClientProductPricebookEntry = new Map<String, Map<String, PricebookEntry>>();
        Map<String, Map<Order,List<String>>> mapClientOrdersProducts = new Map<String, Map<Order,List<String>>>();
        Map<String, Map<Order,Map<String,Integer>>> malClientOrdersProductsQuantity = new Map<String, Map<Order,Map<String,Integer>>>();
        Map<String, Map<String, Map<Order,Set<String>>>> mapClientOrderOrderProducts = new Map<String, Map<String, Map<Order,Set<String>>>>();
        Set<String> standardProducts = new Set<String>();
        //Mapa que contiene Cliente -> Pedido -> Productos (desde el csv).
        
        for(Integer i = 1; i < lstCSVLines.size(); i++){
            List<String> csvRowData = getDataLine(lstCSVLines[i]);
            System.debug(csvRowData[3]);
            System.debug(csvRowData[4]);
            //mapClientOrderProducts
            if(!mapClientOrderProducts.containsKey(csvRowData[0])){
                mapClientOrderProducts.put(csvRowData[0], new Map<String,List<String>>());
            }
            if(!mapClientOrderProducts.get(csvRowData[0]).containsKey(csvRowData[1])){
                mapClientOrderProducts.get(csvRowData[0]).put(csvRowData[1], new List<String>());
            }
            mapClientOrderProducts.get(csvRowData[0]).get(csvRowData[1]).add(csvRowData[2]);

            //mapClienProductQuantity
            if(!mapClienProductQuantity.containsKey(csvRowData[0])){
                mapClienProductQuantity.put(csvRowData[0], new Map<String, Map<String,Integer>>());
            }
            if(!mapClienProductQuantity.get(csvRowData[0]).containsKey(csvRowData[1])){
                mapClienProductQuantity.get(csvRowData[0]).put(csvRowData[1], new Map<String,Integer>());
            }
    
            if(!mapClienProductQuantity.get(csvRowData[0]).get(csvRowData[1]).containsKey(csvRowData[2])){
                Integer quantity = Integer.ValueOf(csvRowData[4]);
                mapClienProductQuantity.get(csvRowData[0]).get(csvRowData[1]).put(csvRowData[2],quantity);
            }
            System.debug('mapClienProductQuantity ANTES');
            System.debug(mapClienProductQuantity);
            //ClientProductPricebookEntry
            if(!ClientProductPricebookEntry.containsKey(csvRowData[0])){
                ClientProductPricebookEntry.put(csvRowData[0], new Map<String, PricebookEntry>());
            }
            if(!ClientProductPricebookEntry.get(csvRowData[0]).containsKey(csvRowData[2])){
                ClientProductPricebookEntry.get(csvRowData[0]).put(csvRowData[2], new PricebookEntry());
            }

            //standardProducts
            standardProducts.add(csvRowData[2]);

            /* WrapperOrder wraperOrder = new WrapperOrder(
                csvRowData[0],
                csvRowData[1],
                csvRowData[2],
                csvRowData[3],
                integer.valueof(csvRowData[4])
                );
            wrapperOrderList.add(wraperOrder); */
        }
        System.debug('standardProducts');
        System.debug(standardProducts);
        Map<String,String> mapClientAccountID = getMapAccountId(mapClientOrderProducts);

        checkDuplicatedProduct(mapClientOrderProducts);

        Map<String, String> mapProductName = new Map<String, String>();
        for(String productId : standardProducts){
            if(!mapProductName.containsKey(productId)){
                mapProductName.put(productId,'');
            }
        }
        Map<String, Map<String, String>> mapClientUnitBusinessPricebookId = new Map<String, Map<String, String>>();
        if(tipoVenta == '00'){
            mapClientUnitBusinessPricebookId = getPricebookForBusnissUnit(mapClientOrderProducts);
        }
    
        WrapperMaps wrapMaps = getClientsWithOrganizationAndProduct(mapClientOrderProducts, tipoVenta, mapProductName);
        System.debug('mapProductName');
        System.debug(mapProductName);
        Map<String, Map<String,List<String>>> organizationToCallOut = wrapMaps.mapClientOrganizationProducts;
        System.debug('wrapMaps..mapClientOrganizationProducts');
        System.debug(wrapMaps.mapClientOrganizationProducts);
        //Validaciones

        Map<String,Set<String>> mapClienOrganizationCallOut = new Map<String,Set<String>>();
        System.debug('mapClientOrderProducts');
        System.debug(mapClientOrderProducts);
        System.debug('mapClientProductOrganization');
        System.debug(wrapMaps.mapClientProductOrganization);
        
        for(String client :mapClientOrderProducts.keySet()){
            List<String> productsAMN = new List<String>();
            List<String> productsNuba = new List<String>();
            for(String ordenCompra : mapClientOrderProducts.get(client).keySet()){
                System.debug(ordenCompra);
                if(String.isEmpty(ordenCompra)){
                    List<String> products = mapClientOrderProducts.get(client).get(ordenCompra);
                    Map<String,Integer> mapProductQuantity = mapClienProductQuantity.get(client).get(ordenCompra);
                    for(String product :products){
                        String organization = wrapMaps.mapClientProductOrganization.get(client).get(product);
                        if(organization == '5800'){
                            productsAMN.add(product);
                            Integer Cantidad = mapProductQuantity.get(product);
                            if(!mapClienProductQuantity.get(client).containsKey('OrdenCompraA')){
                                mapClienProductQuantity.get(client).put('OrdenCompraA', new Map<String,Integer>());
                            }
                            mapClienProductQuantity.get(client).get('OrdenCompraA').put(product,Cantidad);
                        } else if(organization == '5771'){
                            productsNuba.add(product);
                            Integer Cantidad = mapProductQuantity.get(product);
                            if(!mapClienProductQuantity.get(client).containsKey('OrdenCompraN')){
                                mapClienProductQuantity.get(client).put('OrdenCompraN', new Map<String,Integer>());
                            }
                            mapClienProductQuantity.get(client).get('OrdenCompraN').put(product,Cantidad);
                        }
                    }
                       
                    if(productsAMN.size() > 0){
                        mapClientOrderProducts.get(client).put('OrdenCompraA', productsAMN);
                    }
                    if(productsNuba.size() > 0){
                        mapClientOrderProducts.get(client).put('OrdenCompraN', productsNuba);
                    }
                    mapClientOrderProducts.get(client).remove(ordenCompra);
                    mapClienProductQuantity.get(client).remove(OrdenCompra);
                }  
            }
        }
        System.debug('mapClienProductQuantity');
        System.debug(mapClienProductQuantity);
        System.debug('mapClientOrderProducts MODIFICADO');
        System.debug(mapClientOrderProducts);

        for(String client : mapClientOrderProducts.keySet()){
            if(wrapMaps.mapClientProductOrganization.containsKey(client)){ // Validacion Cliente
                Map<String,List<String>> mapOrderProducts = mapClientOrderProducts.get(client);
                Map<String,String> productOrganization = wrapMaps.mapClientProductOrganization.get(client);
                for(String orden : mapOrderProducts.keySet()){
                    List<String> products = mapOrderProducts.get(orden);
                    for(String product : products){
                        System.debug(product);
                        System.debug(productOrganization);
                        if(productOrganization.containsKey(product)){// Validacion de producto para el cliente
                            String organizationToCompare = productOrganization.get(products[0]);
                            String organization = productOrganization.get(product);
                            System.debug(organizationToCompare);
                            System.debug(organization);
                            System.debug(organizationToCompare == organization);
                            if(organizationToCompare == organization){ // Validacion misma Organizacion para los productos dentro de una misma orden.
                                String accountIdSF = mapClientAccountID.get(client);
                                if(!mapClientOrderOrderProducts.containsKey(client)){
                                    mapClientOrderOrderProducts.put(client, new Map<String, Map<Order,Set<String>>>());
                                }
                                if(!mapClientOrdersProducts.containsKey(client)){
                                    mapClientOrdersProducts.put(client, new Map<Order,List<String>>());   
                                }
                                if(!mapClientOrderOrderProducts.get(client).containsKey(orden)){
                                    System.debug('orden del if');
                                    System.debug(orden);
                                    Id listaPrecio;
                                    if(tipoVenta == '05'){
                                        listaPrecio = standardPricebookId;
                                    } else {
                                        listaPrecio = mapClientUnitBusinessPricebookId.get(client).get(organizationToCompare);
                                    }
                                    Order pedido = new Order(
                                        RecordTypeId = orderRecordType,
                                        Pricebook2Id = listaPrecio,
                                        Orden_de_compra__c=orden,
                                        Dan360_UnidadNegocio__c=organizationToCompare, 
                                        Status = 'Borrador',
                                        AccountId = accountIdSF,
                                        EffectiveDate = Date.today());
                                    System.debug('pedido');   
                                    System.debug(pedido);
                                    List<String> listProductsOrders = mapClientOrderProducts.get(client).get(orden);
                                    Map<Order,Set<String>> mapToinsert = new Map<Order,Set<String>>();
                                    mapToinsert.put(pedido, new Set<String>{product});
                                    mapClientOrderOrderProducts.get(client).put(orden,mapToinsert );
                                    if(!mapClientOrdersProducts.get(client).containsKey(pedido)){
                                        mapClientOrdersProducts.get(client).put(pedido, new List<String>());
                                    }
                                    mapClientOrdersProducts.get(client).get(pedido).addAll(listProductsOrders);

                                    Map<String,Integer> mapProductQuantity = mapClienProductQuantity.get(client).get(orden);
                                    if(!malClientOrdersProductsQuantity.containsKey(client)){
                                        malClientOrdersProductsQuantity.put(client, new Map<Order,Map<String,Integer>>());
                                    }
                                    if(!malClientOrdersProductsQuantity.get(client).containsKey(pedido)){
                                        malClientOrdersProductsQuantity.get(client).put(pedido, new Map<String,Integer>());
                                    }
                                    for(String productOrder : listProductsOrders){
                                        if(!malClientOrdersProductsQuantity.get(client).get(pedido).containsKey(productOrder)){
                                            Integer quantity = mapProductQuantity.get(productOrder);
                                            malClientOrdersProductsQuantity.get(client).get(pedido).put(productOrder, quantity);
                                        }
                                    }
                                }
                                
                                if(!mapClienOrganizationCallOut.containsKey(client)){
                                    mapClienOrganizationCallOut.put(client, new Set<String>());
                                }
                                mapClienOrganizationCallOut.get(client).add(organizationToCompare);
                                
                            }else{
                                throw new ApplicationException('El producto: '+ product + ' para la orden: '+ orden + ' no pertenece a la misma unidad de negocio del pedido ('+ organizationToCompare+')');
                            }
                        } else {
                            throw new ApplicationException('El producto: '+ product + ' para cliente: '+client+' es incorrecto');
                        } 
                    }
                }
            } else{
                throw new ApplicationException('No pude crear pedidos para el cliente: '+ client);
            }
        }

        // INICIO --- Traer Lista de precios actualizada. 
        Map<String,List<Dan360_CustomerSalesArea__c>> mapClientCustomerSalesAreas = new Map<String,List<Dan360_CustomerSalesArea__c>>();

        for(String client :mapClienOrganizationCallOut.keySet()){
            for(Dan360_CustomerSalesArea__c customerSalesArea : [
                SELECT Id, Dan360_SalesArea__c, Dan360_Customer__r.Id_SAP__c, Dan360_Id_Externo__c, 
                    Dan360_SalesArea__r.Dan360_Division__c,Dan360_SalesArea__r.Dan360_DistributionChannel__c,Dan360_SalesArea__r.Dan360_SalesOrganization__c
                FROM Dan360_CustomerSalesArea__c
                WHERE (Dan360_Customer__r.Id_SAP__c = :client AND Dan360_Block__c = false)
                    AND (Dan360_SalesArea__r.Dan360_DistributionChannel__c = :tipoVenta AND Dan360_SalesArea__r.Dan360_SalesOrganization__c IN :mapClienOrganizationCallOut.get(client))
            ]){
                System.debug(customerSalesArea);
                if(!mapClientCustomerSalesAreas.containsKey(client)){
                    mapClientCustomerSalesAreas.put(client, new List<Dan360_CustomerSalesArea__c>());
                }
                mapClientCustomerSalesAreas.get(client).add(customerSalesArea);
            }
        }
        System.debug('mapClientCustomerSalesAreas');
        System.debug(mapClientCustomerSalesAreas);
        
        Map<String, PricebookEntry> mapStandardPrice = new Map<String, PricebookEntry>();
        if(tipoVenta == '05'){
            for(PricebookEntry entry : [SELECT Id, Pricebook2Id, UnitPrice , Product2.Id_SAP__c , Product2Id
                                        FROM PricebookEntry 
                                        WHERE Product2.Id_SAP__c IN :standardProducts
                                        AND Pricebook2.IsStandard = true]){
                if(!mapStandardPrice.containsKey(entry.Product2.Id_SAP__c)){
                    mapStandardPrice.put(entry.Product2.Id_SAP__c, entry);
                }
            }
        }

        updateMaterialsPrices.MapWrappers mapWrappers = updateMaterialsPrices.updatePricesSAPandGetPrices(mapClientCustomerSalesAreas,ClientProductPricebookEntry, mapStandardPrice);
        //Map<String, Map<String, PricebookEntry>> mapClientProductPricebookDONE = updateMaterialsPrices.updatePricesSAPandGetPrices(mapClientCustomerSalesAreas,ClientProductPricebookEntry, mapStandardPrice);
        Map<String, Map<String, PricebookEntry>> mapClientProductPricebookDONE = mapWrappers.clientProductPricebookEntry;
        Map<String,PricebookEntry> pricebookIdExternoPricebookEntry = mapWrappers.pricebookIdExternoPricebookEntry;
        System.debug('pricebookIdExternoPricebookEntry');
        System.debug(pricebookIdExternoPricebookEntry);
        System.debug('malClientOrdersProductsQuantity');
        System.debug(malClientOrdersProductsQuantity);

        // FIN --- Traer Lista de precios actualizada. 

        // INICIO -- CREAR ORDERITEMS
        Map<String, Map<String, Map<String, Decimal>>> mapClienteUnidadNegocioproductTradeUnitBulto = wrapMaps.mapClienteUnidadNegocioproductTradeUnitBulto;
        Map<String, Map<String, Map<String, Map<String,Integer>>>> mapWrapperToShow = new  Map<String, Map<String, Map<String, Map<String,Integer>>>>();
            Map<String, Map<Order, List<OrderItem>>> mapOrderOrderItem = getMapOrdersAndProductsToInsert(tipoVenta,pricebookIdExternoPricebookEntry,malClientOrdersProductsQuantity,mapClientProductPricebookDONE,mapClienteUnidadNegocioproductTradeUnitBulto, mapWrapperToShow,mapProductName);
            Map<String,Map<String,List<OrderItem>>> mapClientOrderOrderitem = new Map<String,Map<String,List<OrderItem>>>();
            List<Order> listOrderToInsert = new list<Order>();
            for(String client : mapOrderOrderItem.keySet()){
                for(Order orden : mapOrderOrderItem.get(client).keySet()){
                    System.debug(orden);
                    listOrderToInsert.add(orden);
                    if(!mapClientOrderOrderitem.containsKey(client)){
                        mapClientOrderOrderitem.put(client, new Map<String,List<OrderItem>>());
                    }
                    if(!mapClientOrderOrderitem.get(client).containsKey(orden.Orden_de_compra__c)){
                        mapClientOrderOrderitem.get(client).put(orden.Orden_de_compra__c, mapOrderOrderItem.get(client).get(orden));
                    }
                }
            }
            System.debug(mapClientOrderOrderitem);
            System.debug(listOrderToInsert);
        //Map<String, Map<String, Map<String, Map<String,Integer>>>>
        System.debug('mapWrapperToShow');
        System.debug(mapWrapperToShow);

        for (String client :mapWrapperToShow.keySet()){
            for(String ordenCompra : mapWrapperToShow.get(client).keySet()){
                for(String productId : mapWrapperToShow.get(client).get(ordenCompra).keySet()){
                    for(String productName : mapWrapperToShow.get(client).get(ordenCompra).get(productId).keySet()){
                        Integer productQuantity = mapWrapperToShow.get(client).get(ordenCompra).get(productId).get(productName);
                        WrapperOrder wraperOrder = new WrapperOrder(
                            client,
                            ordenCompra,
                            productId,
                            productName,
                            productQuantity
                            );
                        wrapperOrderList.add(wraperOrder);
                    }
                }
            }
        }

        if(isSave){
            Database.SaveResult[] upResult = Database.insert(listOrderToInsert,true);
            for (Database.SaveResult sr : upResult) {
                if (sr.isSuccess()) {
                    System.debug('Exito: '+ sr.getId());
                }
                else {             
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('fields that affected this error: ' + err.getFields());
                        
                    }
                }
            }

            if (Test.isRunningTest()) {
                List<Order> ordenIntert = [SELECT Id, Dan360_CustomerSalesArea__c FROM Order WHERE Orden_de_compra__c != '00000742'];
                //List<Pricebook2> pricebookTest = [SELECT Id FROM Pricebook2 WHERE Dan360_CustomerSalesArea__c = ];

                System.debug(ordenIntert);
            }

            List<OrderItem> listOrdenItemToInsert = new List<OrderItem>();

            for(String client : mapOrderOrderItem.keySet()){
                for(Order orden : mapOrderOrderItem.get(client).keySet()){ //Orden_de_compra__c
                        
                        for(String orderString : mapClientOrderOrderitem.get(client).keySet()){
                            
                            if(orderString == orden.Orden_de_compra__c){
                                List<OrderItem> listOrderItem = mapClientOrderOrderitem.get(client).get(orderString);
                                
                                for(OrderItem orderItemToAdd : listOrderItem){
                                    orderItemToAdd.OrderId = orden.Id;
                                    listOrdenItemToInsert.add(orderItemToAdd);
                                }
                            }
                        }
                }
            }
           
            System.debug(listOrdenItemToInsert);
            Database.SaveResult[] upResult2 = Database.insert(listOrdenItemToInsert,true);
            for (Database.SaveResult sr : upResult2) {
                if (sr.isSuccess()) {
                    System.debug('Exito: '+ sr.getId());
                }
                else {             
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('fields that affected this error: ' + err.getFields());
                        
                    }
                }
            }
        }
        
        System.debug('wrapperOrderList -->'+wrapperOrderList);
        return wrapperOrderList;
    }


    public static Map<String, Map<Order, List<OrderItem>>> getMapOrdersAndProductsToInsert(String tipoVenta,Map<String,PricebookEntry> pricebookIdExternoPricebookEntry, Map<String, Map<Order,Map<String,Integer>>> malClientOrdersProductsQuantity, Map<String, Map<String, PricebookEntry>> mapClientProductPricebookDONE, Map<String, Map<String, Map<String, Decimal>>> mapClienteUnidadNegocioproductTradeUnitBulto, Map<String, Map<String, Map<String, Map<String,Integer>>>> mapWrapperToShow,Map<String, String> mapProductName){
        Map<String, Map<Order, List<OrderItem>>> mapOrderOrderItemsToInsert = new Map<String, Map<Order, List<OrderItem>>>();
        System.debug('mapClienteUnidadNegocioproductTradeUnitBulto dentro del armado del OLI');
        System.debug(mapClienteUnidadNegocioproductTradeUnitBulto);
        System.debug('mapWrapperToShow dentro del armado del OLI');
        System.debug(mapWrapperToShow);
        System.debug('tipoVenta');
        System.debug(tipoVenta);
        for(String client : malClientOrdersProductsQuantity.keySet()){
            if(!mapOrderOrderItemsToInsert.containsKey(client)){
                mapOrderOrderItemsToInsert.put(client, new Map<Order, List<OrderItem>>());
            }
            for(Order orden : malClientOrdersProductsQuantity.get(client).keySet()){
                if(!mapOrderOrderItemsToInsert.get(client).containsKey(orden)){
                    mapOrderOrderItemsToInsert.get(client).put(orden, new List<OrderItem>());
                }
                System.debug('Orden');
                System.debug(orden);
                System.debug('Unidad de negocio Orden: ');
                System.debug(orden.Dan360_UnidadNegocio__c);
                Map<String, Decimal> productBulto = mapClienteUnidadNegocioproductTradeUnitBulto.get(client).get(orden.Dan360_UnidadNegocio__c);
                List<OrderItem> listOrdenItem = new List<OrderItem>();
                for(String product : malClientOrdersProductsQuantity.get(client).get(orden).keySet()){
                    Integer productQuantity;
                    String unidadMedidaOrderItem = 'Unidad';
                    if(productBulto.containsKey(product)){
                        unidadMedidaOrderItem = 'Trade Unit';
                        Decimal dif = math.mod(malClientOrdersProductsQuantity.get(client).get(orden).get(product), Integer.valueOf(productBulto.get(product)));
                        System.debug(dif);
                        if(dif == 0){
                           productQuantity = malClientOrdersProductsQuantity.get(client).get(orden).get(product);
                        } else {
                            Integer quantity = Integer.valueOf(productBulto.get(product)) - Integer.valueOf(dif);
                            productQuantity = malClientOrdersProductsQuantity.get(client).get(orden).get(product) + quantity;
                        }
                        //Integer quantity = Integer.valueOf(productBulto.get(product)) - Integer.valueOf(dif);
                        //System.debug(quantity);
                        //productQuantity = malClientOrdersProductsQuantity.get(client).get(orden).get(product) + quantity;
                        System.debug(productQuantity);
                    } else {
                        productQuantity = malClientOrdersProductsQuantity.get(client).get(orden).get(product);
                    }
                    ///////////////
                    if(!mapWrapperToShow.containsKey(client)){
                        mapWrapperToShow.put(client, new  Map<String, Map<String, Map<String,Integer>>>());
                    }
                    if(!mapWrapperToShow.get(client).containsKey(orden.Orden_de_compra__c)){
                        mapWrapperToShow.get(client).put(orden.Orden_de_compra__c, new Map<String, Map<String,Integer>>());
                    }
                    if(!mapWrapperToShow.get(client).get(orden.Orden_de_compra__c).containsKey(product)){
                        String productName = mapProductName.get(product);
                        mapWrapperToShow.get(client).get(orden.Orden_de_compra__c).put(product, new Map<String,Integer>{productName => productQuantity});
                    }
                    ////////////////////
                    PricebookEntry pricebookEntryProduct = mapClientProductPricebookDONE.get(client).get(product);
                    System.debug('pricebookEntryProduct');
                    System.debug(pricebookEntryProduct);
                    Decimal precioUnitario ;
                    if(tipoVenta == '00'){
                        String priceWithDiscount = pricebookIdExternoPricebookEntry.get(pricebookEntryProduct.Dan360_IDExterno__c).UnitPriceWithDiscountS__c;

                        String decimalString1 = '00';
                        List<String> listString1 = priceWithDiscount.split('\\.');
                
                        if(listString1.size() > 1){
                            if(listString1[1].length() == 1){
                                decimalString1 = listString1[1]+'0';
                            }else{
                                decimalString1 = listString1[1].substring(0,2);
                            }
                        }
                
                        String fullUnitPriceString1 =  listString1[0]+'.'+decimalString1;
                        precioUnitario = Decimal.valueOf(fullUnitPriceString1);
                    } else {
                        precioUnitario = pricebookEntryProduct.UnitPrice - ((pricebookEntryProduct.UnitPrice * pricebookEntryProduct.Dan360_Descuento__c)/100);
                    }

                    OrderItem newOrderItem = new OrderItem();
                    Product2 prodRefference = new Product2(
                            Id_SAP__c = product
                    );
                    newOrderItem.Product2 = prodRefference;
                    newOrderItem.UnitPrice = precioUnitario;
                    newOrderItem.Quantity = productQuantity;
                    newOrderItem.PricebookEntryId = pricebookEntryProduct.Id;
                    newOrderItem.Dan360_Descuento__c = pricebookEntryProduct.Dan360_Descuento__c;
                    newOrderItem.Dan360_ListPrice__c = pricebookEntryProduct.UnitPrice;
                    newOrderItem.Dan360_UnidadMedida__c = unidadMedidaOrderItem;
                    System.debug('newOrderItem');
                    System.debug(newOrderItem);
                    listOrdenItem.add(newOrderItem);
                }
                mapOrderOrderItemsToInsert.get(client).get(orden).addAll(listOrdenItem);
            }
        }
        return mapOrderOrderItemsToInsert;
    }

    public static List<String> getDataLine(String csvLine) {
        String prevLine = csvLine;
            Integer startIndex;
            Integer endIndex;
            
            while(csvLine.indexOf('"') > -1){
            
                if(startIndex == null){
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                    
                }else{
                    if(endIndex == null){
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                        
                    }
                }
                
                if(startIndex != null && endIndex != null){
                    String sub = csvLine.substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
    
                    startIndex = null;
                    endIndex = null;
                }
            }
            
            List<String> csvRowData = new List<String>();
            Integer indexColumn = 0;

            // 0 , 1, 2 , 4, 6
            String spliter;
            if(csvLine.split(';').size() > 1){
                spliter = ';';
            }else{
                spliter = ',';
            }
            for(String column : csvLine.split(spliter)){
                if(String.isBlank(column) && (indexColumn == 0 || indexColumn == 2 || indexColumn == 4)){
                    system.debug('La posicion: ' + indexColumn + ' esta vacia');
                    String columnName; 
                    switch on indexColumn {
                        when 0 {
                            columnName = 'Sucursal';
                        }
                        when 2 {
                            columnName = 'Codigo de Producto';
                        }
                        when 4 {
                            columnName = 'Cantidad Solicitada';
                        }
                    }

                    throw new AuraHandledException('Formato invalido o vacio: '+columnName);
                } 

                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                csvRowData.add(column);
                indexColumn += 1;
            }
            return csvRowData;
    }

    public static void checkDuplicatedProduct(Map<String, Map<String,List<String>>> mapClientOrderProducts){
        for(String client : mapClientOrderProducts.keySet()){
            Map<String,List<String>> OrderProducts = mapClientOrderProducts.get(client);
            for(String orden : OrderProducts.keySet()){
                List<String> products = OrderProducts.get(orden);

                for(Integer i = 0; i < products.size(); i++){
                    Integer count = 0;
                    for(Integer j = 0; j < products.size(); j++){
                        if(products[i] == products[j]){
                            count += 1;
                        }
                    }
                 	if(count == 2){
                        throw new ApplicationException('La orden: '+orden+ ' para el cliente: '+client+ ' tiene el producto: '+products[i]+ ' duplicado');
                    }
                }
            }
        }
    }

    public static WrapperMaps getClientsWithOrganizationAndProduct(Map<String, Map<String,List<String>>> mapClientOrderProducts, String tipoVenta, Map<String, String> mapProductName){
        Map<String, Map<String,List<String>>> mapClientOrganizationProducts = new Map<String, Map<String,List<String>>>();
        Map<String,List<String>> orgProducts = new Map<String, List<String>>();
        Map<String, Map<String,String>> mapClientTemplates = new Map<String, Map<String,String>>();
        Map<String, Map<String, Map<String, Decimal>>> mapClienteUnidadNegocioproductTradeUnitBulto = new Map<String, Map<String, Map<String, Decimal>>>();

        for(Account accId : [SELECT Id_SAP__c FROM Account WHERE Id_SAP__c = :mapClientOrderProducts.keySet()]){
            if(!mapClientOrganizationProducts.containsKey(accId.Id_SAP__c)){
                mapClientOrganizationProducts.put(accId.Id_SAP__c, new Map<String,List<String>>());
            }
            if(!mapClienteUnidadNegocioproductTradeUnitBulto.containsKey(accId.Id_SAP__c)){
                mapClienteUnidadNegocioproductTradeUnitBulto.put(accId.Id_SAP__c, new Map<String, Map<String, Decimal>>());
            }
        }

        for(Dan360_CustomerSalesArea__c customerSalesArea : [SELECT id, Dan360_Customer__r.Id_SAP__c, Dan360_SalesArea__r.Dan360_SalesOrganization__c 
                                                             FROM Dan360_CustomerSalesArea__c 
                                                             WHERE Dan360_Customer__r.Id_SAP__c = :mapClientOrderProducts.keySet()
                                                                AND (Dan360_Block__c = false AND Dan360_SalesArea__r.Dan360_DistributionChannel__c = :tipoVenta)
                                                                AND Dan360_District__c != 'AR3TEN'
                                                             ]){
            if(mapClientOrganizationProducts.containsKey(customerSalesArea.Dan360_Customer__r.Id_SAP__c)){
                if(!mapClientOrganizationProducts.get(customerSalesArea.Dan360_Customer__r.Id_SAP__c).containsKey(customerSalesArea.Dan360_SalesArea__r.Dan360_SalesOrganization__c)){
                    mapClientOrganizationProducts.get(customerSalesArea.Dan360_Customer__r.Id_SAP__c).put(customerSalesArea.Dan360_SalesArea__r.Dan360_SalesOrganization__c, new List<String>());
                }
            }
        }

        Set<String> templatesIds = new Set<String>();
        for(dAN360_PlantillaporcCuenta__c templates : [SELECT id, Dan360_Cuenta__r.Id_SAP__c, Dan360_UnidadNegocio__c, Dan360_PlantillaDeProductos__c 
                                                       FROM dAN360_PlantillaporcCuenta__c
                                                       WHERE  Dan360_Cuenta__r.Id_SAP__c = :mapClientOrderProducts.keySet() AND Dan360_DistributionChannel__c = :tipoVenta ]){
            if(!mapClientTemplates.containsKey(templates.Dan360_Cuenta__r.Id_SAP__c)){
                mapClientTemplates.put(templates.Dan360_Cuenta__r.Id_SAP__c, new Map<String,String>());
            }
            if(!mapClientTemplates.get(templates.Dan360_Cuenta__r.Id_SAP__c).containsKey(templates.Dan360_UnidadNegocio__c)){
                mapClientTemplates.get(templates.Dan360_Cuenta__r.Id_SAP__c).put(templates.Dan360_UnidadNegocio__c,templates.Dan360_PlantillaDeProductos__c);
            }
            templatesIds.add(templates.Dan360_PlantillaDeProductos__c);
            System.debug('templates');
            System.debug(templates);
            if(mapClienteUnidadNegocioproductTradeUnitBulto.containsKey(templates.Dan360_Cuenta__r.Id_SAP__c)){
                mapClienteUnidadNegocioproductTradeUnitBulto.get(templates.Dan360_Cuenta__r.Id_SAP__c).put(templates.Dan360_UnidadNegocio__c, new  Map<String, Decimal>());
            }
        }
        System.debug('mapClientTemplates');
        System.debug(mapClientTemplates);
        Map<String, List<String>> templateProducts = new Map<String, List<String>>();


        Map<String, List<String>> mapTemplateProductWithTradeUnit = new Map<String, List<String>>();
        List<String> productosWithTradeToRetrieve = new List<String>();
        for(Dan360_ProductoPorPlantilla__c templateProduct : [SELECT Dan360_Producto__r.Id_SAP__c,Dan360_Producto__r.Name, Dan360_PlantillaProductos__c, Dan360_UnidadDeMedida__c 
                                                              FROM Dan360_ProductoPorPlantilla__c
                                                              WHERE Dan360_Activo__c = true 
                                                                AND Dan360_PlantillaProductos__c = :templatesIds
                                                            ]){
            if(!templateProducts.containsKey(templateProduct.Dan360_PlantillaProductos__c)){
                templateProducts.put(templateProduct.Dan360_PlantillaProductos__c, new List<String>());
            }
            templateProducts.get(templateProduct.Dan360_PlantillaProductos__c).add(templateProduct.Dan360_Producto__r.Id_SAP__c);
            if(templateProduct.Dan360_UnidadDeMedida__c == 'Trade Unit'){
                if(!mapTemplateProductWithTradeUnit.containsKey(templateProduct.Dan360_PlantillaProductos__c)){
                    mapTemplateProductWithTradeUnit.put(templateProduct.Dan360_PlantillaProductos__c,new List<String>());
                }
                mapTemplateProductWithTradeUnit.get(templateProduct.Dan360_PlantillaProductos__c).add(templateProduct.Dan360_Producto__r.Id_SAP__c);
                productosWithTradeToRetrieve.add(templateProduct.Dan360_Producto__r.Id_SAP__c);
            }

            if(mapProductName.containsKey(templateProduct.Dan360_Producto__r.Id_SAP__c)){
                mapProductName.put(templateProduct.Dan360_Producto__r.Id_SAP__c, templateProduct.Dan360_Producto__r.Name);
            }
        }
        System.debug('productosWithTradeToRetrieve');
        System.debug(productosWithTradeToRetrieve);
        System.debug('mapClientOrganizationProducts');
        System.debug(mapClientOrganizationProducts);
        
        Map<String, Decimal> mapProductBultoSF = new Map<String, Decimal>();

        for(Product2 productSF : [SELECT Id_SAP__c, Dan360_UnidadesPorBulto__c FROM Product2 WHERE Id_SAP__c IN :productosWithTradeToRetrieve]){
            if(!mapProductBultoSF.containsKey(productSF.Id_SAP__c)){
                mapProductBultoSF.put(productSF.Id_SAP__c, productSF.Dan360_UnidadesPorBulto__c);
            }
        }
        System.debug('mapProductBultoSF');
        System.debug(mapProductBultoSF);
        System.debug('mapTemplateProductWithTradeUnit');
        System.debug(mapProductBultoSF);

            for(String clientId : mapClientTemplates.keySet()){
                Map<String,String> mapOrganizationTemplate = mapClientTemplates.get(clientId);
                for(String organization : mapClientOrganizationProducts.get(clientId).keySet()){ 
                    String template = mapOrganizationTemplate.get(organization);
                    List<String> products = templateProducts.get(template);
                    List<String> productsWithTrade = mapTemplateProductWithTradeUnit.get(template);
                    System.debug(productsWithTrade);
                    mapClientOrganizationProducts.get(clientId).get(organization).addAll(products);
                    if(productsWithTrade != null){
                      for(String producto : productsWithTrade){
                        Decimal bulto = mapProductBultoSF.get(producto);
                        mapClienteUnidadNegocioproductTradeUnitBulto.get(clientId).get(organization).put(producto,bulto);
                   		}  
                    }
                    
                    
                }
            }
        System.debug('mapClienteUnidadNegocioproductTradeUnitBulto');
        System.debug(mapClienteUnidadNegocioproductTradeUnitBulto);

        Map<String, Map<String,String>> mapClientProductOrganization = new Map<String, Map<String,String>>();
        for(String client : mapClientOrganizationProducts.keySet()){
           Map<String,List<String>> organizationProducts = mapClientOrganizationProducts.get(client);
           for(String organization : organizationProducts.keySet()){
                List<String> products = organizationProducts.get(organization);
                for(String producto : products){
                    if(!mapClientProductOrganization.containsKey(client)){
                        mapClientProductOrganization.put(client, new Map<String,String>());
                    }
                    if(!mapClientProductOrganization.get(client).containsKey(producto)){
                        mapClientProductOrganization.get(client).put(producto,organization);
                    }
                }
           }
        }
        WrapperMaps wrapMaps = new WrapperMaps(
            mapClientProductOrganization,
            mapClientOrganizationProducts,
            mapClienteUnidadNegocioproductTradeUnitBulto
        );
        return wrapMaps;
    }

    public static Map<String,String> getMapAccountId (Map<String, Map<String,List<String>>> mapClientOrderProducts) {
        Map<String,String> mapClientAccountId = new Map<String,String>();
        for (Account accounts : [
            SELECT Id, Id_SAP__c
            FROM Account
            WHERE Id_SAP__c IN :mapClientOrderProducts.keySet() 
            ]){
                if(!mapClientAccountId.containsKey(accounts.Id_SAP__c)){
                    mapClientAccountId.put(accounts.Id_SAP__c,accounts.Id);
                }
        }
        return mapClientAccountId;
    }

    public static Map<String, Map<String, String>> getPricebookForBusnissUnit (Map<String, Map<String,List<String>>> mapClientOrderProducts){
        Map<String, Map<String, String>> mapClientUnitBusinessPricebookId = new Map<String, Map<String, Id>>();
        Map<String, String> mapCustomerSalesAreaIdsSalesOrganization = new Map<String, String>();
        for(Dan360_CustomerSalesArea__c customerSalesArea : [   SELECT id, Dan360_SalesArea__r.Dan360_SalesOrganization__c, Dan360_Customer__r.Id_SAP__c
                                                                FROM Dan360_CustomerSalesArea__c 
                                                                WHERE Dan360_Customer__r.Id_SAP__c IN :mapClientOrderProducts.keySet()
                                                                    AND Dan360_SalesArea__r.Dan360_DistributionChannel__c = '00']
        ){
            if(!mapClientUnitBusinessPricebookId.containsKey(customerSalesArea.Dan360_Customer__r.Id_SAP__c)){
                mapClientUnitBusinessPricebookId.put(customerSalesArea.Dan360_Customer__r.Id_SAP__c, new Map<String, String>());
            }
            if(!mapClientUnitBusinessPricebookId.get(customerSalesArea.Dan360_Customer__r.Id_SAP__c).containsKey(customerSalesArea.Dan360_SalesArea__r.Dan360_SalesOrganization__c)){
                mapClientUnitBusinessPricebookId.get(customerSalesArea.Dan360_Customer__r.Id_SAP__c).put(customerSalesArea.Dan360_SalesArea__r.Dan360_SalesOrganization__c,'');
            }

            if(!mapCustomerSalesAreaIdsSalesOrganization.containsKey(customerSalesArea.Dan360_SalesArea__r.Dan360_SalesOrganization__c)){
                mapCustomerSalesAreaIdsSalesOrganization.put(customerSalesArea.Dan360_SalesArea__r.Dan360_SalesOrganization__c,customerSalesArea.id);
            }
        }

        Map<String, String> mapCustomerSalesAreaIDPricebook = new Map<String, String>();
        for(Pricebook2 pricebook : [SELECT Id, Dan360_CustomerSalesArea__c FROM Pricebook2 WHERE Dan360_CustomerSalesArea__c IN : mapCustomerSalesAreaIdsSalesOrganization.values()]){
            if(!mapCustomerSalesAreaIDPricebook.containsKey(pricebook.Dan360_CustomerSalesArea__c)){
                mapCustomerSalesAreaIDPricebook.put(pricebook.Dan360_CustomerSalesArea__c, pricebook.Id);
            }
        }

        for(String client : mapClientUnitBusinessPricebookId.keySet()){
            for(String salesOrganization : mapClientUnitBusinessPricebookId.get(client).keySet()){
                String customerSalesAreaId = mapCustomerSalesAreaIdsSalesOrganization.get(salesOrganization);
                String pricebookId =  mapCustomerSalesAreaIDPricebook.get(customerSalesAreaId);
                mapClientUnitBusinessPricebookId.get(client).put(salesOrganization,pricebookId);
            }
        }
        System.debug('mapClientUnitBusinessPricebookId');
        System.debug(mapClientUnitBusinessPricebookId);
        return mapClientUnitBusinessPricebookId;
    }
    public class WrapperTipoVentaOpc{
        @AuraEnabled
        public String label {get; set;}
        
        @AuraEnabled
        public String value {get; set;}

        public WrapperTipoVentaOpc(String label, String value){
            this.label = label;
            this.value = value;
        }
        
    }

    public class WrapperOrder {
        @AuraEnabled
        public String sucursal;
        @AuraEnabled
        public String ordenDeCompra;
        @AuraEnabled
        public String codProducto;
        @AuraEnabled
        public String nombreProducto;
        @AuraEnabled
        public Integer cantidadProducto;

        public WrapperOrder (String sucursal, String ordenDeCompra, String codProducto, String nombreProducto, Integer cantidadProducto){
            this.sucursal = sucursal;
            this.ordenDeCompra = ordenDeCompra;
            this.codProducto = codProducto;
            this.nombreProducto = nombreProducto;
            this.cantidadProducto = cantidadProducto;
        }
    }

    public class WrapperItems {
        String ordenDeCompra;
        Integer cantidad;
        String codigoProducto;
        String ShipTo;
        String codCliente;

        public WrapperItems (String ordenDeCompra, String cantidad, String codigoProducto, String ShipTo, String codCliente){
            this.ordenDeCompra = ordenDeCompra;
            this.cantidad = Integer.valueOf(cantidad);
            this.codigoProducto = codigoProducto;
            this.ShipTo = ShipTo;
            this.codCliente = codCliente;
        }
    }

    public class WrapperMaps {
        Map<String, Map<String,String>> mapClientProductOrganization;
        Map<String, Map<String,List<String>>> mapClientOrganizationProducts;
        Map<String, Map<String, Map<String, Decimal>>> mapClienteUnidadNegocioproductTradeUnitBulto;

        public WrapperMaps (Map<String, Map<String,String>> mapClientProductOrganization, Map<String, Map<String,List<String>>> mapClientOrganizationProducts,Map<String, Map<String, Map<String, Decimal>>> mapClienteUnidadNegocioproductTradeUnitBulto){
            this.mapClientProductOrganization = mapClientProductOrganization;
            this.mapClientOrganizationProducts = mapClientOrganizationProducts;
            this.mapClienteUnidadNegocioproductTradeUnitBulto = mapClienteUnidadNegocioproductTradeUnitBulto;
        }
    }
    public class ApplicationException extends Exception {}
}