global class BatchDeleteOldNotification implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext param1) {
        String query = 'SELECT Id, Name, CreatedDate, Leido__c' + 
            ' FROM Notificacion__c' +
            ' WHERE CreatedDate < LAST_N_DAYS:30 AND Leido__c = true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext param1, List<Notificacion__c> scope) {
        List<Notificacion__c> itemsToDelete = new List<Notificacion__c>();

        if (!scope.isEmpty()) {
            for (Notificacion__c item : scope) {
                itemsToDelete.add(item);
            }
            delete itemsToDelete;
        }  
    }  

    global void finish(Database.BatchableContext param1) {
        System.debug('Batch Job Delete Old Notification Completed'); 
    }
}