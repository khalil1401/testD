public class InteractionTriggerHelper  {
	public static void validateVisitasMedicasInteracciones(List<Interaccion__c> visitasMedicas){
		for(Interaccion__c visita : visitasMedicas){
			if(visita.Fecha__c == null){
				visita.Fecha__c.addError('Seleccione una fecha');
			}
			else if(fechaDeCreacionEsUnFeriado(visita) || fechaDeCreacionEsFinDeSemana(visita)){
				visita.Fecha__c.addError('No puede generar una Visita Médica en un día feriado o fin de semana');
			}
		}
	}

	public static Boolean fechaDeCreacionEsUnFeriado(Interaccion__c visita){
		for(Feriado__c feriado : [SELECT Fecha__c FROM Feriado__c]){
			if(feriado.Fecha__c == visita.Fecha__c){
				return true;
			}
		}
		return false;
	}

	public static Boolean fechaDeCreacionEsFinDeSemana(Interaccion__c interaccion){
		Datetime today = Datetime.newInstance(interaccion.Fecha__c, Time.newInstance(0,0,0,0));
		string dayName = today.format('EEEE');
		if(dayName == 'Saturday' || dayName == 'Sunday'){
			return true;
		}
		return false;
	}
}