trigger LicenseTrigger on Licencia__c (before insert, before update, after update, after insert) {

	if (Trigger.isInsert && Trigger.isBefore) {
		
		List<Licencia__c> licenciasACalcularDiasHabiles = LicenseTriggerHelper.getLicenciasACalcularDiasHabilesInsert(Trigger.new);

		if (!licenciasACalcularDiasHabiles.isEmpty()) {
			CycleTriggerHelper.calcularDiasHabiles(licenciasACalcularDiasHabiles);
		}
	}

	if (Trigger.isUpdate && Trigger.isBefore) {
		
		List<Licencia__c> licenciasACalcularDiasHabiles = LicenseTriggerHelper.getLicenciasACalcularDiasHabilesUpdate(Trigger.oldMap, Trigger.new);
		
		if (!licenciasACalcularDiasHabiles.isEmpty()) {
			CycleTriggerHelper.calcularDiasHabiles(licenciasACalcularDiasHabiles);
		}
		
	}
	if(Trigger.isInsert && Trigger.isAfter) {
		Map<Id, Ciclo__c> idCiclo = new Map<Id, Ciclo__c>();
		for(Licencia__c lc : Trigger.new) {
			if(lc.Aprobado__c) {
				if(!idCiclo.containsKey(lc.Ciclo__c))
					idCiclo.put(lc.Ciclo__c, null);
			}
		}
		List<Ciclo__c> listaCiclos = [SELECT Id,Cantidad_de_dias_habiles__c,
									  Dias_de_campo_efectivo_transcurridos__c,
									  Fecha_de_inicio__c,Fecha_de_fin__c,
									  Cantidad_de_dias_en_el_mes__c,Actualizar__c,
									  (SELECT Id,Cantidad_de_dias__C,Ciclo__c,Aprobado__c,
									  Dia_decimal__c,
									  Fecha_de_inicio__c,Fecha_de_fin__c 
									  FROM Licencias__r)
									  FROM Ciclo__c
									  WHERE Id IN :idCiclo.keySet()];
		for(Ciclo__c c : listaCiclos)
			c.Actualizar__c = true;
		listaCiclos = DiasHabilesTranscurridosHelper.calcularDiasHabilesTranscurridos(listaCiclos);
		if(listaCiclos != null && listaCiclos.size() > 0)
			update listaCiclos;
	}

	
	if(Trigger.isUpdate && Trigger.isAfter) {
		Map<Id, Ciclo__c> idCiclo = new Map<Id, Ciclo__c>();
		for(Licencia__c lc : Trigger.new) {
			if(lc.Aprobado__c) {
				if(!idCiclo.containsKey(lc.Ciclo__c))
					idCiclo.put(lc.Ciclo__c, null);
			}
		}
		List<Ciclo__c> listaCiclos = [SELECT Id,Cantidad_de_dias_habiles__c,
									  Dias_de_campo_efectivo_transcurridos__c,
									  Fecha_de_inicio__c,Fecha_de_fin__c,
									  Cantidad_de_dias_en_el_mes__c,Actualizar__c,
									  (SELECT Id,Cantidad_de_dias__C,Ciclo__c,Aprobado__c,
									  Dia_decimal__c,
									  Fecha_de_inicio__c,Fecha_de_fin__c 
									  FROM Licencias__r)
									  FROM Ciclo__c
									  WHERE Id IN :idCiclo.keySet()];
		for(Ciclo__c c : listaCiclos)
			c.Actualizar__c = true;
		listaCiclos = DiasHabilesTranscurridosHelper.calcularDiasHabilesTranscurridos(listaCiclos);
		if(listaCiclos != null && listaCiclos.size() > 0)
			update listaCiclos;
	}
}