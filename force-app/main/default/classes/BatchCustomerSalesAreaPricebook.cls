public with sharing class BatchCustomerSalesAreaPricebook implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    String customerSalesAreaId;
    
    public BatchCustomerSalesAreaPricebook(String customerSalesAreaIdP){
        customerSalesAreaId = customerSalesAreaIdP;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 
            'SELECT Id, Name, Dan360_SalesArea__c, Dan360_Customer__r.Id_SAP__c, Dan360_Id_Externo__c,' +
            'Dan360_SalesArea__r.Dan360_Division__c,Dan360_SalesArea__r.Dan360_DistributionChannel__c,Dan360_SalesArea__r.Dan360_SalesOrganization__c ' +
            'FROM Dan360_CustomerSalesArea__c ' +
            'WHERE Id = :customerSalesAreaId';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Dan360_CustomerSalesArea__c> customerSalesAreas) {
        
        Dan360_CustomerSalesArea__c customerSalesArea = customerSalesAreas[0];

        String fechaPedido = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        WebServiceSap.matPricesResponse response = WebServiceSap.askMaterialPricesSAP(fechaPedido, customerSalesArea.Dan360_SalesArea__r.Dan360_SalesOrganization__c, 
        customerSalesArea.Dan360_SalesArea__r.Dan360_DistributionChannel__c, customerSalesArea.Dan360_SalesArea__r.Dan360_Division__c,
                                                                                    customerSalesArea.Dan360_Customer__r.Id_SAP__c);
        
        List<Pricebook2> listnewPriceBook = new List<PriceBook2>();
        System.debug(response);
        Pricebook2 newPriceBook = new Pricebook2(
            Name = 'Lista '+ customerSalesArea.Name,
            Dan360_CustomerSalesArea__c = customerSalesArea.Id,
            isActive = true, 
            Dan360_LastModSap__c = Datetime.now()
        );
            try {
                Database.insert(newPriceBook,true);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        

        if(response.response.getStatusCode() != 200){
            System.debug(response.response.getStatusCode());
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
                    Pricebook2Id = newPriceBook.Id,
                    UnitPrice = price.price,
                    IsActive = true, 
                    Dan360_Descuento__c = price.discount
                );
                System.debug(pbEntry);
                pbToInsert.add(pbEntry);
            }
            
            Schema.SObjectField externalIdPB = PricebookEntry.Fields.Dan360_IDExterno__c;
            Database.UpsertResult[] upResult = Database.upsert(pbToInsert,externalIdPB,false);
            for (Database.UpsertResult sr : upResult) {
                if (sr.isSuccess()) {
                   
                    System.debug('Exito');
                }
                else {             
                    for(Database.Error err : sr.getErrors()) {
                       
                        System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('fields that affected this error: ' + err.getFields());
                        
                    }
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}