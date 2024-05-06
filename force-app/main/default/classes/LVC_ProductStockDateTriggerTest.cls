@isTest
public class LVC_ProductStockDateTriggerTest {
    @TestSetup
    static void generateData(){
        LVC_DistributionCenter__c distributionCenter = new LVC_DistributionCenter__c(
            Name = 'Danone Sur',    
            CDExternalId__c = '1'
        );
        insert distributionCenter;

        List<LVC_ProductStockDate__c> productsToInsert = new List<LVC_ProductStockDate__c>();
        LVC_ProductStockDate__c product = new LVC_ProductStockDate__c(
            DistributionCenter__c = distributionCenter.Id,
            StockDate__c = Date.newInstance(2022, 06, 25),
            Sku__c = '4766',
            Stock__c = 1000
        );
        productsToInsert.add(product);

        LVC_ProductStockDate__c product2 = new LVC_ProductStockDate__c(
            DistributionCenter__c = distributionCenter.Id,
            StockDate__c = Date.newInstance(2022, 06, 26),
            Sku__c = '4766',
            Stock__c = 1000
        );
        productsToInsert.add(product2);

        LVC_ProductStockDate__c product3 = new LVC_ProductStockDate__c(
            DistributionCenter__c = distributionCenter.Id,
            StockDate__c = Date.newInstance(2022, 06, 27),
            Sku__c = '4766',
            Stock__c = 1000
        );
        productsToInsert.add(product3);

        insert productsToInsert;
    }

    @isTest
    static void upsertProducts(){
        LVC_DistributionCenter__c CD = [SELECT Id FROM LVC_DistributionCenter__c LIMIT 1];
        Test.startTest();
        LVC_ProductStockDate__c newProduct = new LVC_ProductStockDate__c(
            DistributionCenter__c = CD.Id,
            StockDate__c = Date.newInstance(2022, 06, 28),
            Sku__c = '4766',
            Stock__c = 1000
        );
        insert newProduct;
        Test.stopTest();
    }

    @isTest
    static void upsertProductsDuplicateFound(){
        LVC_DistributionCenter__c CD = [SELECT Id FROM LVC_DistributionCenter__c LIMIT 1];
        Test.startTest();
        LVC_ProductStockDate__c newProduct = new LVC_ProductStockDate__c(
            DistributionCenter__c = CD.Id,
            StockDate__c = Date.newInstance(2022, 06, 27),
            Sku__c = '4766',
            Stock__c = 1000
        );
        try{insert newProduct;}catch(exception e){}
        Test.stopTest();
    }
}