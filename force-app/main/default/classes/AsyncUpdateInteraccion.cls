public with sharing class AsyncUpdateInteraccion implements Queueable {


    public String inputInteractionId;

    public  void setVariable(String id){
        this.inputInteractionId = id;
    }

    public void execute(QueueableContext context) {


        Dan360_Interacciones__c interactionToUpdate = [SELECT ID FROM Dan360_Interacciones__c WHERE Id = :inputInteractionId];

        System.debug('Se ejecuto la interaccion con el Id > ' + inputInteractionId );

        // Account a = new Account(Name='Acme',Phone='(415) 555-1212');
        // insert a;        
    }
}