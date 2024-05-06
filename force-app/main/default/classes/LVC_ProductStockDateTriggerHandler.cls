public with sharing class LVC_ProductStockDateTriggerHandler {

    public static void completeStockExternalId(){
        
        List<LVC_ProductStockDate__c> stockToUpdate = new List<LVC_ProductStockDate__c>(); 
        List<LVC_ProductStockDate__c> newProducts = [SELECT Id, DistributionCenter__r.CDExternalId__c, Sku__c, StockDate__c 
                                                     FROM LVC_ProductStockDate__c
                                                     WHERE Id =: Trigger.newMap.keySet()];
        if(newProducts.size() > 0){
            for(LVC_ProductStockDate__c psd : newProducts){
                // String decomposedDate = String.valueOf(psd.StockDate__c.year()) + String.valueOf(psd.StockDate__c.month()) + String.valueOf(psd.StockDate__c.day());
                String decomposedDate = DateTime.newInstance(psd.StockDate__c.year(), psd.StockDate__c.month(), psd.StockDate__c.day()).format('yyyyMMdd');
                psd.StockExternalId__c = psd.DistributionCenter__r.CDExternalId__c + '-' + psd.Sku__c + '-' + decomposedDate;
                stockToUpdate.add(psd);
            }
        }
        
        if(stockToUpdate.size() > 0){
            update stockToUpdate;
        }
    }
}