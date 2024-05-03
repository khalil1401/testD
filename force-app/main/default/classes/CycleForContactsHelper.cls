public class CycleForContactsHelper  {
	
	@Future
	public static void cyclesForContactTrigger (Id usuario) {

		Id recordTypeId = XappiaHelper.getRecordType('Contact', 'Visitador médico').Id;

		List<User> usuariosBD = new List<User> ([
			SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.RecordTypeId, Contact.OwnerId
			FROM User
			WHERE Contact.RecordTypeId = :recordTypeId 
				AND Id = :usuario
		]);

		if (usuariosBD.isEmpty()) {
			return;
		}

		List<Ciclo__c> cycles = cyclesForContact(usuariosBD[0].Contact, usuariosBD[0].Id);
		insert cycles;
	}
    
	public static List<Ciclo__c> cyclesForContact (Contact contacto, id usuario) {
        
        Map<String,String>  monthNameMap = new Map<String, String> {
            '1'=>'Enero', '2'=>'Febrero', '3'=>'Marzo', '4'=>'Abril', '5'=>'Mayo', '6'=>'Junio',
                '7'=>'Julio', '8'=>'Agosto', '9'=>'Septiembre','10'=>'Octubre', '11'=>'Noviembre', '12'=>'Diciembre'
                };
    	return cyclesForContactWithMonths(contacto, usuario, monthNameMap);
    }

	public static List<Ciclo__c> cyclesForContactWithMonths(Contact contacto, id usuario, Map<String,String> monthNameMap) {

		List<Ciclo__c> listCycles = new List<Ciclo__c>();

		Integer year = Date.today().year();
		Datetime initialMonth = Date.newInstance(year, 01, 01);
		String monthNumber = initialMonth.formatGmt('M');
        
		String monthName = monthNameMap.get(monthNumber);

		Date initialDay = Date.newInstance(year, 01, 01);

		Date finalDay = initialDay.addMonths(1).addDays(-1);
        if (monthNameMap.containsKey(monthNumber)) {
            listCycles.add(new Ciclo__c(ContactId__c = contacto.Id,
                                        Name = monthName + ' ' + year + ' - ' + contacto.FirstName + ' ' + contacto.LastName,
                                        OwnerId = usuario,
                                        Fecha_de_inicio__c = initialDay,
                                        Fecha_de_fin__c = finalDay,
                                        Generado_por_usuario__c =true));
        }
		for(Integer i = 1 ; i < 12; i ++) {
	  
			Datetime moths = initialMonth.addMonths(i);
			String monthNumbers = moths.formatGmt('M');
			String monthNames = monthNameMap.get(monthNumbers);

			initialDay = initialDay.addMonths(1);

			finalDay = initialDay.addMonths(1).addDays(-1);
            
            if (monthNameMap.containsKey(monthNumbers)) {
                listCycles.add(new Ciclo__c(ContactId__c = contacto.Id,
                                            Name = monthNames + ' ' + year + ' - ' + contacto.FirstName + ' ' + contacto.LastName,
                                            OwnerId = usuario,
                                            Fecha_de_inicio__c = initialDay,
                                            Fecha_de_fin__c = finalDay,
                                            Generado_por_usuario__c =true));
            }
		}

		return listCycles;

	}

}