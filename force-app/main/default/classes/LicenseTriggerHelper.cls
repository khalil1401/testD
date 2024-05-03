public class LicenseTriggerHelper  {

	public static List<Licencia__c> getLicenciasACalcularDiasHabilesInsert(List<Licencia__c> licencias) {

		List<Licencia__c> licenciasACalcularDiasHabiles = new List<Licencia__c>();
		for (Licencia__c licencia : licencias) {
			if (licencia.Aprobado__c == true && licencia.Fecha_de_inicio__c != null && licencia.Fecha_de_fin__c != null) {		
				licenciasACalcularDiasHabiles.add(licencia);
			} 
		}
		return licenciasACalcularDiasHabiles;
	}

	public static List<Licencia__c> getLicenciasACalcularDiasHabilesUpdate(Map<id, Licencia__c> odlLicencias, List<Licencia__c> licencias) {
		List<Licencia__c> licenciasACalcularDiasHabiles = new List<Licencia__c>();

		for (Licencia__c licencia : licencias) {
            if(licencia.Fecha_de_inicio__c != null && licencia.Fecha_de_fin__c != null)
            {
                Licencia__c licenciaOld = odlLicencias.get(licencia.Id);
                Boolean fueAprobada = licencia.Aprobado__c == true && licenciaOld.Aprobado__c == false;
                Boolean cambioCantidadDeDias = licencia.Aprobado__c == true && 
                    licencia.Cantidad_de_dias__c != licenciaOld.Cantidad_de_dias__c;
                
                if (fueAprobada || cambioCantidadDeDias) {		
                    licenciasACalcularDiasHabiles.add(licencia);
                    
    
                } else if (licencia.Aprobado__c == false && licenciaOld.Aprobado__c == true) {
                    licencia.Cantidad_de_dias_de_la_licencia__c = 0;
                }
            }
		}
		return licenciasACalcularDiasHabiles;

	}

}