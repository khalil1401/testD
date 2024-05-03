trigger CycleTrigger on Ciclo__c (before insert, after insert) {

	if (Trigger.isBefore && Trigger.isInsert) {

		List<Ciclo__c> ciclosACalcularDiasHabiles = new List<Ciclo__c>();

		for (Ciclo__c ciclo : Trigger.new) {

			ciclosACalcularDiasHabiles.add(ciclo);
		}

		if (!ciclosACalcularDiasHabiles.isEmpty()) {
			
			CycleTriggerHelper.calcularDiasHabiles(ciclosACalcularDiasHabiles);
		}

		
	}

	if(Trigger.isBefore){
        
        List<Ciclo__c> listaCiclos = new List<Ciclo__c>();
        
        for(Ciclo__c ciclo : Trigger.new){
            
            if(!ciclo.Generado_por_usuario__c){
                
                listaCiclos.add(ciclo);
                
            }
            
        }
        
        if(listaCiclos.size()>0){
            System.debug('SIZE'+listaCiclos.size());
            CycleTriggerHelper.autoCompletarNombreDelCiclo(listaCiclos);
            
        }
	}

}