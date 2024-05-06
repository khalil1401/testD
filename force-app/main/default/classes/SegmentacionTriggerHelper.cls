public with sharing class SegmentacionTriggerHelper {
    
    public static void setFrecuencias (List<VisMed_Segmentacion__c> segmentaciones, Boolean isUpdate) {
        List<Frecuencia_por_Categoria__mdt> mdt;
        Map<String, Frecuencia_por_Categoria__mdt> frecuenciaParaEquipoCategoria = new Map<String,Frecuencia_por_Categoria__mdt>();
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosById();
        System.debug('rtMap');
        System.debug(rtMap);
        mdt = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Categoria__c, Frecuencia__c, Segmenta_Por__c 
                FROM Frecuencia_por_Categoria__mdt];
        System.debug('mdt '+ mdt);
        for (Frecuencia_por_Categoria__mdt metadata : mdt) {
            String key = metadata.Segmenta_Por__c + '-' + metadata.Categoria__c;
            frecuenciaParaEquipoCategoria.put(key, metadata);
        }
        System.debug('frecuenciaParaEquipoCategoria');
        System.debug(frecuenciaParaEquipoCategoria);
        for(String key : frecuenciaParaEquipoCategoria.keySet()) {
            System.debug(key);
        }
        for (VisMed_Segmentacion__c segmentacion : segmentaciones) {
            String key = rtMap.get(segmentacion.RecordTypeId).getName() + '-' + segmentacion.Categoria__c;
            System.debug('Segmentacion y Categoria: ' + key);
            if (frecuenciaParaEquipoCategoria.containsKey(key)) {
                System.debug('Segmentacion y Categoria: ' + key);
                segmentacion.Frecuencia__c = frecuenciaParaEquipoCategoria.get(key).Frecuencia__c;
                System.debug('segmentacion.Frecuencia__c: ' + segmentacion.Frecuencia__c);
            }
            System.debug('Segmentacion: ' + segmentacion);
        }

        if (isUpdate) {
            update segmentaciones;
        }
    }

}