@isTest public class InteractionTriggerTest  {
	@isTest public static void siHoyEsFeriadoNoPuedoCrearVisitaMedica(){
		Account anAccount = Build.anAccountProfesionaldelasalud()
		    .withLastName('Perez')
			.build();
		insert anAccount;

		Feriado__c feriado = Build.aFeriado()
			.withFecha(Date.newInstance(2018, 7, 9))
			.build();
		insert feriado;

	    Date today = System.today();
		Ciclo__c ciclo = Build.aCiclo()
		    .withFechaDeInicio(today.addDays(-20))
			.withFechaDeFin(today.addDays(20))
			.build();
		insert ciclo;
		Interaccion__c visitaMedica = Build.aInteraccion()
			.withFecha(Date.newInstance(2018, 7, 9))  // 9 de Julio
			.withTipoDeVisita('Presencial')
			.withCiclo(ciclo)
			.withProfesionalDeLaSalud(anAccount.Id)
			.build();
	
		Test.startTest();
		Boolean res;
		try{
			insert visitaMedica;
			res = true;
		}
		catch(DmlException e){
			System.debug(e.getMessage());
			res = false;
		}
		Test.stopTest();
		
		System.assertEquals(false, res);
	}

	@isTest public static void siHoyEsFinDeSemanaNoPuedoCrearVisitaMedica(){
		Account anAccount = Build.anAccountProfesionaldelasalud()
			.withLastName('Perez')
			.build();
		insert anAccount;

	    Date today = System.today();
		Ciclo__c ciclo = Build.aCiclo()
			.withFechaDeInicio(today.addDays(-20))
			.withFechaDeFin(today.addDays(20))
			.build();
		insert ciclo;
		Interaccion__c visitaMedica = Build.aInteraccion()
			.withTipoDeVisita('Presencial')
			.withCiclo(ciclo)
			.withProfesionalDeLaSalud(anAccount.Id)
			.withFecha(Date.newInstance(2018, 7, 29))		// Domingo
			.build();
	
		Test.startTest();
		Boolean res;
		try{
			insert visitaMedica;
			res = true;
		}
		catch(DmlException e){
			System.debug(e.getMessage());
			res = false;
		}
		Test.stopTest();
		
		System.assertEquals(false, res);
	}

	@isTest public static void siNoSeSeleccionaUnaFechaNoSePuedeCrearVisitaMedica(){
		Account anAccount = Build.anAccountProfesionaldelasalud()
			.withLastName('Perez')
			.build();
		insert anAccount;

	    Date today = System.today();
		Ciclo__c ciclo = Build.aCiclo()
			.withFechaDeInicio(today.addDays(-20))
			.withFechaDeFin(today.addDays(20))
			.build();
		insert ciclo;
		Interaccion__c visitaMedica = Build.aInteraccion()
			.withTipoDeVisita('Presencial')
			.withCiclo(ciclo)
			.withProfesionalDeLaSalud(anAccount.Id)
			.withFecha(null)
			.build();
        //Debido a que la fecha ya tiene un valor por default, para que el test tenga sentido, debo forzar a que el usuario no setee la fecha intencionalmente.
        
		Test.startTest();
		Boolean res;
		try{
			insert visitaMedica;
			res = true;
		}
		catch(DmlException e){
			System.debug(e.getMessage());
			res = false;
		}
		Test.stopTest();
		
		System.assertEquals(false, res);
	}
}