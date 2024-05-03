global class BatchCycleForContacts implements Database.Batchable<SObject> {

	global Database.QueryLocator start(Database.BatchableContext contactSearch) {

		Id recordTypeId = XappiaHelper.getRecordType('Contact', 'Visitador médico').Id;

		return Database.getQueryLocator(
			'SELECT Id, FirstName, LastName, RecordTypeId, OwnerId ' +
			'FROM Contact ' +
			'WHERE RecordTypeId = \'' + recordTypeId + '\''
		);

	}

   	global void execute(Database.BatchableContext contactSearch, List<Contact> scope) {

        
		List<User> usuariosBD = new List<User> ([
				SELECT Id, ContactId, Contact.Id, Contact.FirstName, Contact.LastName, Contact.RecordTypeId, Contact.OwnerId
				FROM User
				WHERE ContactId = :scope AND IsActive = true
		]);

		List<Ciclo__c> ciclo = new List<Ciclo__c>();

		if (usuariosBD.size() > 0) {
					
			for (User usuario : usuariosBD) {

				ciclo.addAll(CycleForContactsHelper.cyclesForContact(usuario.Contact, usuario.Id));

			}
											
		}

		if (ciclo.size() > 0) { 
			insert ciclo;
		}
	
	}
	
	global void finish(Database.BatchableContext contactSearch) {
		
	}
}