public class Flow_Frecuencias {
    
    @InvocableMethod(label='Flow_Frecuencias')
    public static void frecuenciaAction(List<Id> fichero){
        	
       	System.debug('Se detecto un cambio en la frecuencia de fichero > ' 
                     + [SELECT Id FROM VisMed_Contacto_Cuenta_Usuario__c WHERE Id = :fichero[0]] );
        
    }
}