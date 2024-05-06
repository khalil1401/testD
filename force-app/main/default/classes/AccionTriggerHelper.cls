public  without Sharing class AccionTriggerHelper {
    public static void activarAccionPorCuenta(List<VisMed_Accion__c> acciones){        
        Set<Id> accionIds = new Set<Id>{};
        List<VisMed_AccionPorCuenta__c> accionesPorCuentaActivar = new List<VisMed_AccionPorCuenta__c>();

        for (VisMed_Accion__c accion : acciones) {
            if (accion.Estado__c == 'Activo') {
                accionIds.add(accion.Id);
            }
        }

        List<VisMed_AccionPorCuenta__c> accionesPorCuenta =  [
            SELECT Id, Name, VisMed_Accion__c, Estado__c
            FROM VisMed_AccionPorCuenta__c
            WHERE VisMed_Accion__c IN :accionIds
        ];
       
        if(!accionesPorCuenta.isEmpty()){
            for (VisMed_AccionPorCuenta__c aAccionPorCuenta : accionesPorCuenta) {
                aAccionPorCuenta.Estado__c = 'Activo';
                accionesPorCuentaActivar.add(aAccionPorCuenta);
            }
            update accionesPorCuentaActivar;
        }
    }

    public static void desactivarAccionPorCuenta(List<VisMed_Accion__c> acciones){        
        Set<Id> accionIds = new Set<Id>{};
        List<VisMed_AccionPorCuenta__c> accionesPorCuentaDesactivar = new List<VisMed_AccionPorCuenta__c>();

        for (VisMed_Accion__c accion : acciones) {
            if (accion.Estado__c == 'Inactivo') {
                accionIds.add(accion.Id);
            }
        }

        List<VisMed_AccionPorCuenta__c> accionesPorCuenta =  [
            SELECT Id, Name, VisMed_Accion__c, Estado__c
            FROM VisMed_AccionPorCuenta__c
            WHERE VisMed_Accion__c IN :accionIds
        ];
       
        if(!accionesPorCuenta.isEmpty()){
            for (VisMed_AccionPorCuenta__c aAccionPorCuenta : accionesPorCuenta) {
                aAccionPorCuenta.Estado__c = 'Inactivo';
                accionesPorCuentaDesactivar.add(aAccionPorCuenta);
            }
            update accionesPorCuentaDesactivar;
        }
    }

    public static void createAccionPorCuenta(List<VisMed_Accion__c> acciones){

        Map<String, List<VisMed_Accion__c>> mapObjetivoIdAcciones = new Map<String, List<VisMed_Accion__c>>();
        Map<String, List<VisMed_ObjetivoPorCuenta__c>> mapobjetivoPorCuenta = new Map<String, List<VisMed_ObjetivoPorCuenta__c>>();
        
        for(VisMed_Accion__c accion : acciones){
            if(!mapObjetivoIdAcciones.containsKey(accion.VisMed_Objetivo__c)){
                mapObjetivoIdAcciones.put(accion.VisMed_Objetivo__c, new List<VisMed_Accion__c>());
            }
            mapObjetivoIdAcciones.get(accion.VisMed_Objetivo__c).add(accion);
        }

        system.debug(mapObjetivoIdAcciones.keySet());
        for(VisMed_ObjetivoPorCuenta__c objetivoPorCuenta : [SELECT Id,VisMed_Objetivo__c, VisMed_APMContacto__c FROM VisMed_ObjetivoPorCuenta__c WHERE VisMed_Objetivo__c IN :mapObjetivoIdAcciones.keySet()/* :objetivosIds */]){
            system.debug(objetivoPorCuenta);

            if(!mapobjetivoPorCuenta.containsKey(objetivoPorCuenta.VisMed_Objetivo__c)){
                mapobjetivoPorCuenta.put(objetivoPorCuenta.VisMed_Objetivo__c, new List<VisMed_ObjetivoPorCuenta__c>());
            }
            mapobjetivoPorCuenta.get(objetivoPorCuenta.VisMed_Objetivo__c).add(objetivoPorCuenta);
        }
        system.debug(mapobjetivoPorCuenta);

        List<VisMed_AccionPorCuenta__c> accionXCuentaToInsert = new List<VisMed_AccionPorCuenta__c>();

        for(String objetivo : mapobjetivoPorCuenta.keySet()){
            for(VisMed_ObjetivoPorCuenta__c objxCuenta : mapobjetivoPorCuenta.get(objetivo)){
                List<VisMed_Accion__c> objAcciones = mapObjetivoIdAcciones.get(objetivo);
                for(VisMed_Accion__c accion : objAcciones){
                    VisMed_AccionPorCuenta__c accionXCuenta = new VisMed_AccionPorCuenta__c(
                        VisMed_Accion__c = accion.Id,
                        VisMed_APMContacto__c = objxCuenta.VisMed_APMContacto__c,
                        VisMed_ObjetivoPorCuenta__c = objxCuenta.Id,
                        VisMed_Objetivo__c = accion.VisMed_Objetivo__c,
                        Estado__c = accion.Estado__c
                    );
                    System.debug(accionXCuenta);
                    accionXCuentaToInsert.add(accionXCuenta);
                }
            }
        }

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

    public static void calcularEstadoRegistro(List<VisMed_Accion__c> acciones){
        for(VisMed_Accion__c accion : acciones){
            String estado = 'Pendiente';
            if((accion.VisMed_FechaInicio__c < Date.TODAY() && accion.VisMed_FechaFin__c > Date.TODAY()) || accion.VisMed_FechaInicio__c == Date.TODAY()){
                estado = 'Activo';
            }
            accion.Estado__c = estado;
        }
    }

    public static void activarODesactivarAccion(List<VisMed_Accion__c> acciones){
        Date today = Date.today();  
        System.debug(Today);     
        for (VisMed_Accion__c accion : acciones) {
            if (accion.VisMed_FechaInicio__c <= today && accion.VisMed_FechaFin__c >= today) {
                accion.Estado__c = 'Activo';
            }else {
                accion.Estado__c = 'Inactivo';
            }  
            System.debug('accion: '+ accion);         
            System.debug('accion estado: '+ accion.Estado__c);         
        }         
    }
}