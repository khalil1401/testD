public class DiasHabilesTranscurridosHelper  {
	// Esto es un remake de CycleTriggerHelper
	public static List<Ciclo__c> calcularDiasHabilesTranscurridos(List<Ciclo__c> sobjs) {
		List<Ciclo__c> resultados = new List<Ciclo__c>();
		Date fechaMinima = CycleTriggerHelper.obtenerFechaMinima(sobjs, 'fecha_de_inicio__c');
		Date fechaMaxima = CycleTriggerHelper.obtenerFechaMaxima(sobjs, 'fecha_de_fin__c');
		fechaMaxima = fechaMaxima <= System.today() ? fechaMaxima : System.today();
		fechaMinima = fechaMinima <= System.today() ? fechaMinima : null;
		if (fechaMinima == null || fechaMaxima == null) {
			return null;
		}
		//Map<Id, List<Licencia__c>> CicloLicencia = new Map<Id, List<Licencia__c>>();
		List<Feriado__c> diasFeriados = new List<Feriado__c>([
			SELECT Fecha__c
			FROM Feriado__c
			WHERE Fecha__c >= :fechaMinima
				AND Fecha__c <= :fechaMaxima
		]);
		
		Date inicioCiclosActuales = Date.newInstance(System.today().year(), System.today().month(), 1);
		for (Ciclo__c sobj : sobjs) {
			
			if((sobj.Fecha_de_inicio__c >= fechaMinima && sobj.Actualizar__c) || sobj.Fecha_de_inicio__c >= inicioCiclosActuales)
			{
				Date cicloFechaMaxima = fechaMaxima > sobj.Fecha_de_fin__c ? sobj.Fecha_de_fin__c : fechaMaxima;
				
				Decimal cantidadDeDias = CycleTriggerHelper.cantidadDeDiasNoHabiles(
					(Date) sobj.Fecha_de_inicio__c, (Date) cicloFechaMaxima, diasFeriados
				);
				
				cantidadDeDias = (Decimal) cicloFechaMaxima.day() - cantidadDeDias;
				
				if(sobj.Licencias__r != null && sobj.Licencias__r.size() > 0)
					cantidadDeDias -= calcularDiasDeLicenciaTranscurridos(sobj.Licencias__r, diasFeriados);
				if(cantidadDeDias < 0)
					cantidadDeDias = 0;
				sobj.Dias_de_campo_efectivo_transcurridos__c = cantidadDeDias;
				resultados.add(sobj);
				
				if(sobj.Fecha_de_inicio__c < inicioCiclosActuales) {
					sobj.Actualizar__c = false;
					
				}
			}
		}
		return resultados;
	}
	public static Decimal calcularDiasDeLicenciaTranscurridos(List<Licencia__c> licencias, List<Feriado__c> todosFeriados) 
	{
		Decimal diasARestar = 0;
		Date fechaMinima = CycleTriggerHelper.obtenerFechaMinima(licencias, 'fecha_de_inicio__c');
		Date fechaMaxima = CycleTriggerHelper.obtenerFechaMaxima(licencias, 'fecha_de_fin__c');
		fechaMaxima = fechaMaxima <= System.today() ? fechaMaxima : System.today();
		
		List<Feriado__c> diasFeriados = new List<Feriado__c>();
		for(Feriado__c feriado : todosFeriados)
		{
			if(feriado.Fecha__c >= fechaMinima && feriado.Fecha__c <= fechaMaxima)
				diasFeriados.add(feriado);
		}
		for (Licencia__c licencia : licencias) {
			if(licencia.Aprobado__c)
			{
				Date ultimaFecha = licencia.Fecha_de_fin__c < fechaMaxima ? licencia.Fecha_de_fin__c : fechaMaxima;

				Decimal cantDiasTranscurridos = 0;
				Decimal cantidadDeDias = 0;
				
				if(licencia.Fecha_de_inicio__c != null &&
						licencia.Fecha_de_inicio__c == licencia.Fecha_de_fin__c && 
						licencia.Dia_decimal__c != null)
				{
					cantDiasTranscurridos = licencia.Dia_decimal__c;
				}
				else if(licencia.Fecha_de_inicio__c != null)
				{
					cantDiasTranscurridos = ultimaFecha.day() - licencia.Fecha_de_inicio__c.day() + 1; // +1 porque el dia de inicio tambien cuenta
					
					cantidadDeDias = CycleTriggerHelper.cantidadDeDiasNoHabiles(licencia.Fecha_de_inicio__c, ultimaFecha, diasFeriados);
				}

				if(cantidadDeDias < 0)
					cantidadDeDias = 0;
				
				cantidadDeDias = cantDiasTranscurridos - cantidadDeDias;
				if(cantidadDeDias < 0)
					cantidadDeDias = 0;
				diasARestar += cantidadDeDias;
			}
		}
		return diasARestar;
	}
}