@isTest
private class CycleForContactsHelperTest {
	
	public static Id recordTypeId = XappiaHelper.getRecordType('Contact', 'Visitador médico').Id;

	final static Id RT_ACCOUNT_COMMUNITY = Account.getSObjectType()
												.getDescribe()
												.getRecordTypeInfosByDeveloperName()
												.get('Cuenta_community')
												.getRecordTypeId();

	@testSetup
	static void setup() {
		Account cuenta = Build.anAccountCuentacommunity()
								.withName('Xappia1')
								.withEstadoDePaciente('En Seguimiento')
								.withRecordType(RT_ACCOUNT_COMMUNITY)
								.withAreaTerapeutica('Alergia')
            					.withCanalParaConsumidorBaby('Farmacias')
            					.withDNI('123456789')
								.build();
		insert cuenta;
	
		Contact contacto1 = Build.aContactVisitadormedico()
								.withFirstName('Primer')
								.withLastName('Contacto')
								.forAccount(cuenta)
								.build();
		insert contacto1;

		Contact contacto2 = Build.aContactContactodesucursal()
								.withFirstName('Segundo')
								.withLastName('Contacto')
								.forAccount(cuenta)
								.build();
		insert contacto2;

		Contact contacto3 = Build.aContactVisitadormedico()
								.withFirstName('Tercer')
								.withLastName('Contacto')
								.forAccount(cuenta)
								.build();
		insert contacto3;

		Profile perfil = [
			SELECT Id 
			FROM Profile 
			WHERE Name = 'Coordinación médica/enfermería' 
			LIMIT 1
		];

		User usuario1 = Build.aUser()
							.withContactId(contacto1)
							.withUsername(
								'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
							)
							.withLastName('Contacto1')
							.withEmail('contacto1@xappia.com')
							.withAlias('contact1')
							.withTimeZoneSidKey('America/Argentina/Buenos_Aires')
							.withLocaleSidKey('es_AR')
							.withCommunityNickname('prueba1.xappia')
							.withEmailEncodingKey('ISO-8859-1')
							.withProfileId(perfil.Id)
							.withLanguageLocaleKey('es')
							.build();
		insert usuario1; 

		User usuario2 = Build.aUser()
							.withContactId(contacto2)
							.withUsername(
								'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
							)
							.withLastName('Contacto2')
							.withEmail('contacto2@xappia.com')
							.withAlias('contact2')
							.withTimeZoneSidKey('America/Argentina/Buenos_Aires')
							.withLocaleSidKey('es_AR')
							.withCommunityNickname('prueba2.xappia')
							.withEmailEncodingKey('ISO-8859-1')
							.withProfileId(perfil.Id)
							.withLanguageLocaleKey('es')
							.build();
		insert usuario2;

		User usuario3 = Build.aUser()
							.withContactId(contacto3)
							.withUsername(
								'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
							)
							.withLastName('Contacto3')
							.withEmail('contacto3@xappia.com')
							.withAlias('contact3')
							.withTimeZoneSidKey('America/Argentina/Buenos_Aires')
							.withLocaleSidKey('es_AR')
							.withCommunityNickname('prueba3.xappia')
							.withEmailEncodingKey('ISO-8859-1')
							.withProfileId(perfil.Id)
							.withLanguageLocaleKey('es')
							.build();
		insert usuario3;
	}

	@isTest private static void ShouldCreateTheCycleWithTheNameTheMonthConcatenatedWithTheContact() {

		List<User> usuariosBD = [
				SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.RecordTypeId, Contact.OwnerId
				FROM User
				WHERE Contact.RecordTypeId = :recordTypeId
		];

		Test.startTest();
		List<Ciclo__c> cyclesForContact = CycleForContactsHelper.cyclesForContact(usuariosBD[0].contact, usuariosBD[0].Id);
		Test.stopTest();

		Contact Primer = [SELECT Id FROM Contact WHERE FirstName=:'Primer'];
		Contact Segundo = [SELECT Id FROM Contact WHERE FirstName=:'Segundo'];
		Contact Tercer = [SELECT Id FROM Contact WHERE FirstName=:'Tercer'];

		List<Ciclo__c> CicloContacto1 = [
			SELECT Id, ContactId__c, Name, OwnerId, Fecha_de_inicio__c, Fecha_de_fin__c
			FROM Ciclo__c
			WHERE ContactId__c = :Primer.Id
		];

		List<Ciclo__c> CicloContacto2 = [
			SELECT Id, ContactId__c, Name, OwnerId, Fecha_de_inicio__c, Fecha_de_fin__c
			FROM Ciclo__c
			WHERE ContactId__c = :Segundo.Id
		];

		List<Ciclo__c> CicloContacto3 = [
			SELECT Id, ContactId__c, Name, OwnerId, Fecha_de_inicio__c, Fecha_de_fin__c
			FROM Ciclo__c
			WHERE ContactId__c = :Tercer.Id
		];

		System.assertEquals(12, CicloContacto1.size());
		string year = '' + DateTime.now().year();
		System.assertEquals('Enero '+ year +' - Primer Contacto', CicloContacto1[0].Name);
		System.assertEquals('Febrero '+ year +' - Primer Contacto', CicloContacto1[1].Name);
		System.assertEquals('Marzo '+ year +' - Primer Contacto', CicloContacto1[2].Name);
		System.assertEquals('Abril '+ year +' - Primer Contacto', CicloContacto1[3].Name);
		System.assertEquals('Mayo '+ year +' - Primer Contacto', CicloContacto1[4].Name);
		System.assertEquals('Junio '+ year +' - Primer Contacto', CicloContacto1[5].Name);
		System.assertEquals('Julio '+ year +' - Primer Contacto', CicloContacto1[6].Name);
		System.assertEquals('Agosto '+ year +' - Primer Contacto', CicloContacto1[7].Name);
		System.assertEquals('Septiembre '+ year +' - Primer Contacto', CicloContacto1[8].Name);
		System.assertEquals('Octubre '+ year +' - Primer Contacto', CicloContacto1[9].Name);
		System.assertEquals('Noviembre '+ year +' - Primer Contacto', CicloContacto1[10].Name);
		System.assertEquals('Diciembre '+ year +' - Primer Contacto', CicloContacto1[11].Name);

		System.assertEquals(0, CicloContacto2.size());

		System.assertEquals(12, CicloContacto3.size());

		System.assertEquals('Enero '+ year +' - Tercer Contacto', CicloContacto3[0].Name);
		System.assertEquals('Febrero '+ year +' - Tercer Contacto', CicloContacto3[1].Name);
		System.assertEquals('Marzo '+ year +' - Tercer Contacto', CicloContacto3[2].Name);
		System.assertEquals('Abril '+ year +' - Tercer Contacto', CicloContacto3[3].Name);
		System.assertEquals('Mayo '+ year +' - Tercer Contacto', CicloContacto3[4].Name);
		System.assertEquals('Junio '+ year +' - Tercer Contacto', CicloContacto3[5].Name);
		System.assertEquals('Julio '+ year +' - Tercer Contacto', CicloContacto3[6].Name);
		System.assertEquals('Agosto '+ year +' - Tercer Contacto', CicloContacto3[7].Name);
		System.assertEquals('Septiembre '+ year +' - Tercer Contacto', CicloContacto3[8].Name);
		System.assertEquals('Octubre '+ year +' - Tercer Contacto', CicloContacto3[9].Name);
		System.assertEquals('Noviembre '+ year +' - Tercer Contacto', CicloContacto3[10].Name);
		System.assertEquals('Diciembre '+ year +' - Tercer Contacto', CicloContacto3[11].Name);

	}

	@isTest private static void ShouldCreateTheStartAndEndDatesOfEachMonthRespectivelyForEachCycle() {

		List<User> usuariosBD = [
				SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.RecordTypeId, Contact.OwnerId
				FROM User
				WHERE Contact.RecordTypeId = :recordTypeId
		];

		Test.startTest();
		List<Ciclo__c> cyclesForContact = CycleForContactsHelper.cyclesForContact(usuariosBD[0].contact, usuariosBD[0].Id);
		Test.stopTest();

		Contact Primer = [SELECT Id FROM Contact WHERE FirstName=:'Primer'];
		Contact Segundo = [SELECT Id FROM Contact WHERE FirstName=:'Segundo'];
		Contact Tercer = [SELECT Id FROM Contact WHERE FirstName=:'Tercer'];

		List<Ciclo__c> CicloContacto1 = [
			SELECT Id, ContactId__c, Name, OwnerId, Fecha_de_inicio__c, Fecha_de_fin__c
			FROM Ciclo__c
			WHERE ContactId__c = :Primer.Id
		];

		List<Ciclo__c> CicloContacto2 = [
			SELECT Id, ContactId__c, Name, OwnerId, Fecha_de_inicio__c, Fecha_de_fin__c
			FROM Ciclo__c
			WHERE ContactId__c = :Segundo.Id
		];

		List<Ciclo__c> CicloContacto3 = [
			SELECT Id, ContactId__c, Name, OwnerId, Fecha_de_inicio__c, Fecha_de_fin__c
			FROM Ciclo__c
			WHERE ContactId__c = :Tercer.Id
		];
		System.assertEquals(12, CicloContacto1.size());
		integer year = DateTime.now().year();
		System.assertEquals(Date.newInstance(year,01,01), CicloContacto1[0].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,01,31), CicloContacto1[0].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,02,01), CicloContacto1[1].Fecha_de_inicio__c);
		if(Date.isLeapYear(year)){
			System.assertEquals(Date.newInstance(year,02,29), CicloContacto1[1].Fecha_de_fin__c);
		}else{
			System.assertEquals(Date.newInstance(year,02,28), CicloContacto1[1].Fecha_de_fin__c);
		}
		System.assertEquals(Date.newInstance(year,03,01), CicloContacto1[2].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,03,31), CicloContacto1[2].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,04,01), CicloContacto1[3].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,04,30), CicloContacto1[3].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,05,01), CicloContacto1[4].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,05,31), CicloContacto1[4].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,06,01), CicloContacto1[5].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,06,30), CicloContacto1[5].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,07,01), CicloContacto1[6].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,07,31), CicloContacto1[6].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,08,01), CicloContacto1[7].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,08,31), CicloContacto1[7].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,09,01), CicloContacto1[8].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,09,30), CicloContacto1[8].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,10,01), CicloContacto1[9].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,10,31), CicloContacto1[9].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,11,01), CicloContacto1[10].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,11,30), CicloContacto1[10].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,12,01), CicloContacto1[11].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,12,31), CicloContacto1[11].Fecha_de_fin__c);

		System.assertEquals(0, CicloContacto2.size());

		System.assertEquals(Date.newInstance(year,01,01), CicloContacto3[0].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,01,31), CicloContacto3[0].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,02,01), CicloContacto3[1].Fecha_de_inicio__c);
		if(Date.isLeapYear(year)){
			System.assertEquals(Date.newInstance(year,02,29), CicloContacto1[1].Fecha_de_fin__c);
		}else{
			System.assertEquals(Date.newInstance(year,02,28), CicloContacto3[1].Fecha_de_fin__c);
		}
		System.assertEquals(Date.newInstance(year,03,01), CicloContacto3[2].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,03,31), CicloContacto3[2].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,04,01), CicloContacto3[3].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,04,30), CicloContacto3[3].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,05,01), CicloContacto3[4].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,05,31), CicloContacto3[4].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,06,01), CicloContacto3[5].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,06,30), CicloContacto3[5].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,07,01), CicloContacto3[6].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,07,31), CicloContacto3[6].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,08,01), CicloContacto3[7].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,08,31), CicloContacto3[7].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,09,01), CicloContacto3[8].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,09,30), CicloContacto3[8].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,10,01), CicloContacto3[9].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,10,31), CicloContacto3[9].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,11,01), CicloContacto3[10].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,11,30), CicloContacto3[10].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,12,01), CicloContacto3[11].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,12,31), CicloContacto3[11].Fecha_de_fin__c);

	}
    
    @isTest private static void TheMonthsWhichCyclesMustBeCreatedCanBeFiltered() {

		List<User> usuariosBD = [
				SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.RecordTypeId, Contact.OwnerId
				FROM User
				WHERE Contact.RecordTypeId = :recordTypeId
        ];
        Map<String,String>  monthNameMap = new Map<String, String> {
             '1'=>'Enero', '2'=>'Febrero', '3'=>'Marzo', '4'=>'Abril', '5'=>'Mayo', '6'=>'Junio',
                '7'=>'Julio', '8'=>'Agosto', '9'=>'Septiembre','10'=>'Octubre', '11'=>'Noviembre', '12'=>'Diciembre'
               	 };

		Test.startTest();
		List<Ciclo__c> cyclesForContact = CycleForContactsHelper.cyclesForContactWithMonths(usuariosBD[0].contact, usuariosBD[0].Id, monthNameMap);
		Test.stopTest();

		Contact Primer = [SELECT Id FROM Contact WHERE FirstName=:'Primer'];
		Contact Segundo = [SELECT Id FROM Contact WHERE FirstName=:'Segundo'];
		Contact Tercer = [SELECT Id FROM Contact WHERE FirstName=:'Tercer'];

		List<Ciclo__c> CicloContacto1 = [
			SELECT Id, ContactId__c, Name, OwnerId, Fecha_de_inicio__c, Fecha_de_fin__c
			FROM Ciclo__c
			WHERE ContactId__c = :Primer.Id
		];

		List<Ciclo__c> CicloContacto2 = [
			SELECT Id, ContactId__c, Name, OwnerId, Fecha_de_inicio__c, Fecha_de_fin__c
			FROM Ciclo__c
			WHERE ContactId__c = :Segundo.Id
		];

		List<Ciclo__c> CicloContacto3 = [
			SELECT Id, ContactId__c, Name, OwnerId, Fecha_de_inicio__c, Fecha_de_fin__c
			FROM Ciclo__c
			WHERE ContactId__c = :Tercer.Id
		];
    
		System.assertEquals(monthNameMap.size(), CicloContacto1.size());
		integer year = DateTime.now().year();
		System.assertEquals(Date.newInstance(year,03,01), CicloContacto1[2].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,03,31), CicloContacto1[2].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,04,01), CicloContacto1[3].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,04,30), CicloContacto1[3].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,05,01), CicloContacto1[4].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,05,31), CicloContacto1[4].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,06,01), CicloContacto1[5].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,06,30), CicloContacto1[5].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,07,01), CicloContacto1[6].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,07,31), CicloContacto1[6].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,08,01), CicloContacto1[7].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,08,31), CicloContacto1[7].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,09,01), CicloContacto1[8].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,09,30), CicloContacto1[8].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,10,01), CicloContacto1[9].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,10,31), CicloContacto1[9].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,11,01), CicloContacto1[10].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,11,30), CicloContacto1[10].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,12,01), CicloContacto1[11].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,12,31), CicloContacto1[11].Fecha_de_fin__c);

		System.assertEquals(0, CicloContacto2.size());

		System.assertEquals(Date.newInstance(year,03,01), CicloContacto3[2].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,03,31), CicloContacto3[2].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,04,01), CicloContacto3[3].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,04,30), CicloContacto3[3].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,05,01), CicloContacto3[4].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,05,31), CicloContacto3[4].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,06,01), CicloContacto3[5].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,06,30), CicloContacto3[5].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,07,01), CicloContacto3[6].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,07,31), CicloContacto3[6].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,08,01), CicloContacto3[7].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,08,31), CicloContacto3[7].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,09,01), CicloContacto3[8].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,09,30), CicloContacto3[8].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,10,01), CicloContacto3[9].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,10,31), CicloContacto3[9].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,11,01), CicloContacto3[10].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,11,30), CicloContacto3[10].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,12,01), CicloContacto3[11].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,12,31), CicloContacto3[11].Fecha_de_fin__c);

	}

	@isTest private static void ShouldHaveTheOwnersNameTheSameAsTheUser() {

		List<User> usuariosBD = [
				SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.RecordTypeId, Contact.OwnerId
				FROM User
				WHERE Contact.RecordTypeId = :recordTypeId
		];

		Test.startTest();
		List<Ciclo__c> cyclesForContact = CycleForContactsHelper.cyclesForContact(usuariosBD[0].contact, usuariosBD[0].Id);
		Test.stopTest();

		Contact Primer = [SELECT Id FROM Contact WHERE FirstName=:'Primer'];
		Contact Tercer = [SELECT Id FROM Contact WHERE FirstName=:'Tercer'];

		User Usuario1 = [
			SELECT Id, Name, ContactId  
			FROM User
			WHERE ContactId = :Primer.Id
		];

		List<Ciclo__c> CicloContacto1 = [
			SELECT Id, ContactId__c, Name, OwnerId
			FROM Ciclo__c
			WHERE ContactId__c = :Primer.Id
		];

		User Usuario3 = [
			SELECT Id, Name, ContactId  
			FROM User
			WHERE ContactId = :Tercer.Id
		];

		List<Ciclo__c> CicloContacto3 = [
			SELECT Id, ContactId__c, Name, OwnerId
			FROM Ciclo__c
			WHERE ContactId__c = :Tercer.Id
		];

		System.assertEquals(Usuario1.Id, CicloContacto1[0].OwnerId);
		System.assertEquals(Usuario3.Id, CicloContacto3[0].OwnerId);

	}
}