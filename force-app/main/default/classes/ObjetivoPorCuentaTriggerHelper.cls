public without sharing class ObjetivoPorCuentaTriggerHelper {
    
    public static void createAccionPorCuenta(List<VisMed_ObjetivoPorCuenta__c> objetivosXCuentas){
        Set<String> objetivosIds = new Set<String>();
        for(VisMed_ObjetivoPorCuenta__c objetivoXCuenta : objetivosXCuentas){
            objetivosIds.add(objetivoXCuenta.VisMed_Objetivo__c);
        }
        List<String> objetivosIdsSinDuplicados = new List<String>(objetivosIds);

        Map<String,List<VisMed_Accion__c>> mapObjIdAccions = new Map<String,List<VisMed_Accion__c>>();
        for(VisMed_Accion__c accion : [SELECT id, Estado__c,VisMed_Objetivo__c FROM VisMed_Accion__c WHERE VisMed_Objetivo__c IN :objetivosIdsSinDuplicados]){
            if(!mapObjIdAccions.containsKey(accion.VisMed_Objetivo__c)){
                mapObjIdAccions.put(accion.VisMed_Objetivo__c, new List<VisMed_Accion__c>());
            }
            mapObjIdAccions.get(accion.VisMed_Objetivo__c).add(accion);
        }
        System.debug('mapObjIdAccions');
        System.debug(mapObjIdAccions);
        if(mapObjIdAccions.size() > 0){
            List<VisMed_AccionPorCuenta__c> accionXCuentaToInsert = new List<VisMed_AccionPorCuenta__c>();
            for(VisMed_ObjetivoPorCuenta__c objetivoXCuenta : objetivosXCuentas){
                for(VisMed_Accion__c objAccion : mapObjIdAccions.get(objetivoXCuenta.VisMed_Objetivo__c)){
                    VisMed_AccionPorCuenta__c accionXCuenta = new VisMed_AccionPorCuenta__c(
                        VisMed_Accion__c = objAccion.Id,
                        VisMed_APMContacto__c = objetivoXCuenta.VisMed_APMContacto__c,
                        VisMed_ObjetivoPorCuenta__c = objetivoXCuenta.Id,
                        VisMed_Objetivo__c = objAccion.VisMed_Objetivo__c,
                        Estado__c = objAccion.Estado__c
                    );
                    accionXCuentaToInsert.add(accionXCuenta);
                }
            }
            System.debug('accionXCuentaToInsert');
            System.debug(accionXCuentaToInsert);
            Database.SaveResult[] saveResultList = Database.insert(accionXCuentaToInsert, true);
            for (Database.SaveResult sr : saveResultList) {
                if (sr.isSuccess()) {
                    System.debug('Se inserto AccionXCuenta');
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }  
                }
            } 
        }
        
    }
}