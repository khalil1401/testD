public without sharing class MetadataInsertUpdate implements Metadata.DeployCallback {
    public static Boolean testResultIsSuccessful;
    public static Database.SaveResult resultsEvents;

    public void handleResult (Metadata.DeployResult result, Metadata.DeployCallbackContext context) {        
        if (result.status == Metadata.DeployStatus.Succeeded) {           
            System.debug('success: '+ result);
            Metadata_updated__e platformEvent = new Metadata_updated__e(
                isSuccess__c = true
            );
            resultsEvents = Eventbus.publish(platformEvent);
        } else {           
            System.debug(' fail: '+ result);    
        }       
    }
    
    public static void handleInsertAndUpdate (String fullName, String label, Map<String, Object> fieldWithValuesMap){     
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata(); //Creo la metada en funcion de los valores recibidos.
        customMetadata.fullName = fullName;
        customMetadata.label = label;
        fieldWithValuesMap.remove('fullName');
        fieldWithValuesMap.remove('developerName');
        fieldWithValuesMap.remove('id');
        fieldWithValuesMap.remove('label');
        for (String key: fieldWithValuesMap.keySet()) { // Recorro el mapa de valores y por cada uno creo un CustomMetadataValue.
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = key.replace('_c', '__c');
            customField.value = fieldWithValuesMap.get(key);
            customMetadata.values.add(customField); // Agrego el valor creado a la metadata.
        }
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer(); // Inicio un deploy de la metadata.
        mdContainer.addMetadata(customMetadata);
        metadataInsertUpdate callback = new metadataInsertUpdate();
        
        if(!Test.isRunningTest()) {
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback); // Hago deploy de la metadata.
        }else{
            //Test data
            Metadata.DeployResult result = new Metadata.DeployResult();
            if(testResultIsSuccessful){
                result.status = Metadata.DeployStatus.SUCCEEDED;
            }else {
                result.status = Metadata.DeployStatus.FAILED;
            }
            callback.handleResult(result, new Metadata.DeployCallbackContext());
        }
        
    }
    
}