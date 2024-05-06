public class BatchUpdateFicheroCategory implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext context) {

		String query = 'SELECT	Id,';
		query += '				Profesional__c,';
		query += '				VisMed_APM__c,';
        query += '				Categoria__c,';
        query += '				VisMed_Semaforo__c,';
        query += '				Segmenta_Por__c';
		query += '		FROM	VisMed_Contacto_Cuenta_Usuario__c';
		query += '		WHERE	Estado__c = \'Activo\'';
        query += '		AND     Categoria__c != null';
        query += '		AND     Categoria__c != \'null\'';
		query += '		AND     Segmenta_Por__c != null';
		
		
		System.debug('query:::' + query);
		return Database.getQueryLocator(query);
	}

    public void execute(Database.BatchableContext context, List<VisMed_Contacto_Cuenta_Usuario__c> ficheros) {
		Map<String,Map<String,String>> mapProfesionalSegmentaCategoria = new Map<String,Map<String,String>>();
		Set<String> segmentaPor = new Set<String>();

		Map<String,Map<String,String>> mapProfesionalSegmentaCategoriaSegmentacion = new Map<String,Map<String,String>>();
        for(VisMed_Contacto_Cuenta_Usuario__c fichero : ficheros){
			if(!mapProfesionalSegmentaCategoria.containsKey(fichero.Profesional__c)){
				mapProfesionalSegmentaCategoria.put(fichero.Profesional__c, new Map<String,String>());
			}
			if(!mapProfesionalSegmentaCategoria.get(fichero.Profesional__c).containsKey(fichero.Segmenta_Por__c)){
				mapProfesionalSegmentaCategoria.get(fichero.Profesional__c).put(fichero.Segmenta_Por__c, fichero.Categoria__c);
			}
			segmentaPor.add(fichero.Segmenta_Por__c);
        }
		
		for(VisMed_Segmentacion__c segmentacion : [SELECT Id, Profesional__c, Categoria__c, RecordType.Name FROM VisMed_Segmentacion__c WHERE Profesional__c IN :mapProfesionalSegmentaCategoria.keySet() AND RecordType.Name IN :segmentaPor]){
			if(!mapProfesionalSegmentaCategoriaSegmentacion.containsKey(segmentacion.Profesional__c)){
				mapProfesionalSegmentaCategoriaSegmentacion.put(segmentacion.Profesional__c, new Map<String,String>());
			}
			if(!mapProfesionalSegmentaCategoriaSegmentacion.get(segmentacion.Profesional__c).containsKey(segmentacion.RecordType.Name)){
				mapProfesionalSegmentaCategoriaSegmentacion.get(segmentacion.Profesional__c).put(segmentacion.RecordType.Name,segmentacion.Categoria__c);
			}
		}
		List<VisMed_Contacto_Cuenta_Usuario__c> ficherosToUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>();
		for(VisMed_Contacto_Cuenta_Usuario__c fichero : ficheros){
			for(String segmentacion : mapProfesionalSegmentaCategoriaSegmentacion.get(fichero.Profesional__c).keySet()){
				if(fichero.Segmenta_Por__c == segmentacion){
					String categoriaToCompare = mapProfesionalSegmentaCategoriaSegmentacion.get(fichero.Profesional__c).get(segmentacion);
					if(fichero.Categoria__c != categoriaToCompare){
						ficherosToUpdate.add(fichero);
					}
				}
			}
		}
		
		SeguimientoTriggerHelper.setFrecuencia(ficherosToUpdate, true, false);
	
	}   

    public void finish(Database.BatchableContext context) {
	}
}