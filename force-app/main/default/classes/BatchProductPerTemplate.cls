public class BatchProductPerTemplate implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date yesterday = Date.today().addDays(-1);
        String query = 
            'SELECT id, Dan360_Activo__c, Dan360_VigenciaDesde__c, Dan360_Vigencia__c ' +
            'FROM Dan360_ProductoPorPlantilla__c ' +
            'WHERE Dan360_VigenciaDesde__c <> NULL AND Dan360_Vigencia__c <> NULL '; // AND Dan360_Vigencia__c >= :yesterday 
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Dan360_ProductoPorPlantilla__c> productsPerTemplate) {
        List<Dan360_ProductoPorPlantilla__c> productsPerTemplateToUpdate = new List<Dan360_ProductoPorPlantilla__c>();
        Date hoy = date.today();        
        for (Dan360_ProductoPorPlantilla__c productPerTemplate : productsPerTemplate) {
            
            if (productPerTemplate.Dan360_Activo__c == true && (hoy > productPerTemplate.Dan360_Vigencia__c || hoy < productPerTemplate.Dan360_VigenciaDesde__c)) {
                //Deactivation
                productPerTemplate.Dan360_Activo__c = false;
                productsPerTemplateToUpdate.add(productPerTemplate);
            } else if (productPerTemplate.Dan360_Activo__c == false && hoy >= productPerTemplate.Dan360_VigenciaDesde__c && hoy <= productPerTemplate.Dan360_Vigencia__c) {
                //Activation
                productPerTemplate.Dan360_Activo__c = true;
                productsPerTemplateToUpdate.add(productPerTemplate); 
            }
        }        
        update productsPerTemplateToUpdate;
    }

    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operationsjaja
    }
}