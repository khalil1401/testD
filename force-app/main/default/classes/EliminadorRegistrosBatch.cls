global class EliminadorRegistrosBatch implements Database.Batchable<sObject>{

    string sobjectType;

    global EliminadorRegistrosBatch(String registroABorrar){
        this.sobjectType = registroABorrar;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT ID FROM '+this.sobjectType+'');
    }
    global void execute(Database.BatchableContext bc, List<SObject> records){
        delete records;
    }    
    global void finish(Database.BatchableContext bc) {

    } 
    
}