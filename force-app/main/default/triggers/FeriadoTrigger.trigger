trigger FeriadoTrigger on Feriado__c (after insert, after delete) {
	if(Trigger.isAfter && Trigger.isInsert)
    {
        List<Date> dateQuery = new List<Date>();
        for(Feriado__c feriado : Trigger.New)
        {
            dateQuery.add(Date.newInstance(feriado.Fecha__c.year(), feriado.Fecha__c.month(), 1));
        }
       	List<Ciclo__c> ciclos = [SELECT Id, Fecha_de_inicio__c, Fecha_de_fin__c, 
                                 		Cantidad_de_dias_en_el_mes__c, Cantidad_de_dias_habiles__c
                                 FROM Ciclo__c
                                 WHERE Fecha_de_inicio__c IN :dateQuery];
        if (!ciclos.isEmpty()) {
			CycleTriggerHelper.calcularDiasHabiles(ciclos);
		}
        for(Ciclo__c c : ciclos){
            system.debug(c.Cantidad_de_dias_habiles__c);
        }
        update ciclos;
    }
    if(Trigger.isAfter && Trigger.isDelete)
    {
        List<Date> dateQuery = new List<Date>();
        for(Feriado__c feriado : Trigger.Old)
        {
            dateQuery.add(Date.newInstance(feriado.Fecha__c.year(), feriado.Fecha__c.month(), 1));
        }
       	List<Ciclo__c> ciclos = [SELECT Id, Fecha_de_inicio__c, Fecha_de_fin__c, 
                                 		Cantidad_de_dias_en_el_mes__c, Cantidad_de_dias_habiles__c
                                 FROM Ciclo__c
                                 WHERE Fecha_de_inicio__c IN :dateQuery];
        if (!ciclos.isEmpty()) {
			CycleTriggerHelper.calcularDiasHabiles(ciclos);
		}
        update ciclos;
    }
}