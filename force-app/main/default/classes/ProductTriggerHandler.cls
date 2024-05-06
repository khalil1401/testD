public with sharing class ProductTriggerHandler {
    public static void removeInactiveProductsFromOrders(Set<Id> products) {
        List<OrderItem> orderItemsToDelete = [
            SELECT  Id
            FROM    OrderItem
            WHERE   Order.Status = 'Borrador'
                AND Product2Id IN :products
        ];

        delete orderItemsToDelete;
    }

    private static Id getStandardPrice(){
        if(Test.IsRunningTest()){
            System.debug('test1');
            return string.valueOf(Test.getStandardPricebookId());
        }else{
            System.debug('test2');
            PriceBook2 pricebookId = [
                SELECT Id 
                FROM PriceBook2 
                WHERE isStandard = true 
                LIMIT 1];
            return pricebookId.id;
        }
    }

    public static void createNewPriceBookEntry(List<Product2> products){
        List<PricebookEntry> newPriceBookEntryList = new List<PricebookEntry>();
        Id pricebookId = getStandardPrice();

        for (Product2 product : products) {
            newPriceBookEntryList.add(
                new PricebookEntry(
                    IsActive = true,
                    Pricebook2Id = pricebookId,
                    Product2Id = product.id,
                    UnitPrice = 0.01,
                    Dan360_Editable__c = true
                )
            );
        }
        
        insert newPriceBookEntryList;
    }
}