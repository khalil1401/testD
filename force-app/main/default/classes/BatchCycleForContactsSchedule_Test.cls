@isTest
public class BatchCycleForContactsSchedule_Test {
    
   	@isTest
    public static void SetRecurrentSchedule_Success()
    {
        string year = '' + (DateTime.now().year() + 1);
        string cron_exp = '0 0 0 1 1 ? ' + year;
        System.debug(cron_exp);
        
        Test.startTest();
        string jobId = System.schedule('Crear ciclos cada año', cron_exp, new BatchCycleForContactsSchedule());
        List<Ciclo__c> ciclos = [SELECT Id FROM Ciclo__c];
        System.assertEquals(0, ciclos.size(), 'Se crearon ciclos antes de tiempo');
        Test.stopTest();
        
        ciclos = [SELECT Id FROM Ciclo__c];
        System.assertNotEquals(0, ciclos.size(), 'No se crearon');
        
    }
	
    static Account cuenta;
	static Contact contacto1, contacto2, contacto3;
	static user usuario1, usuario2, usuario3;

	static {

		cuenta = Build.anAccountCuentacommunity()
			.withName('Xappia1')
            .withCanalParaConsumidorBaby('Farmacias')
            .withDNI('123456')
			.build();
		insert cuenta;
	
		contacto1 = Build.aContactVisitadormedico()
			.withFirstName('Primer')
			.withLastName('Contacto')
			.forAccount(cuenta)
			.build();
		insert contacto1;

		contacto2 = Build.aContactContactodesucursal()
			.withFirstName('Segundo')
			.withLastName('Contacto')
			.forAccount(cuenta)
			.build();
		insert contacto2;

		contacto3 = Build.aContactVisitadormedico()
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

		usuario1 = Build.aUser()
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

		usuario2 = Build.aUser()
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

		usuario3 = Build.aUser()
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
}