public class BatchDeleteTablaIntermediaCC implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    public Database.QueryLocator start (Database.BatchableContext bc) {
        String query ='SELECT Id '+
                        'FROM Dan360_TablaIntermediaCuentaCorriente__c';

        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext BC, List<Dan360_TablaIntermediaCuentaCorriente__c> scope) {
        if(scope.size()>0){
            delete scope;
        }
    }

    public void finish (Database.BatchableContext BC) {
    }

}