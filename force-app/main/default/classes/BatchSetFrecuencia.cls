public with sharing class BatchSetFrecuencia implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT	Id,';
		query += '				Profesional__c,';
		query += '				VisMed_APM__c,';        
        query += '				Segmenta_Por__c,';
        query += '				Estado__c,';
        query += '				Fecha_de_Aprobacion__c,';
        query += '				Segmenta_Anterior__c,';
        query += '				VisMed_Semaforo__c';
		query += '		FROM	VisMed_Contacto_Cuenta_Usuario__c';
		query += '		WHERE	Estado__c = \'Activo\'';
        query += '		AND     Segmenta_Por__c != null';
        query += '		AND     Actualizar_Frecuencia__c = True';
        //query += '		AND     Segmenta_Por__c != Segmenta_Anterior__c';
        //query += '		AND     (CreatedDate = LAST_MONTH';
        //query += '		OR     LastModifiedDate = LAST_MONTH)';
        //query += '		AND     Fecha_de_Aprobacion__c = LAST_MONTH';
        System.debug('ficheros aprobados el mes pasado: '+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<VisMed_Contacto_Cuenta_Usuario__c> scope){
        System.debug('Ficheros '+ scope);
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        // List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaUpdatearSegmentaAnterior = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        // String segmentaAuxiliar;       
        for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : scope) {            
            // segmentaAuxiliar = seguimiento.Segmenta_Por__c;
            System.debug('Segmenta aterior '+ seguimiento.Segmenta_Anterior__c);
            //if (seguimiento.Segmenta_Anterior__c != null) {
                //if (seguimiento.Segmenta_Anterior__c != seguimiento.Segmenta_Por__c) {
                    // seguimiento.Segmenta_Anterior__c = segmentaAuxiliar;
                    // seguimientosParaUpdatearSegmentaAnterior.add(seguimiento);
                    //System.debug('Segmenta aterior Nuevo'+ seguimiento.Segmenta_Anterior__c);                
                    //seguimientos.add(seguimiento);
                //}                
            //} else {
                // seguimiento.Segmenta_Anterior__c = segmentaAuxiliar;
                // seguimientosParaUpdatearSegmentaAnterior.add(seguimiento);
                //System.debug('Segmenta aterior Nuevo'+ seguimiento.Segmenta_Anterior__c);                
                seguimientos.add(seguimiento);
                
            //}
        }
        System.debug(seguimientos);
        // if (seguimientosParaUpdatearSegmentaAnterior.size() > 0 && !seguimientosParaUpdatearSegmentaAnterior.isEmpty() ) {
        //     Database.update(seguimientosParaUpdatearSegmentaAnterior, false);
            
        // }
        if (seguimientos.size() > 0 && !seguimientos.isEmpty()) {
            SeguimientoTriggerHelper.crearSegmentacion(seguimientos);
            SeguimientoTriggerHelper.setFrecuencia(seguimientos, true, true);            
        }
    }

    public void finish(Database.BatchableContext context) {
	}
}