trigger SegmentacionTrigger on VisMed_Segmentacion__c (before insert, after insert, after update, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            SegmentacionTriggerHelper.setFrecuencias(Trigger.new, false);
            //Se iguala la categoria anterior a la actual solo en la primera carga
            for(VisMed_Segmentacion__c segmentacion : Trigger.new){
                segmentacion.Categoria_Anterior__c = segmentacion.Categoria__c;
            }
        }
        if(Trigger.isUpdate) {
            List<VisMed_Segmentacion__c> segmentacionesSetFrecuencia = new List<VisMed_Segmentacion__c>();
            List<VisMed_Segmentacion__c> segmentaciones = new List<VisMed_Segmentacion__c>();
            for(VisMed_Segmentacion__c segmentacion : Trigger.new) {
                if(segmentacion.Categoria_Auxiliar__c != segmentacion.Categoria__c) {
                    System.debug('Cambio la categoria de: '+segmentacion.Categoria_Auxiliar__c+ ', a :' +segmentacion.Categoria__c);
                    segmentacion.Categoria_Anterior__c = segmentacion.Categoria_Auxiliar__c;
                    segmentacionesSetFrecuencia.add(segmentacion);
                }
                System.debug('segmentacion.Categoria_Anterior__c');
                System.debug(segmentacion.Categoria_Anterior__c);
            }
            if(segmentacionesSetFrecuencia.size()>0){
                SegmentacionTriggerHelper.setFrecuencias(segmentacionesSetFrecuencia, false);
            } 
        }
    }
}