public class CycleTriggerHelper  {

	public static void calcularDiasHabiles(
		List<SObject> sobjs, String campoFechaInicio, String campoFechaFin, String campoTotalDias, String campoDiasHabiles
	) {
		
		Date fechaMinima = obtenerFechaMinima(sobjs, campoFechaInicio);
		Date fechaMaxima = obtenerFechaMaxima(sobjs, campoFechaFin);

		if (fechaMinima == null || fechaMaxima == null) {
			return;
		}
		
		List<Feriado__c> diasFeriados = new List<Feriado__c>([
			SELECT Fecha__c
			FROM Feriado__c
			WHERE Fecha__c >= :fechaMinima
				AND Fecha__c <= :fechaMaxima
		]);
		system.debug('diasFeriados: '+diasFeriados.size());
		for (SObject sobj : sobjs) {

			Decimal cantidadDeDias = CycleTriggerHelper.cantidadDeDiasNoHabiles(
				(Date) sobj.get(campoFechaInicio), (Date) sobj.get(campoFechaFin), diasFeriados
			);
			cantidadDeDias = (Decimal) sobj.get(campoTotalDias) - cantidadDeDias;
            if(cantidadDeDias < 0){
                cantidadDeDias = 0;
            }
            sobj.put(campoDiasHabiles, cantidadDeDias);
			
		}

	}

	public static void calcularDiasHabiles(List<Licencia__c> licencias) {

		calcularDiasHabiles(licencias, 'Fecha_de_inicio__c', 'Fecha_de_fin__c', 'cantidad_de_dias__c','Cantidad_de_dias_de_la_licencia__c');
		
	}

	public static void calcularDiasHabiles(List<Ciclo__c> ciclos) {
		
		calcularDiasHabiles(ciclos, 'Fecha_de_inicio__c', 'Fecha_de_fin__c', 'Cantidad_de_dias_en_el_mes__c', 'Cantidad_de_dias_habiles__c');
		
	}

	public static Date obtenerFechaMinima (List<SObject> sobjs, String campoFecha) {
		
		Date out;
		
		for (SObject sobj : sobjs) {
			if (out == null 
				|| (sobj.get(campoFecha) != null 
					&& (Date) sobj.get(campoFecha) < out
				)
			) {
				out = (Date) sobj.get(campoFecha);
			}
		}
		return out;
	}

	public static Date obtenerFechaMaxima (List<SObject> sobjs, String campoFecha) {

		Date out;
		
			for (SObject sobj : sobjs) {
			
				if (out == null 
					|| (sobj.get(campoFecha) != null 
						&& (Date) sobj.get(campoFecha) > out
					)
				) {
					out = (Date) sobj.get(campoFecha);
				}
			}
				
		return out;
	}


	public static Integer cantidadDeDiasNoHabiles (Date fechaInicial, Date fechaFinal, List<Feriado__c> diasFeriados) {

		Integer cantidadDeDias = 0;

		Datetime myInitialDate = Datetime.newInstance(fechaInicial.year(), fechaInicial.month(), fechaInicial.day());
		Datetime myFinalDate = Datetime.newInstance(fechaFinal.year(), fechaFinal.month(), fechaFinal.day());

		Integer initialDay = myInitialDate.day();
		Integer finalDay = myFinalDate.day();

		String dayName = myInitialDate.format('EEEE');
			
		if (dayName == 'Saturday' || dayName == 'Sunday') {
				
			cantidadDeDias = cantidadDeDias + 1;

		}

		for (Integer i = 1 ; i < (finalDay-initialDay)+1 ; i++) {

			Datetime days = myInitialDate.addDays(i);
			String dayNames = days.format('EEEE');
			
			if (dayNames == 'Saturday' || dayNames == 'Sunday') {
				
				cantidadDeDias = cantidadDeDias + 1;

			}

		}

		Date initialDate = Date.newInstance(fechaInicial.year(), fechaInicial.month(), fechaInicial.day());
		Date finalDate = Date.newInstance(fechaFinal.year(), fechaFinal.month(), fechaFinal.day());

		for (Feriado__c diaFeriado : diasFeriados) {
		
			if (diaFeriado.Fecha__c >= initialDate && diaFeriado.Fecha__c <= finalDate) {

				Datetime day = Datetime.newInstance(diaFeriado.Fecha__c.year(), diaFeriado.Fecha__c.month(), diaFeriado.Fecha__c.day());
				String dayNames = day.format('EEEE');

				if (dayNames != 'Saturday' && dayNames != 'Sunday') {
				
					cantidadDeDias = cantidadDeDias + 1;

				}
			}
		}
			
		return cantidadDeDias;

	}

	public static void autoCompletarNombreDelCiclo(List<Ciclo__c> listCiclos){

		List<id> contactId = new List<id>();

		for(Ciclo__c cicloToUpdate : listCiclos){

			contactId.add(cicloToUpdate.contactId__c);
		}

		Map<Id, Contact> mapContact = new Map<Id, Contact>(
			[
			   SELECT id,Name 
			   FROM Contact
			   WHERE id IN :contactId
		   	]);

		for(Ciclo__c cicloToUpdate : listCiclos){
			
			Contact relatedContact = mapContact.get(cicloToUpdate.ContactId__c);

			if(relatedContact !=null){

				DateTime fecha = DateTime.now();
				String nombreDelMes = fecha.format('MMMMM');
				String yearName = fecha.format('YYYY');

				cicloToUpdate.name =nombreDelMes+ ' - '+ yearName+ ' - ' +relatedContact.name;


			}else{

				System.debug('El ciclo no Tiene contacto relacionado');
			} 

		}

	}
}