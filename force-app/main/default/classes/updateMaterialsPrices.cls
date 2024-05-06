public with sharing class updateMaterialsPrices {        
    @AuraEnabled
    public static String updateMaterials(String pedidoId){
        
        String mensaje;
        Pricebook2 pricebookCustomer ;
        
        Order pedido = [
            SELECT Id, Dan360_CustomerSalesArea__c, RecordType.Name 
            FROM Order 
            WHERE Id = : pedidoId
        ];


        Dan360_CustomerSalesArea__c customerSalesArea = [
            SELECT Id, Dan360_SalesArea__c, Dan360_Customer__r.Id_SAP__c, Dan360_Id_Externo__c, 
                Dan360_SalesArea__r.Dan360_Division__c,Dan360_SalesArea__r.Dan360_DistributionChannel__c,Dan360_SalesArea__r.Dan360_SalesOrganization__c
            FROM Dan360_CustomerSalesArea__c
            WHERE Id = :pedido.Dan360_CustomerSalesArea__c
        ];


        List<PriceBook2> customerPriceBook = [
            SELECT Id, Name, Dan360_LastModSap__c, LastModifiedDate
            FROM PriceBook2
            WHERE Dan360_CustomerSalesArea__c = :customerSalesArea.Id
                AND IsActive = true
        ];

        

        String fechaPedido = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        System.debug('---------TEST-----------');
        if(pedido.RecordType.Name == 'Pedido de Venta Directa'){
            //ACA
            Map<String, PricebookEntry> mapProductCodePricebook = new Map<String, PricebookEntry>();
            for(PricebookEntry pbe : [SELECT Id, Product2.Id_SAP__c, IsActive FROM PricebookEntry WHERE Pricebook2Id = :customerPriceBook[0].Id]){
                if(!mapProductCodePricebook.containsKey(pbe.Product2.Id_SAP__c)){
                    mapProductCodePricebook.put(pbe.Product2.Id_SAP__c, pbe);
                }
            }
            System.debug('mapProductCodePricebook');
            System.debug(mapProductCodePricebook);
            //ACA**
            WebServiceSap.matPricesResponse response = WebServiceSap.askMaterialPricesSAP(fechaPedido, 
                                                                                customerSalesArea.Dan360_SalesArea__r.Dan360_SalesOrganization__c, 
                                                                                customerSalesArea.Dan360_SalesArea__r.Dan360_DistributionChannel__c, 
                                                                                customerSalesArea.Dan360_SalesArea__r.Dan360_Division__c,
                                                                                customerSalesArea.Dan360_Customer__r.Id_SAP__c);    
            System.debug(customerPriceBook);                                                                        
            List<Pricebook2> listnewPriceBook = new List<PriceBook2>();
            if(customerPriceBook.size() == 0){
                Pricebook2 newPriceBook = new Pricebook2(
                    Name = 'Lista Prueba Insert',
                    Dan360_CustomerSalesArea__c = customerSalesArea.Id,
                    isActive = true, 
                    Dan360_LastModSap__c = Datetime.now()
                );
                listnewPriceBook.add(newPriceBook);
                System.debug('No habia lista de precios');
                try {
                    Database.insert(listnewPriceBook,true);
                } catch (Exception e) {
                    mensaje = 'Fallo la creacion de los precios';
                    System.debug(e.getMessage());
                }
            } else {
                System.debug('Ya habia lista de precios');
                System.debug(customerPriceBook[0]);
                customerPriceBook[0].Dan360_LastModSap__c =  Datetime.now();
                update customerPriceBook[0];
            }

            if(response.response.getStatusCode() == 200){
                List<PriceBookEntry> pbToInsert = new List<PriceBookEntry>();
                List<MatPriceUtilityJson.Prices> listPrices = response.matPricesResponseObj.prices;
                for(MatPriceUtilityJson.Prices price : listPrices){
                    Product2 prodRefference = new Product2(
                        Id_SAP__c = price.materialId
                    );
                    PriceBookEntry pbEntry = new PriceBookEntry(
                        Dan360_IDExterno__c = customerSalesArea.Dan360_Id_Externo__c+'-'+price.materialId,
                        Product2 = prodRefference,
                        Pricebook2Id = customerPriceBook.size() == 0 ? listnewPriceBook[0].Id : customerPriceBook[0].Id,
                        UnitPrice = price.price,
                        IsActive = true,
                        Dan360_Descuento__c = price.discount
                    );
                    pbToInsert.add(pbEntry);
                    System.debug(pbEntry);
                }

                Schema.SObjectField externalIdPB = PricebookEntry.Fields.Dan360_IDExterno__c;
                Database.UpsertResult[] upResult = Database.upsert(pbToInsert,externalIdPB,false);
                for (Database.UpsertResult sr : upResult) {
                    if (sr.isSuccess()) {
                        mensaje = 'Se actualizacion los precios correctamente';
                        System.debug('Exito');
                    }
                    else {             
                        for(Database.Error err : sr.getErrors()) {
                            mensaje = 'Algunos productos no se encontraban habilitados para su compra';
                            System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                            System.debug('fields that affected this error: ' + err.getFields());

                        }
                    }
                }
                //ACA
                for(PriceBookEntry pbeToCheck : pbToInsert){
                    if(mapProductCodePricebook.containsKey(pbeToCheck.Product2.Id_SAP__c)){
                        mapProductCodePricebook.remove(pbeToCheck.Product2.Id_SAP__c);
                    }
                }
                System.debug('mapProductCodePricebook Despues de borrar');
                System.debug(mapProductCodePricebook); 
                for(String productoCode : mapProductCodePricebook.keySet()){
                    mapProductCodePricebook.get(productoCode).isActive = false;
                }
                System.debug('mapProductCodePricebook Despues de desactivar');
                System.debug(mapProductCodePricebook); 

                Database.update(mapProductCodePricebook.values(), false);
                //ACA**
            }else{
                mensaje = 'Fallo la actualizacion de los Precios';
                System.debug('Fallo la respuesta mamu.');
            }
        }
        
        System.debug('mensajes----------->'+mensaje);
        return mensaje;
    }

    @InvocableMethod(label='Get Actual Prices' description='Update the prices of pricebookentries')
    public static void updateMaterialsFlow(List<String> pedidoId){
    
        String mensaje;
        Pricebook2 pricebookCustomer ;
        
        Order pedido = [
            SELECT Id, Dan360_CustomerSalesArea__c, RecordType.Name
            FROM Order 
            WHERE Id = : pedidoId
        ];

        Dan360_CustomerSalesArea__c customerSalesArea = [
            SELECT Id, Dan360_SalesArea__c, Dan360_Customer__r.Id_SAP__c, Dan360_Id_Externo__c
            FROM Dan360_CustomerSalesArea__c
            WHERE Id = :pedido.Dan360_CustomerSalesArea__c
        ];

        Dan360_SalesArea__c salesArea = [
            SELECT id, Dan360_Division__c, Dan360_DistributionChannel__c, Dan360_SalesOrganization__c
            FROM Dan360_SalesArea__c
            WHERE Id = :customerSalesArea.Dan360_SalesArea__c
        ];

        List<PriceBook2> customerPriceBook = [
            SELECT Id, Name, Dan360_LastModSap__c, LastModifiedDate
            FROM PriceBook2
            WHERE Dan360_CustomerSalesArea__c = :customerSalesArea.Id
                AND IsActive = true
        ];

        if(pedido.RecordType.Name == 'Pedido de Venta Directa'){
            Map<String, PricebookEntry> mapProductCodePricebook = new Map<String, PricebookEntry>();
                for(PricebookEntry pbe : [SELECT Id, Product2.Id_SAP__c, IsActive FROM PricebookEntry WHERE Pricebook2Id = :customerPriceBook[0].Id]){
                    if(!mapProductCodePricebook.containsKey(pbe.Product2.Id_SAP__c)){
                        mapProductCodePricebook.put(pbe.Product2.Id_SAP__c, pbe);
                }
            }
            String fechaPedido = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
            WebServiceSap.matPricesResponse response = WebServiceSap.askMaterialPricesSAP(fechaPedido, salesArea.Dan360_SalesOrganization__c, 
                                                                                        salesArea.Dan360_DistributionChannel__c, salesArea.Dan360_Division__c,
                                                                                        customerSalesArea.Dan360_Customer__r.Id_SAP__c);
            List<Pricebook2> listnewPriceBook = new List<PriceBook2>();
            if(customerPriceBook.size() == 0){
                Pricebook2 newPriceBook = new Pricebook2(
                    Name = 'Lista Prueba Insert',
                    Dan360_CustomerSalesArea__c = customerSalesArea.Id,
                    isActive = true, 
                    Dan360_LastModSap__c = Datetime.now()
                );
                listnewPriceBook.add(newPriceBook);
                try {
                    Database.insert(listnewPriceBook,true);
                } catch (Exception e) {
                    mensaje = 'Fallo la creacion de los precios';
                    System.debug(e.getMessage());
                }
            } else {
                customerPriceBook[0].Dan360_LastModSap__c =  Datetime.now();
                update customerPriceBook[0];
            }

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
                        Pricebook2Id = customerPriceBook.size() == 0 ? listnewPriceBook[0].Id : customerPriceBook[0].Id,
                        UnitPrice = price.price,
                        IsActive = true, 
                        Dan360_Descuento__c = price.discount
                    );
                    pbToInsert.add(pbEntry);
                }

                Schema.SObjectField externalIdPB = PricebookEntry.Fields.Dan360_IDExterno__c;
                Database.UpsertResult[] upResult = Database.upsert(pbToInsert,externalIdPB,false);
                for (Database.UpsertResult sr : upResult) {
                    if (sr.isSuccess()) {
                        mensaje = 'Se actualizacion los precios correctamente';
                    }
                    else {             
                        for(Database.Error err : sr.getErrors()) {
                            mensaje = 'Algunos productos no se encontraban habilitados para su compra';
                            System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                            System.debug('fields that affected this error: ' + err.getFields());

                        }
                    }
                }

                //ACA
                for(PriceBookEntry pbeToCheck : pbToInsert){
                    if(mapProductCodePricebook.containsKey(pbeToCheck.Product2.Id_SAP__c)){
                        mapProductCodePricebook.remove(pbeToCheck.Product2.Id_SAP__c);
                    }
                } 
                for(String productoCode : mapProductCodePricebook.keySet()){
                    mapProductCodePricebook.get(productoCode).isActive = false;
                } 

                Database.update(mapProductCodePricebook.values(), false);
                
            }
        }
        
    }


    public static /* Map<String, Map<String, PricebookEntry>> */ MapWrappers updatePricesSAPandGetPrices(Map<String,List<Dan360_CustomerSalesArea__c>> mapClientCustomerSalesAreas, Map<String, Map<String, PricebookEntry>> ClientProductPricebookEntry, Map<String, PricebookEntry> mapStandardPrice){
        System.debug(mapClientCustomerSalesAreas);
        System.debug(ClientProductPricebookEntry);
        System.debug(mapStandardPrice);
        List<Id> listCustomerSalesAreasIds = new List<Id>();
        List<Dan360_CustomerSalesArea__c> customerSalesAreaSAP = new List<Dan360_CustomerSalesArea__c>();
        for( String client : mapClientCustomerSalesAreas.keySet()){
            for(Dan360_CustomerSalesArea__c customerSalesArea : mapClientCustomerSalesAreas.get(client)){
                listCustomerSalesAreasIds.add (customerSalesArea.id);
                customerSalesAreaSAP.add(customerSalesArea);
            }
        }

        Map<String, PriceBook2> mapClientPriceBook2 = new Map<String, PriceBook2>();
        
        for(PriceBook2 customerPricebook2 : [
            SELECT Id, Name, Dan360_LastModSap__c, LastModifiedDate, Dan360_CustomerSalesArea__c
            FROM PriceBook2
            WHERE Dan360_CustomerSalesArea__c IN :listCustomerSalesAreasIds
                AND IsActive = true
            WITH SECURITY_ENFORCED
        ]){
            if(!mapClientPriceBook2.containsKey(customerPricebook2.Dan360_CustomerSalesArea__c)){
                mapClientPriceBook2.put(customerPricebook2.Dan360_CustomerSalesArea__c, customerPricebook2);
            }
        }

        List<PricebookEntry> listPricebookEntryToInsert = new List<PricebookEntry>();
        String fechaPedido = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        List<String> pricebookIdsExternos = new List<String>();
        Boolean isVentaDirecta = false;
        for(Dan360_CustomerSalesArea__c customerSalesArea: customerSalesAreaSAP){
            if (customerSalesArea.Dan360_SalesArea__r.Dan360_DistributionChannel__c == '00'){
                isVentaDirecta = true;
                PriceBook2 customerPriceBook = mapClientPriceBook2.get(customerSalesArea.Id);

                WebServiceSap.matPricesResponse response = WebServiceSap.askMaterialPricesSAP(fechaPedido, customerSalesArea.Dan360_SalesArea__r.Dan360_SalesOrganization__c, 
                                                customerSalesArea.Dan360_SalesArea__r.Dan360_DistributionChannel__c, customerSalesArea.Dan360_SalesArea__r.Dan360_Division__c,
                                                customerSalesArea.Dan360_Customer__r.Id_SAP__c);

                if(response.response.getStatusCode() == 200){
                    List<MatPriceUtilityJson.Prices> listPrices = response.matPricesResponseObj.prices;
                    for(MatPriceUtilityJson.Prices price : listPrices){
                        Product2 prodRefference = new Product2(
                            Id_SAP__c = price.materialId
                        );
                        PriceBookEntry pbEntry = new PriceBookEntry(
                            Dan360_IDExterno__c = customerSalesArea.Dan360_Id_Externo__c+'-'+price.materialId,
                            Product2 = prodRefference,
                            Pricebook2Id = customerPriceBook.id,
                            UnitPrice = price.price,
                            IsActive = true,
                            Dan360_Descuento__c = price.discount
                        );
                        System.debug('pbEntry');
                        System.debug(pbEntry);
                        listPricebookEntryToInsert.add(pbEntry);
                        pricebookIdsExternos.add(pbEntry.Dan360_IDExterno__c);
                        Map<String,PricebookEntry> mapProductPricebookEntry = ClientProductPricebookEntry.get(customerSalesArea.Dan360_Customer__r.Id_SAP__c);
                        if(mapProductPricebookEntry.containsKey(price.materialId)){
                            ClientProductPricebookEntry.get(customerSalesArea.Dan360_Customer__r.Id_SAP__c).put(price.materialId,pbEntry);
                        }
                    }
                } else {
                    throw new applicationException('No se pudo actualizar los precios');
                }
            }else {
                if(customerSalesArea.Dan360_SalesArea__r.Dan360_DistributionChannel__c == '05'){
                    System.debug('Crear la lista con 0.01');
                    Map<String,PricebookEntry> mapProductPricebookEntry = ClientProductPricebookEntry.get(customerSalesArea.Dan360_Customer__r.Id_SAP__c);
                    for(String codeProduct : mapProductPricebookEntry.keySet()){
                        PricebookEntry pbEntryToCopy = mapStandardPrice.get(codeProduct);
                        pbEntryToCopy.Dan360_IDExterno__c = customerSalesArea.Dan360_Id_Externo__c+'-'+codeProduct;
                        pbEntryToCopy.IsActive = true;
                        pbEntryToCopy.Dan360_Descuento__c = 0;
                        ClientProductPricebookEntry.get(customerSalesArea.Dan360_Customer__r.Id_SAP__c).put(codeProduct,pbEntryToCopy);
                    }
                }
            }
            
        }

        Schema.SObjectField externalIdPB = PricebookEntry.Fields.Dan360_IDExterno__c;

            Database.UpsertResult[] upResult2 = Database.upsert(listPricebookEntryToInsert,externalIdPB,false);
            for (Database.UpsertResult sr : upResult2) {
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
        System.debug('ClientProductPricebookEntry');
        System.debug(ClientProductPricebookEntry);
        
        Map<String,PricebookEntry> pricebookIdExternoPricebookEntry = new Map<String,PricebookEntry>();
        if(isVentaDirecta){     
            for(PricebookEntry pbEntryWithDisc : [SELECT Id,Dan360_IDExterno__c,Product2Id,Pricebook2Id,UnitPrice,IsActive,Dan360_Descuento__c, UnitPriceWithDiscountS__c FROM PricebookEntry WHERE Dan360_IDExterno__c IN:pricebookIdsExternos]){
                if(!pricebookIdExternoPricebookEntry.containsKey(pbEntryWithDisc.Dan360_IDExterno__c)){
                    pricebookIdExternoPricebookEntry.put(pbEntryWithDisc.Dan360_IDExterno__c,pbEntryWithDisc);
                }
            }
        }
        System.debug('PricebookIdExternoPricebookEntry');
        System.debug(pricebookIdExternoPricebookEntry);
        MapWrappers wrapper = new MapWrappers(
            ClientProductPricebookEntry,
            pricebookIdExternoPricebookEntry
        );
        System.debug('wrapper');
        System.debug(wrapper);
        System.debug('wrapper.ClientProductPricebookEntry');
        System.debug(wrapper.ClientProductPricebookEntry);
        System.debug('wrapper.pricebookIdExternoPricebookEntry');
        System.debug(wrapper.pricebookIdExternoPricebookEntry);
        //Cliente - Producto - PriceBookEntry
        //return ClientProductPricebookEntry;
        return wrapper;
    }

    public class MapWrappers{
        public final Map<String, Map<String, PricebookEntry>> clientProductPricebookEntry;
        public final Map<String,PricebookEntry> pricebookIdExternoPricebookEntry;

        mapWrappers(Map<String, Map<String, PricebookEntry>> clientProductPricebookEntry, Map<String,PricebookEntry> pricebookIdExternoPricebookEntry){
            this.clientProductPricebookEntry = clientProductPricebookEntry;
            this.pricebookIdExternoPricebookEntry = pricebookIdExternoPricebookEntry;
        }
    }

    public class applicationException extends Exception {}
}