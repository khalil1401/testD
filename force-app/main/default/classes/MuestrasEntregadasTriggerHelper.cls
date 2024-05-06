public with sharing class MuestrasEntregadasTriggerHelper {
    
    public static void checkDuplicates(List<Muestras_Entregadas__c> muestrasMedicas){
        Map<String, List<String>> mapInteraccionStockxMMInsert = new Map<String, List<String>>(); // Guarda la interaccion de la muestra a insertar con su stockMM
        Map<String, List<String>> mapInteraccionProductNameInsert = new Map<String, List<String>>(); // Guarda la interaccion de la muestra a insertar con el nombre del producto
        List<String> stockxMMIds = new List<String>(); // Guarda los StockMM de las muestras a insertar
        List<String> interaccionesIds = new List<String>(); // Guarda las inteacciones de las muestras a insertar
        for(Muestras_Entregadas__c muestraMedica : muestrasMedicas){
            interaccionesIds.add(muestraMedica.Interaccion__c);
        }
        
        Map<String, List<String>> mapInteraccionStockMMSF = new Map<String, List<String>>();
        for(Muestras_Entregadas__c muestrasSf : [SELECT Interaccion__c, Stock_x_MM__c FROM Muestras_Entregadas__c WHERE Interaccion__c IN : interaccionesIds]){
            if(!mapInteraccionStockMMSF.containsKey(muestrasSf.Interaccion__c)){
                mapInteraccionStockMMSF.put(muestrasSf.Interaccion__c, new List<String>());
            }
            mapInteraccionStockMMSF.get(muestrasSf.Interaccion__c).add(muestrasSf.Stock_x_MM__c);
        }
        System.debug('mapInteraccionStockMMSF');
        System.debug(mapInteraccionStockMMSF);

        if(mapInteraccionStockMMSF.size()>0){
            for(Muestras_Entregadas__c muestraMedica : muestrasMedicas){
                if(mapInteraccionStockMMSF.containsKey(muestraMedica.Interaccion__c)){
                    for(String stockMMSF : mapInteraccionStockMMSF.get(muestraMedica.Interaccion__c)){
                        if(stockMMSF == muestraMedica.Stock_x_MM__c){
                            muestraMedica.addError('Muestra medica Duplicada en la interaccion: ' + muestraMedica.Interaccion__c);
                        }
                    }
                }
            }
        }
    }
}