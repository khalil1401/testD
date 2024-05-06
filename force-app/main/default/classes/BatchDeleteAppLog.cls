public class BatchDeleteAppLog implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    
    public Database.QueryLocator start (Database.BatchableContext bc) {
        Id recordTypeEDI = Schema.SObjectType.AppLog__c.getRecordTypeInfosByDeveloperName().get('EDI').getRecordTypeId();
        String query ='SELECT Id ' +
                        'FROM AppLog__c '+
                        'WHERE RecordTypeId != :recordTypeEDI';

        return Database.getQueryLocator(query);
    }   

    public void execute (Database.BatchableContext BC, List<AppLog__c> scope) {
        Database.delete(scope);
    }

    public void finish (Database.BatchableContext BC) {
    }

      
}