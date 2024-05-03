@isTest
public class CycleTriggerTest  {

	@IsTest private static void ShouldCompleteTheFieldWithTheWorkingDaysOfTheMonthCorrespondingToTheCycle() {
		
		Ciclo__c ciclo = Build.aCiclo()
			.withName('New Ciclo')
			.withFechaDeInicio(Date.newInstance(2018,01,01))
			.withFechaDeFin(Date.newInstance(2018,01,31))
			.build();

		Test.startTest();
		insert ciclo;
		Test.stopTest();

		List<Ciclo__c> cicloBD = [
			SELECT Id, Name, Cantidad_de_dias_en_el_mes__c, Cantidad_de_dias_habiles__c 
			FROM Ciclo__c
			WHERE Id = :ciclo.Id
		];

		System.assertEquals(23, cicloBD[0].Cantidad_de_dias_habiles__c);

	}

	@IsTest private static void ShouldCompleteTheFieldWithTheWorkDaysOfTheMonthCorrespondingToTheRestartHolidaysCycle() {

		Feriado__c feriado1 = Build.aFeriado()
			.withFecha(Date.newInstance(2018,05,01))
			.build();
		insert feriado1;

		Feriado__c feriado2 = Build.aFeriado()
			.withFecha(Date.newInstance(2018,05,12))
			.build();
		insert feriado2;

		Feriado__c feriado3 = Build.aFeriado()
			.withFecha(Date.newInstance(2018,05,25))
			.build();
		insert feriado3;

		Feriado__c feriado4 = Build.aFeriado()
			.withFecha(Date.newInstance(2018,03,15))
			.build();
		insert feriado4;
        
        Contact contactTest = Build.aContact()
            .withLastName('Test')
            .withFirstName('Contact')
            .Build();
        
        insert contactTest;
        
		Ciclo__c ciclo = Build.aCiclo()
			.withName('New Ciclo')
			.withFechaDeInicio(Date.newInstance(2018,05,01))
			.withFechaDeFin(Date.newInstance(2018,05,31))
			.build();
			ciclo.ContactId__c =contactTest.id;
        
		Test.startTest();
		insert ciclo;
		Test.stopTest();

		List<Ciclo__c> cicloBD = [
			SELECT Id, Name, Cantidad_de_dias_en_el_mes__c, Cantidad_de_dias_habiles__c 
			FROM Ciclo__c
			WHERE Id = :ciclo.Id
		];

		System.assertEquals(21, cicloBD[0].Cantidad_de_dias_habiles__c);

	}

	@IsTest 
    private static void autoCompleteCycleName() {
        
		Contact contactTest = Build.aContact()
            .withLastName('Test')
            .withFirstName('Contact')
            .Build();
        
        insert contactTest;
        
		Ciclo__c ciclo = Build.aCiclo()
			.withName('New Ciclo')
			.withFechaDeInicio(Date.newInstance(2018,05,01))
			.withFechaDeFin(Date.newInstance(2018,05,31))
			.build();
			ciclo.ContactId__c =contactTest.id;

		Test.startTest();
        insert ciclo;
		Test.stopTest();

		Ciclo__c cicloBD = [
			SELECT Id, Name,createdDate 
			FROM Ciclo__c
			WHERE Id = :ciclo.Id
			LIMIT 1
        ];
        DateTime fecha = cicloBD.createdDate;
        String nombreDelMes = fecha.format('MMMMM');
        String yearName = fecha.format('YYYY');
         
		System.assertEquals(nombreDelMes+' - '+yearName+' - '+'Contact Test',cicloBD.name);

	}

}