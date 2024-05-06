public class WSEdiHelper {
    public static void createOrder(WSEdi.Request request,Account sucursal, List<Product2> productsToAdd,Map<String,String> mapProductLotQuantity, List<WSEdi.Items> productsWithError, Boolean ediCheck, String poNumber, String companyCode, Boolean block, String jsonStr) {
        
        Id recordTypeVentaDirecta = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Dan360_PedidoVentaDirecta').getRecordTypeId();
        String estado = 'Borrador';
        List<String> tipoErrores = new List<String>();
        List<OrderItem> orderItemsToInsert = new List<OrderItem>();
        List<String> productsFromIntegration = new List<String>();
        List<Product2> productsToAddFinal = new List<Product2>();

        // Start - Busqueda de Lista de precios para agregar a la orden.
        Dan360_CustomerSalesArea__c customerSalesArea = [SELECT Id, Dan360_SalesArea__r.Dan360_SalesOrganization__c,  Dan360_SalesArea__r.Dan360_DistributionChannel__c, 
                                                                Dan360_SalesArea__r.Dan360_Division__c, Dan360_Id_Externo__c
                                                            FROM Dan360_CustomerSalesArea__c 
                                                            WHERE Dan360_SalesArea__r.Dan360_DistributionChannel__c = '00' 
                                                                AND Dan360_SalesArea__r.Dan360_SalesOrganization__c = :companyCode
                                                                AND Dan360_Customer__c = :sucursal.Id];
        ID listaPrecioId = [SELECT Id FROM Pricebook2 WHERE Dan360_CustomerSalesArea__c = :customerSalesArea.Id  AND IsActive = true].Id;
        // End - Busqueda de Lista de precios para agregar a la orden.

        //Start - Acutalizar lista de precios por integracion
        if(!Test.isRunningTest()){
            productsFromIntegration = updatePrices(sucursal, customerSalesArea, listaPrecioId);
        } else {
            productsFromIntegration.add('123');
        }


        //End - Acutalizar lista de precios por integracion
        List<Product2> productosWithNoPrice = new List<Product2>();
        
        if(productsFromIntegration.size() > 0) {
            for(Product2 producto :productsToAdd){
                if(productsFromIntegration.contains(producto.Id_SAP__c)){
                    productosWithNoPrice.add(producto);
                }
            }
        }
        
        if(productosWithNoPrice.size()>0){
            for(Product2 product : productosWithNoPrice){
                productsToAdd.remove(productsToAdd.indexOf(product));
            }
        }

        // COSA NUEVA
        Map<String, PricebookEntry> mapProductPricebookEntryId = new Map<String, PricebookEntry>();
        List<String> productoIds = new List<String>();
        for(Product2 producto : productsToAdd){
            productoIds.add(producto.id);
        }
        //Obtengo la entrada de lista de precios de los productos a insertar.
        for(PricebookEntry pbEntry : [SELECT id, Product2Id,Dan360_Descuento__c, UnitPrice, UnitPriceWithDiscountS__c FROM PricebookEntry WHERE Product2Id IN :productoIds AND Pricebook2Id =:listaPrecioId]){
            if(!mapProductPricebookEntryId.containsKey(pbEntry.Product2Id)){
                mapProductPricebookEntryId.put(pbEntry.Product2Id, pbEntry);
            }
        }

        if(mapProductPricebookEntryId.size() > 0 ){
            for(Product2 productoToSee : productsToAdd){
                if(mapProductPricebookEntryId.containsKey(productoToSee.Id)){
                    productsToAddFinal.add(productoToSee);
                } else {
                    productosWithNoPrice.add(productoToSee);
                }
            }
        }
        /* if(mapProductPricebookEntryId.size() > 0 ){
            for(String productId : mapProductPricebookEntryId.keySet()){
                for(Product2 productoToSee : productsToAdd){
                    if(mapProductPricebookEntryId.containsKey(productoToSee.id)){
                        //Si el producto a insertar esta dentro de la lista de preicos, es q existe y se puede insertar.
                        productsToAddFinal.add(productoToSee);
                    } else {
                        productosWithNoPrice.add(productoToSee);
                    }
                }
            }
        } */

        if(productsWithError.size() > 0 || mapProductPricebookEntryId.size() == 0 || productosWithNoPrice.size() > 0){
            estado = 'Error';
            tipoErrores.add('Producto - Error en Producto');
        }

        // FIN COSA NUEVA
        //Start - Manejo de estado de la orden con tipo del AppLog a crear.
        if(!ediCheck){
            estado = 'Error';
            tipoErrores.add('Cliente - Sin marca EDI');
        }

        if(block){
            estado = 'Error';
            tipoErrores.add('Cliente - Cliente con Bloqueo');
        }

        if(String.isblank(request.poNumber)){
            estado = 'Error';
            tipoErrores.add('Pedido - Sin orden de compra');
        }

        
        //End - Manejo de estado de la orden con tipo del AppLog a crear.

        //Start - Creacion de la orden con sus ordenItems.
        Order pedido = new Order(
            RecordTypeId = recordTypeVentaDirecta,
            AccountId = sucursal.id,
            Dan360_UnidadNegocio__c = companyCode,
            EffectiveDate = Date.today(),
            Orden_de_compra__c = poNumber,
            Status = estado,
            Pricebook2Id = listaPrecioId
        );
        
        Database.insert(pedido);
        if(productsToAddFinal.size()>0){
            orderItemsToInsert = createOrdenItems(pedido, productsToAddFinal, mapProductLotQuantity,listaPrecioId,estado);
        }
        
        if(orderItemsToInsert.size() > 0){
            Database.insert(orderItemsToInsert);
        }
        //End - Creacion de la orden con sus ordenItems.

        //Start - Update Orden
        if(estado == 'Borrador'){//Si la orden esta en borrador es que no se encontraron errores y se confirma.
            pedido.Status = 'Confirmado';
            pedido.StatusCode = 'Activated';
            pedido.EndDate = Date.today();
            Database.update(pedido);
            List<String> orderId = new List<String>{pedido.id};
            if(!Test.isRunningTest()){
                // sendOrderToSapController.sendOrderToSapFlow(orderId);
                QueueableSendToSap encolable  = new QueueableSendToSap();
                encolable.CreateCustomObject(pedido.Id);
                System.enqueueJob(encolable);
            }
        } else { //Caso contrario, si esta en error, se genera el AppLog
            createAppLog(request, tipoErrores , jsonStr, pedido, productosWithNoPrice, productsWithError, productsToAddFinal);
        }
        //End - Update Orden
    }

    public static List<OrderItem> createOrdenItems(Order pedido, List<Product2> productsToAddFinal,Map<String,String> mapProductLotQuantity, ID listaPrecioId, string estado){
        
        Map<String, PricebookEntry> mapProductPricebookEntryId = new Map<String, PricebookEntry>();
        List<String> productoIds = new List<String>();
        for(Product2 producto : productsToAddFinal){
            productoIds.add(producto.id);
        }
        //Obtengo la entrada de lista de precios de los productos a insertar.
        for(PricebookEntry pbEntry : [SELECT id, Product2Id,Dan360_Descuento__c, UnitPrice, UnitPriceWithDiscountS__c FROM PricebookEntry WHERE Product2Id IN :productoIds AND Pricebook2Id =:listaPrecioId]){
            if(!mapProductPricebookEntryId.containsKey(pbEntry.Product2Id)){
                mapProductPricebookEntryId.put(pbEntry.Product2Id, pbEntry);
            }
        }

        List<OrderItem> listToReturn = new List<OrderItem>();

        for(Product2 producto : productsToAddFinal){
            //Start - Al ser un campo calculado desde un descuento, se corren los decimales, este bloque corrige ese error.
            String UnitPriceWithDiscount =  mapProductPricebookEntryId.get(producto.Id).UnitPriceWithDiscountS__c;
            Decimal unitPriceToInsert;
            if(UnitPriceWithDiscount != null){
                String decimalString1 = '00';
                List<String> listString1 = UnitPriceWithDiscount.split('\\.');

                if(listString1.size() == 1){
                    unitPriceToInsert = Decimal.valueOf(listString1[0]);
                } else {
                    if(listString1[1].length() == 1){
                        decimalString1 = listString1[1]+'0';
                    }else{
                        decimalString1 = listString1[1].substring(0,2);
                    }
                    String fullUnitPriceString1 =  listString1[0]+'.'+decimalString1;
                    unitPriceToInsert = Decimal.valueOf(fullUnitPriceString1);
                }
            } else {
                unitPriceToInsert = mapProductPricebookEntryId.get(producto.Id).UnitPrice;
            }
            //End - Calcular precio.

            OrderItem productoPedido = new OrderItem(
                OrderId = pedido.Id,
                Product2Id = producto.Id,
                Quantity = Decimal.valueOf(mapProductLotQuantity.get(producto.Id)) * producto.Dan360_UnidadesPorBulto__c,
                PricebookEntryId = mapProductPricebookEntryId.get(producto.Id).Id,
                Dan360_Descuento__c = mapProductPricebookEntryId.get(producto.Id).Dan360_Descuento__c == null ? 0 : mapProductPricebookEntryId.get(producto.Id).Dan360_Descuento__c,
                Dan360_ListPrice__c = mapProductPricebookEntryId.get(producto.Id).UnitPrice,
                UnitPrice = unitPriceToInsert,
                Cantidad_de_Bultos__c = Integer.valueOf(mapProductLotQuantity.get(producto.Id)),
                Dan360_UnidadMedida__c = 'Trade Unit'
            );

            listToReturn.add(productoPedido);
        }
        
        return listToReturn;
    }

    public static  void createAppLog (WSEdi.Request request, String error, String jsonStr){
        Id recordTypeEdi = Schema.SObjectType.AppLog__c.getRecordTypeInfosByDeveloperName().get('EDI').getRecordTypeId();
            String mssgError = '<b>'+'Cliente GLN: '+'</b>'+ request.soldTo + '<br>';
            mssgError += '<b>'+'Sucursal GLN: '+'</b>'+ request.shipTo + '<br>';
            mssgError += '<b>'+'Orden de compra: '+'</b>'+ request.poNumber + '<br>'+ '<br>';
            mssgError += '<b>'+'Productos:'+'</b>'+ '<br>';
            
            for(WSEdi.Items productos: request.items){
                mssgError += '<b>'+'Producto EAN: '+'</b>'+ productos.matNumber + '<br>';
                mssgError += '<b>'+'Cantidad de Productos: '+'</b>'+ productos.orderedQuantity + '<br>';
                mssgError += '<b>'+'Cantidad de bultos: '+'</b>'+ productos.lotQuantity + '<br>';
                mssgError += '<b>'+'Cantidad de productos por bulto: '+'</b>'+ productos.quantityByLot + '<br>'+ '<br>';
            }

            AppLog__c appLog = new AppLog__c(
                Name = 'Error EDI',
                Tipo_de_Errores__c = error,
                RecordTypeId = recordTypeEdi,
                Mensaje__c = mssgError,
                json__c = jsonStr
            );

            Database.insert(applog);
    }

    public static  void createAppLog (WSEdi.Request request, List<String> errorres, String jsonStr, Order pedido, List<Product2> productosWithNoPrice, List<WSEdi.Items> productsNotExist, List<Product2> productsToAdd){
        Id recordTypeEdi = Schema.SObjectType.AppLog__c.getRecordTypeInfosByDeveloperName().get('EDI').getRecordTypeId();
        List<String> productsToDelete = new List<String>();
        if(productsToAdd.size()>0){
            for(Product2 productoAgregar : productsToAdd){
                productsToDelete.add(productoAgregar.Dan360_ean13__c);
            }
        }
        String error = String.join( errorres, ';' ); 
        String mssgError = '<b>'+'Cliente GLN: '+'</b>'+ request.soldTo + '<br>';
        mssgError += '<b>'+'Sucursal GLN: '+'</b>'+ request.shipTo + '<br>';
        mssgError += '<b>'+'Orden de compra: '+'</b>'+ request.poNumber + '<br>'+ '<br>';
        if(request.items.size() != productsToAdd.size()){
            mssgError += '<b>'+'Productos:'+'</b>'+ '<br>';
        }
        
        for(WSEdi.Items productos: request.items){
            if(productsToDelete.contains(productos.matNumber)){
                continue;
            }
            String errorEspecifico= '<b>'+'Producto EAN: '+'</b>'+ productos.matNumber + '<br>';
            //Productos SIN Precio
            if(productosWithNoPrice.size()>0){
                for(Product2 productoSinPrecio : productosWithNoPrice){
                    if(productoSinPrecio.Dan360_ean13__c == productos.matNumber){
                        errorEspecifico = '<b>'+'Producto EAN: '+'</b>'+ productos.matNumber +' (Sin precio determinado)' +'<br>';
                    }
                }
            }
            // Productos No existe
            if(productsNotExist.size()>0){
                for(WSEdi.Items itemToCheck : productsNotExist){
                    if(itemToCheck.matNumber == productos.matNumber){
                        errorEspecifico = '<b>'+'Producto EAN: '+'</b>'+ productos.matNumber +' (Producto inexistente)' +'<br>';
                    }
                }
            }
            mssgError +=  errorEspecifico;
            mssgError += '<b>'+'Cantidad de Productos: '+'</b>'+ productos.orderedQuantity + '<br>';
            mssgError += '<b>'+'Cantidad de bultos: '+'</b>'+ productos.lotQuantity + '<br>';
            mssgError += '<b>'+'Cantidad de productos por bulto: '+'</b>'+ productos.quantityByLot + '<br>'+ '<br>';
        }
        AppLog__c appLog = new AppLog__c(
            Name = 'Error EDI',
            Tipo_de_Errores__c = error,
            RecordTypeId = recordTypeEdi,
            Mensaje__c = mssgError,
            json__c = jsonStr,
            Pedido__c = pedido.id
        );
        Database.insert(applog);
    }

    public static List<String> updatePrices (Account sucursal, Dan360_CustomerSalesArea__c customerSalesArea, Id listaPrecioId){
        List<String> productsFromIntegration = new List<String>();
        String fechaPedido = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();

        Map<String, PricebookEntry> mapProductCodePricebook = new Map<String, PricebookEntry>();
            for(PricebookEntry pbe : [SELECT Id, Product2.Id_SAP__c, IsActive FROM PricebookEntry WHERE Pricebook2Id = :listaPrecioId]){
                if(!mapProductCodePricebook.containsKey(pbe.Product2.Id_SAP__c)){
                    mapProductCodePricebook.put(pbe.Product2.Id_SAP__c, pbe);
                }
            }

        WebServiceSap.matPricesResponse response = WebServiceSap.askMaterialPricesSAP(  fechaPedido, customerSalesArea.Dan360_SalesArea__r.Dan360_SalesOrganization__c, 
                                                                                        customerSalesArea.Dan360_SalesArea__r.Dan360_DistributionChannel__c, 
                                                                                        customerSalesArea.Dan360_SalesArea__r.Dan360_Division__c,
                                                                                        sucursal.Id_SAP__c);
        if(response.response.getStatusCode() != 200){
            throw new applicationException('No se pudo actualizar los precios');
        } else{
            List<PriceBookEntry> pbToInsert = new List<PriceBookEntry>();
            List<MatPriceUtilityJson.Prices> listPrices = response.matPricesResponseObj.prices;
            for(MatPriceUtilityJson.Prices price : listPrices){
                Product2 prodRefference = new Product2(
                    Id_SAP__c = price.materialId
                );
                PriceBookEntry pbEntry = new PriceBookEntry(
                    Dan360_IDExterno__c = customerSalesArea.Dan360_Id_Externo__c+'-'+price.materialId,
                    Product2 = prodRefference,
                    Pricebook2Id = listaPrecioId,
                    UnitPrice = price.price,
                    IsActive = true, 
                    Dan360_Descuento__c = price.discount
                );
                pbToInsert.add(pbEntry);
                
            }
            Schema.SObjectField externalIdPB = PricebookEntry.Fields.Dan360_IDExterno__c;
            Database.UpsertResult[] upResult = Database.upsert(pbToInsert,externalIdPB,false);

            //Desactivar productos que no vienen en la integracion
            for(PriceBookEntry pbeToCheck : pbToInsert){
                if(mapProductCodePricebook.containsKey(pbeToCheck.Product2.Id_SAP__c)){
                    mapProductCodePricebook.remove(pbeToCheck.Product2.Id_SAP__c);
                }
            } 

            if(mapProductCodePricebook.size() > 0){
                for(String productoCode : mapProductCodePricebook.keySet()){
                    productsFromIntegration.add(productoCode);
                    mapProductCodePricebook.get(productoCode).isActive = false;
                } 

                Database.update(mapProductCodePricebook.values(), false);
            }
            

        }
        return productsFromIntegration;
    }

    public class applicationException extends Exception {}
}