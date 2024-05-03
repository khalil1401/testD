public class TecnovozCommunicatorCtrl {
    //se usa para executar javascript en la pagina
    public String callfunc { get; set; }    
    public Event currentCall;    
    public String phoneNumber { get; set; }
    
    public String opennedTabPhoneNumber {get; set;}
    public String opennedClientName { get; set; }

	public String newContactType {get;set;}
    public String newContactLastName {get; set;}
	public List<SelectOption> getRecordTypes() {
		List<SelectOption> selectOptions = new List<SelectOption>();
		selectOptions.add(new SelectOption(RecordTypes.Account_PacienteBestCare, 'Paciente best care'));
		selectOptions.add(new SelectOption(RecordTypes.Account_PacienteRegular, 'Paciente regular'));
		selectOptions.add(new SelectOption(RecordTypes.Contact_Contactodepaciente, 'Contacto de paciente'));
		return selectOptions;
	}
	    
    //se ejecuta atravez de javascript en momento de empezar llamada
    public PageReference CallBegin() {
        //recibimos la informacion de la llamada atravez de la pagina
        phoneNumber = ApexPages.currentPage().getParameters().get('phoneNumber');
		if (phoneNumber.startsWith('11')) {
			phoneNumber = phoneNumber.replaceFirst('11', '15');
		}
        String callId = ApexPages.currentPage().getParameters().get('callId');
        String direction = ApexPages.currentPage().getParameters().get('direction');
        String dde = ApexPages.currentPage().getParameters().get('dde');
        
        currentCall = new Event();
        currentCall.ActivityDateTime = System.now();
        currentCall.dde__c = dde;
        currentCall.External_Id__c = callId;
        currentCall.Type = 'Call';
        currentCall.DurationInMinutes = 0;
        

        if (direction == '1') {
            currentCall.Subject = 'Llamada entrante';
		}
        else if (direction == '2') {
            currentCall.Subject = 'Llamada saliente';
		}

        //intentamos asignar llamada a algun cliente
		if (String.isNotBlank(phoneNumber) && !AsignCallToClient(currentCall, phoneNumber)) {
            //actualizmos view
            JavaScriptCommand('SetStatus("Cliente no registrado"); showCreateRecordMenu();');
        }

        insert currentCall;
        return null;
    }
    
	//asigna la llamada al cliente con mismo numero con caso no cerrado mas reciente; si no hay tal cliente entonces
	//al cliente mas reciente. Devuelve true si pudo asignar a alguien
	private static Id findIdOfRecordWithPhone(String phoneNumber) {
		
		List<Contact> contacts = [
			SELECT Id
			FROM Contact
			WHERE Phone = :phoneNumber
				OR MobilePhone = :phoneNumber
		];
		if (!contacts.isEmpty()) {
			return contacts[0].Id;
		}

		List<Account> accs = [
			SELECT Id, PersonContactId
			FROM Account 
			WHERE phone = :phoneNumber
				OR PersonMobilePhone = :phoneNumber
		];

		if (!accs.isEmpty()) {
			return accs[0].PersonContactId;
		}
		
		return null;
	}

    public boolean AsignCallToClient(Event call, String phoneNumber) {
		String recordId = findIdOfRecordWithPhone(phoneNumber);		
		String commands = '';
        if (recordId != null) {
			commands = 'sforce.console.openPrimaryTab(null, "/' + recordId + '", true,"",' + phoneNumber + ',"");';				
			commands += 'sforce.console.focusPrimaryTabByName("'+phoneNumber+'");';
            commands += 'sforce.console.refreshPrimaryTabByName("'+phoneNumber+'",false);';
			call.WhoId = recordId;
			JavaScriptCommand(commands);
			return true;
        } else {
			return false;
		}
    }
    //se ejecuta atravez de javascript en momento de finalizar llamada
    //asigna informacion al evento y lo actualiza
    public PageReference CallEnd() {
        if (currentCall != null) {
            string logData = ApexPages.currentPage().getParameters().get('LogData');
            integer minutes = (integer)(System.now().getTime() - currentCall.ActivityDateTime.getTime()) / (1000 * 60);

            currentCall.EndDateTime = System.now();
            currentCall.DurationInMinutes = minutes;
            currentCall.Description = logData;

            update currentCall;            
        }
        JavaScriptCommand('');
        return null;
    }

	//se usa para executar javascript desde apex controller
    public void JavaScriptCommand(string s) {
        callfunc = s;
    }

    //crea un nuevo contacto y le asigna llamada
    public void CreateContact() {		
		if (String.isNotBlank(newContactLastName)) {
			RecordType rt = XappiaHelper.getRecordType(newContactType);
			if (newContactType == RecordTypes.Contact_Contactodepaciente) {
				Contact c = new Contact();
				c.LastName = newContactLastName;
				c.RecordTypeId = rt.Id;
				c.MobilePhone = phoneNumber;
				insert c;
				currentCall.WhoId = c.Id;
			} else {
				Account newClient = new Account();
				newClient.LastName = newContactLastName;
				newClient.Phone = phoneNumber;
				newClient.RecordTypeId = rt.Id;
				insert newClient;
				Id personContactId = [SELECT PersonContactId From Account WHERE id = :newClient.Id].personContactId;
				currentCall.WhoId = personContactId;
			}		
			System.debug(newContactLastName);
			System.debug(currentCall);
			System.debug(currentCall.WhoId);
			update currentCall;
			//abre ficha del nuevo contacto creado, actualiza estado del view        
			JavaScriptCommand('sforce.console.openPrimaryTab(null, "/' + currentCall.WhoId + '/e", true, "' + newContactLastName + '");' +
				+ 'SetStatus("Registremos nuevo cliente"); hideCreateRecordMenu();');
		} else {
			JavaScriptCommand('alert("El campo apellido es obligatorio!");');
		}
    }

	public void TabOpenned() {        
		String TabObjectId = ApexPages.currentPage().getParameters().get('objectId');        
		opennedClientName = '';
		opennedTabPhoneNumber = '';

		List<Account> clients = [
			SELECT Id, Name, phone, personMobilePhone
            FROM Account 
			WHERE id = :TabObjectId
				AND (Phone != null OR PersonMobilePhone != null)
		];
		if (clients.size() > 0) {
			opennedClientName = clients[0].Name;
			if (clients[0].PersonMobilePhone != null) {
				opennedTabPhoneNumber = clients[0].PersonMobilePhone;
			} else {
				opennedTabPhoneNumber = clients[0].Phone;
			}
		} else {
			List<Contact> contacts = [
				SELECT Id, Phone, LastName
				FROM Contact
				WHERE id = :TabObjectId
					AND Phone != null
			];
			if (contacts.size() > 0) {
				opennedClientName = contacts[0].LastName;
				opennedTabPhoneNumber = contacts[0].Phone;
			}
		}

		if (opennedTabPhoneNumber != '') {
			JavaScriptCommand(
				'OpennedClientPhone='+opennedTabPhoneNumber+';'+
                'ShowCallMenu();'
            );
		} else {
         	JavaScriptCommand(
            	'HideCallMenu();'+
                'OpennedClientPhone="";'
            );
        }
    }    	        
    
}