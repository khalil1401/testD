public class BatchPriceBookEntries implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime lastMinutes = Datetime.now().addMinutes(-15);
        String query = 
            'SELECT id, UnitPrice, Dan360_ListPrice__c, Quantity, TotalPrice, PricebookEntryId, PricebookEntry.UnitPrice, ' +
                'Dan360_Descuento__c, PricebookEntry.Dan360_Descuento__c, PricebookEntry.IsActive ' +
            'FROM OrderItem ' +
            'WHERE Order.Status = \'Borrador\' ' +
                'AND PricebookEntry.LastModifiedDate >= :lastMinutes ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<OrderItem> orderItems) {
        List<OrderItem> itemsToUpdate = new List<OrderItem>();
        List<OrderItem> itemsToDelete = new List<OrderItem>();
        Decimal discount;

        for (OrderItem item : orderItems) {

            if(!item.PricebookEntry.IsActive){
                itemsToDelete.add(item);
                continue;
            }

            if( item.Dan360_ListPrice__c != item.PricebookEntry.UnitPrice || 
                item.Dan360_Descuento__c != item.PricebookEntry.Dan360_Descuento__c
            ){
                item.Dan360_ListPrice__c = item.PricebookEntry.UnitPrice;
                item.Dan360_Descuento__c = item.PricebookEntry.Dan360_Descuento__c;
                
                discount = item.Dan360_ListPrice__c * item.Dan360_Descuento__c/100;
                
                item.UnitPrice = item.Dan360_ListPrice__c - discount;
                itemsToUpdate.add(item);
            }
        }
        update itemsToUpdate;
        delete itemsToDelete;
    }

    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}