@isTest 
private class DiasHabilesTranscurridosHelperTest {
	public static Ciclo__c cicloGenerator() // Depende del dia de hoy
	{
		
		Ciclo__c ciclo = Build.aCiclo().
						 withFechaDeInicio(Date.newInstance(System.today().year(),
															System.today().month(),
															1)).
						 withFechaDeFin(Date.newInstance(System.today().year(),
														 System.today().month(), 
														 Date.daysInMonth(System.today().year(), System.today().month())))
						 .build();
		insert ciclo;
		Licencia__c licencia = Build.aLicencia().withCiclo(ciclo).withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month(),System.today().day())).withFechaDeFin(Date.newInstance(System.today().year(),System.today().month(),System.today().day()).addDays(1)).build();
		insert licencia;
		return ciclo;
	}
	public static Decimal diasTranscurridos(Ciclo__c ciclo, List<Licencia__c> licencias, List<Feriado__c> feriadosMock)
	{
		
		Date fechaFin = ciclo.Fecha_de_fin__c < System.today() ? ciclo.Fecha_de_fin__c : System.today();
		Decimal diasNoHabiles = CycleTriggerHelper.cantidadDeDiasNoHabiles(ciclo.Fecha_de_inicio__c, fechaFin, feriadosMock);
		Decimal diasDeLicencia = DiasHabilesTranscurridosHelper.calcularDiasDeLicenciaTranscurridos(licencias, feriadosMock);
		Decimal totalDias = System.today().day() - ciclo.Fecha_de_inicio__c.day() + 1;
		Decimal diasTranscurridos = totalDias - (diasNoHabiles + diasDeLicencia);
		return diasTranscurridos;
	}
	public static List<Ciclo__c> getAllCycles()
	{
		return [SELECT Id, Cantidad_de_dias_habiles__c, Dias_de_campo_efectivo_transcurridos__c,
						Fecha_de_inicio__c, Fecha_de_fin__c, Cantidad_de_dias_en_el_mes__c, Actualizar__c,
						(SELECT Id,Cantidad_de_dias__C,Aprobado__c,
						Fecha_de_inicio__c,Fecha_de_fin__c, Dia_decimal__c 
						FROM Licencias__r) 
						FROM Ciclo__c];
	}
	@isTest
	private static void EnviarCicloLicencias_CalcularDiasTranscurridos() {
		
		List<Feriado__c> feriadosMock = [SELECT Id FROM Feriado__c];
		Ciclo__c ciclo = cicloGenerator();
		Licencia__c lic = [SELECT Id, Aprobado__c FROM Licencia__c];
		lic.Aprobado__c = true;
		update lic;

		Test.startTest();
		update DiasHabilesTranscurridosHelper.calcularDiasHabilesTranscurridos(getAllCycles());
		Test.stopTest();

		ciclo = getAllCycles()[0];
		
		List<Licencia__c> licencias = [
			SELECT Id, Cantidad_de_dias__c, fecha_de_inicio__c, fecha_de_fin__c, Aprobado__c, Ciclo__c 
			FROM Licencia__c
			];
		
		System.assertEquals(diasTranscurridos(ciclo, licencias, feriadosMock), 
		                    ciclo.Dias_de_campo_efectivo_transcurridos__c, 'Incorrecto');
	}
	@isTest 
	private static void EnviarCicloNoIniciado_NoCalcularNada() { 
		
		Ciclo__c ciclo = Build.aCiclo().
						 withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month() + 1,1)).
						 withFechaDeFin(Date.newInstance(System.today().year(),System.today().month() + 1, 
						                                 Date.daysInMonth(System.today().year(), System.today().month()+1))).
						 build();

		insert ciclo;
		
		Licencia__c licencia = Build.aLicencia().withCiclo(ciclo).
							   withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month() + 1,20)).
							   withFechaDeFin(Date.newInstance(System.today().year(),System.today().month() + 1, 25)).
							   build();
		insert licencia;
		List<Feriado__c> feriados = [SELECT Id, Fecha__c FROM Feriado__c];
		licencia.Aprobado__c = true;
		update licencia;
		Test.startTest();

		List<Ciclo__c> ciclos = DiasHabilesTranscurridosHelper.calcularDiasHabilesTranscurridos(getAllCycles());
		if(ciclos != null)
			update ciclos;
		Test.stopTest();

		ciclo = getAllCycles()[0];
						
		List<Licencia__c> licencias = [
			SELECT Id, Cantidad_de_dias__c, fecha_de_inicio__c, fecha_de_fin__c, Ciclo__c 
			FROM Licencia__c
			];
		
		System.assertEquals(null, ciclo.Dias_de_campo_efectivo_transcurridos__c, 'Incorrecto');
	}
	@isTest
	private static void EnviarCicloDiciembreActual_CalcularDiasTranscurridosAnteriormente() { // Tiene 2 feriados
        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);  
        
		Ciclo__c ciclo = Build.aCiclo().
						 withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month(),firstDayOfMonth.day())).
						 withFechaDeFin(Date.newInstance(System.today().year(),System.today().month(),lastDayOfMonth.day())).build();
		insert ciclo;
		Ciclo__c ciclo2 = Build.aCiclo().
						 withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month(),firstDayOfMonth.day())).
						 withFechaDeFin(Date.newInstance(System.today().year(),System.today().month(),lastDayOfMonth.day())).build();
        
		insert ciclo2;
		Licencia__c licencia = Build.aLicencia().withCiclo(ciclo).
							   withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month(),System.today().day())).
							   withFechaDeFin(Date.newInstance(System.today().year(),System.today().month(),System.today().day()).addDays(1)).build();
		insert licencia;
		Licencia__c licencia2 = Build.aLicencia().withCiclo(ciclo2).
							   withFechaDeInicio(Date.newInstance(System.today().year(),System.today().month(),System.today().day())).
							   withFechaDeFin(Date.newInstance(System.today().year(),System.today().month(),System.today().day())).
							   withDuracionDeLicencia('1/2 día').build();

		
		insert licencia2;
		Feriado__c feriado1 = Build.aFeriado().withFecha(Date.newInstance(System.today().year(),System.today().month(),System.today().day()).addDays(1)).build();
		insert feriado1;
		Feriado__c feriado2 = Build.aFeriado().withFecha(Date.newInstance(System.today().year(),System.today().month(),System.today().day()).addDays(2)).build();
		insert feriado2;
		licencia.Aprobado__c = true;
		update licencia;
		licencia2.Aprobado__c = true;
		update licencia2;
		List<Feriado__c> feriados = [SELECT Id, Fecha__c FROM Feriado__c];
		Test.startTest();
	
		update DiasHabilesTranscurridosHelper.calcularDiasHabilesTranscurridos(getAllCycles());
		Test.stopTest();

		ciclo = getAllCycles()[0];
		ciclo2 = getAllCycles()[1];
        
        Date primerDia = Date.newInstance(System.today().year(),System.today().month(),1);
        Date diasDesdeInicioDelMes = primerDia.addDays((integer)ciclo.Dias_de_campo_efectivo_transcurridos__c);
        integer cantidadDeDias = diasDesdeInicioDelMes.day();
        
        Date primerDiaCiclo2 = Date.newInstance(System.today().year(),System.today().month(),1);
        Date diasDesdeInicioDelMesCiclo2 = primerDiaCiclo2.addDays((integer)ciclo2.Dias_de_campo_efectivo_transcurridos__c);
        integer cantidadDeDiasCiclo2 = diasDesdeInicioDelMesCiclo2.day();
                                   
		System.assertEquals(cantidadDeDias-1, ciclo.Dias_de_campo_efectivo_transcurridos__c, 'Incorrecto');
		System.assertEquals(cantidadDeDiasCiclo2-0.5, ciclo2.Dias_de_campo_efectivo_transcurridos__c, 'Incorrecto');
	}
	@isTest
	private static void Enviar2CiclosLicencias_CalcularDiasTranscurridos() {
		
		Feriado__c feriado1 = Build.aFeriado().
		                      withFecha(Date.newInstance(System.today().year(),System.today().month(),1)).
							  build();
		insert feriado1;
		Feriado__c feriado2 = Build.aFeriado().
							  withFecha(Date.newInstance(System.today().year(),System.today().month(),2)).
							  build();
		insert feriado2;
		cicloGenerator();
		cicloGenerator();
		List<Licencia__c> lic = [SELECT Id, Aprobado__c FROM Licencia__c];
		for(Licencia__c l : lic)
			l.Aprobado__c = true;
		update lic;
		List<Feriado__c> feriados = [SELECT Id, Fecha__c FROM Feriado__c];
		Test.startTest();
		
		
		update DiasHabilesTranscurridosHelper.calcularDiasHabilesTranscurridos(getAllCycles());
		Test.stopTest();

		List<Ciclo__c> ciclo = getAllCycles();
		List<Feriado__c> feriadosMock = [SELECT Id, Fecha__c FROM Feriado__c];
		
		for(Ciclo__c c : ciclo)
		{
			List<Licencia__c> licencias = [
					SELECT Id, Cantidad_de_dias__c, fecha_de_inicio__c, fecha_de_fin__c, Aprobado__c, Ciclo__c 
					FROM Licencia__c WHERE Ciclo__c = :c.Id
					];
			System.assertEquals(diasTranscurridos(c, licencias, feriadosMock), 
								c.Dias_de_campo_efectivo_transcurridos__c, 'Incorrecto');
		}
	}
	@isTest
	private static void ProgramarActualizacion_CalcularDiasTranscurridos() {
		
		Feriado__c feriado1 = Build.aFeriado().
		                      withFecha(Date.newInstance(System.today().year(),System.today().month(),1)).
							  build();
		insert feriado1;
		Feriado__c feriado2 = Build.aFeriado().
							  withFecha(Date.newInstance(System.today().year(),System.today().month(),2)).
							  build();
		insert feriado2;
		cicloGenerator();
		cicloGenerator();
		List<Licencia__c> lic = [SELECT Id, Aprobado__c FROM Licencia__c];
		for(Licencia__c l : lic)
			l.Aprobado__c = true;
		update lic;
		Test.startTest();
		
		BatchUpdateCycles upCiclos = new BatchUpdateCycles();
		Id batchId = Database.executeBatch(upCiclos);

		Test.stopTest();

		List<Ciclo__c> ciclo = getAllCycles();
		List<Feriado__c> feriadosMock = [SELECT Id, Fecha__c FROM Feriado__c];
		
		for(Ciclo__c c : ciclo)
		{
			List<Licencia__c> licencias = [
					SELECT Id, Cantidad_de_dias__c, fecha_de_inicio__c, fecha_de_fin__c, Aprobado__c, Ciclo__c 
					FROM Licencia__c WHERE Ciclo__c = :c.Id
					];
			System.assertEquals(diasTranscurridos(c, licencias, feriadosMock), 
								c.Dias_de_campo_efectivo_transcurridos__c, 'Incorrecto');
		}
	}
	public static testMethod void ProgramoTrabajos_QuedanCargadosSinRepetirse() 
	{
		Feriado__c feriado1 = Build.aFeriado().
		                      withFecha(Date.newInstance(System.today().year(),System.today().month(),1)).
							  build();
		insert feriado1;
		Feriado__c feriado2 = Build.aFeriado().
							  withFecha(Date.newInstance(System.today().year(),System.today().month(),2)).
							  build();
		insert feriado2;
		cicloGenerator();
		cicloGenerator();
		List<Licencia__c> lic = [SELECT Id, Aprobado__c FROM Licencia__c];
		for(Licencia__c l : lic)
			l.Aprobado__c = true;
		update lic;

		Test.StartTest();
		string cron_exp = '0 '+ '0'+' '+ '0' +' ' + (System.now().day()+1) + ' ' + System.now().month() + ' ? ' + System.now().year();
        BatchUpdateCycleEveryDay sch = new BatchUpdateCycleEveryDay();
		string jobId = System.schedule('Actualizar ciclos arranque - Test' , cron_exp, sch);
		Test.stopTest(); 
		

		List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
		System.debug(jobsScheduled);
		System.assertEquals(1, jobsScheduled.size(), 'Tiene que haber 1 trabajo programado');
		List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
		System.assertEquals(1, jobsApexBatch.size(), 'Tiene que haber 1 batch programado');

	}
}