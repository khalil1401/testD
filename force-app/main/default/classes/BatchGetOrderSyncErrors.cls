public class BatchGetOrderSyncErrors implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext ordenesSyncIncompleto) {
        
        DateTime now = System.today();
        DateTime oneHourAgo = now.addHours(-1);
        if(Test.isRunningTest()){
            return Database.getQueryLocator(
            [SELECT Id, OrderNumber, LastModifiedDate, CreatedBy.Name,LastModifiedBy.Name
            FROM Order  
            WHERE  Status  = 'Confirmado'  
            AND Status_SAP__c = NULL 
            AND CreatedDate > 2023-09-01T00:00:00.000+0000]
        );
        }else{
            return Database.getQueryLocator(
            [SELECT Id, OrderNumber, LastModifiedDate, CreatedBy.Name,LastModifiedBy.Name
            FROM Order  
            WHERE  Status  = 'Confirmado'  
            AND Status_SAP__c = NULL 
            AND LastModifiedDate < :oneHourAgo 
            AND CreatedDate > 2023-09-01T00:00:00.000+0000]
        );
        }
        
        
    }
    public void execute(Database.BatchableContext ordenesSyncIncompleto, List<Order> records){
        
        Integer horaActual = Integer.valueOf(System.now().hour());
        if(horaActual >= 9 && horaActual <= 16 ){ 
            if(records.size() > 0){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] { 'lhurtado@labsxd.com', 'gina.vilchez-diaz@danone.com' };
                message.optOutPolicy = 'FILTER';
                message.subject = 'Reporte Ordener con Status = Confirmado, SAP = null de hace una hora: ';
                // Arreglar el formato
                message.plainTextBody = 'Ordenes con estado confirmado : ' + records;
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }
    }
    
    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}