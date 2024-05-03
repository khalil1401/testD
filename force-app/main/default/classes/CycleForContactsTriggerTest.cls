@isTest
public class CycleForContactsTriggerTest  {

	@isTest
	private static void ShouldCreateCyclesToContactWithMedicalVisitorUserIfCreatedAfterJanuaryFirst() {

		Account cuenta = Build.anAccountCuentacommunity()
			.withName('Xappia1')
			.withEstadoDePaciente('En seguimiento')
			.withAreaTerapeutica('Alergia')
			.build();
		insert cuenta;
		
		Contact contacto4 = Build.aContactVisitadormedico()
			   .withFirstName('Cuarto')
			   .withLastName('Contacto')
			   .forAccount(cuenta)
			   .build();
		insert contacto4;
        
		Profile perfil = [
			SELECT Id 
			FROM Profile 
			WHERE Name = 'Coordinación médica/enfermería' 
			LIMIT 1
		];
        
		User usuario4 = Build.aUser()
			.withContactId(contacto4)
			.withUsername(
				'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
			)
			.withLastName('Contacto4')
			.withEmail('contacto4@xappia.com')
			.withAlias('contact4')
			.withTimeZoneSidKey('America/Argentina/Buenos_Aires')
			.withLocaleSidKey('es_AR')
			.withCommunityNickname('prueba4.xappia')
			.withEmailEncodingKey('ISO-8859-1')
			.withProfileId(perfil.Id)
			.withLanguageLocaleKey('es')
			.build();
		
		Test.startTest();
		insert usuario4;
		Test.stopTest();

		List<Ciclo__c> CicloContacto4 = [
			SELECT Id, ContactId__c, Name, OwnerId, Fecha_de_inicio__c, Fecha_de_fin__c
			FROM Ciclo__c
			WHERE ContactId__c = :contacto4.Id
		];

		System.assertEquals(12, CicloContacto4.size());
		
		integer year = DateTime.now().year();
		System.assertEquals('Enero '+ year +' - Cuarto Contacto', CicloContacto4[0].Name);
		System.assertEquals('Febrero '+ year +' - Cuarto Contacto', CicloContacto4[1].Name);
		System.assertEquals('Marzo '+ year +' - Cuarto Contacto', CicloContacto4[2].Name);
		System.assertEquals('Abril '+ year +' - Cuarto Contacto', CicloContacto4[3].Name);
		System.assertEquals('Mayo '+ year +' - Cuarto Contacto', CicloContacto4[4].Name);
		System.assertEquals('Junio '+ year +' - Cuarto Contacto', CicloContacto4[5].Name);
		System.assertEquals('Julio '+ year +' - Cuarto Contacto', CicloContacto4[6].Name);
		System.assertEquals('Agosto '+ year +' - Cuarto Contacto', CicloContacto4[7].Name);
		System.assertEquals('Septiembre '+ year +' - Cuarto Contacto', CicloContacto4[8].Name);
		System.assertEquals('Octubre '+ year +' - Cuarto Contacto', CicloContacto4[9].Name);
		System.assertEquals('Noviembre '+ year +' - Cuarto Contacto', CicloContacto4[10].Name);
		System.assertEquals('Diciembre '+ year +' - Cuarto Contacto', CicloContacto4[11].Name);

		System.assertEquals(Date.newInstance(year,01,01), CicloContacto4[0].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,01,31), CicloContacto4[0].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,02,01), CicloContacto4[1].Fecha_de_inicio__c);
		if(Date.isLeapYear(year)){
			System.assertEquals(Date.newInstance(year,02,29), CicloContacto4[1].Fecha_de_fin__c);
		}else{
			System.assertEquals(Date.newInstance(year,02,28), CicloContacto4[1].Fecha_de_fin__c);
		}
		System.assertEquals(Date.newInstance(year,03,01), CicloContacto4[2].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,03,31), CicloContacto4[2].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,04,01), CicloContacto4[3].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,04,30), CicloContacto4[3].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,05,01), CicloContacto4[4].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,05,31), CicloContacto4[4].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,06,01), CicloContacto4[5].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,06,30), CicloContacto4[5].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,07,01), CicloContacto4[6].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,07,31), CicloContacto4[6].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,08,01), CicloContacto4[7].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,08,31), CicloContacto4[7].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,09,01), CicloContacto4[8].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,09,30), CicloContacto4[8].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,10,01), CicloContacto4[9].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,10,31), CicloContacto4[9].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,11,01), CicloContacto4[10].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,11,30), CicloContacto4[10].Fecha_de_fin__c);
		System.assertEquals(Date.newInstance(year,12,01), CicloContacto4[11].Fecha_de_inicio__c);
		System.assertEquals(Date.newInstance(year,12,31), CicloContacto4[11].Fecha_de_fin__c);

		System.assertEquals(Usuario4.Id, CicloContacto4[0].OwnerId);

	}

}