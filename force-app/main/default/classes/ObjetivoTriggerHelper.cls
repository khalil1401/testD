public class ObjetivoTriggerHelper {
    public static void activarObjetivoPorCuenta(List<VisMed_Objetivo__c> objetivos){        
        Set<Id> objetivoIds = new Set<Id>{};
        List<VisMed_ObjetivoPorCuenta__c> objetivosPorCuentaActivar = new List<VisMed_ObjetivoPorCuenta__c>();

        for (VisMed_Objetivo__c objetivo : objetivos) {
            if (objetivo.Estado__c == 'Activo') {
                objetivoIds.add(objetivo.Id);
            }
        }

        List<VisMed_ObjetivoPorCuenta__c> objetivosPorCuenta =  [
            SELECT Id, Name, VisMed_Objetivo__c, Estado__c
            FROM VisMed_ObjetivoPorCuenta__c
            WHERE VisMed_Objetivo__c IN :objetivoIds
        ];
       
        if(!objetivosPorCuenta.isEmpty()){
            for (VisMed_ObjetivoPorCuenta__c aObjetivoPorCuenta : objetivosPorCuenta) {
                aObjetivoPorCuenta.Estado__c = 'Activo';
                objetivosPorCuentaActivar.add(aObjetivoPorCuenta);
            }
            update objetivosPorCuentaActivar;
        }
    }

    public static void desactivarObjetivoPorCuenta(List<VisMed_Objetivo__c> objetivos){        
        Set<Id> objetivoIds = new Set<Id>{};
        List<VisMed_ObjetivoPorCuenta__c> objetivosPorCuentaDesactivar = new List<VisMed_ObjetivoPorCuenta__c>();

        for (VisMed_Objetivo__c objetivo : objetivos) {
            if (objetivo.Estado__c == 'Inactivo') {
                objetivoIds.add(objetivo.Id);
            }
        }

        List<VisMed_ObjetivoPorCuenta__c> objetivosPorCuenta =  [
            SELECT Id, Name, VisMed_Objetivo__c, Estado__c
            FROM VisMed_ObjetivoPorCuenta__c
            WHERE VisMed_Objetivo__c IN :objetivoIds
        ];
       
        if(!objetivosPorCuenta.isEmpty()){
            for (VisMed_ObjetivoPorCuenta__c aObjetivoPorCuenta : objetivosPorCuenta) {
                aObjetivoPorCuenta.Estado__c = 'Inactivo';
                objetivosPorCuentaDesactivar.add(aObjetivoPorCuenta);
            }
            update objetivosPorCuentaDesactivar;
        }
    }
    public static void activarODesactivarObjetivo(List<VisMed_Objetivo__c> objetivos){
        Date today = Date.today();  
        System.debug(Today);     
        for (VisMed_Objetivo__c objetivo : objetivos) {
            if (objetivo.VisMed_FechaInicio__c <= today && objetivo.VisMed_FechaFin__c >= today) {
                objetivo.Estado__c = 'Activo';
            }else {
                objetivo.Estado__c = 'Inactivo';
            }  
            System.debug('objetivo: '+ objetivo);         
            System.debug('objetivo estado: '+ objetivo.Estado__c);         
        }         
    }
}