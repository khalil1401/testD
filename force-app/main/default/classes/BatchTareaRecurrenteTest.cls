@isTest 
public class BatchTareaRecurrenteTest  {

    @isTest
    Public static void crearTareaLlamadoDeSeguimientoUnDiaAntesDeLosTresMesesDespuesDeLaFechaDelCampoUltimoLlamadoDeSeguimientoDeLaCuentaBestCare(){
        
		pacienteTest1.Ultimo_llamado_de_seguimiento__c = hace3Meses;
		update pacienteTest1;
		
        Test.startTest();
		BatchTareaRecurrente batch = new BatchTareaRecurrente();
        database.executeBatch(batch, 200); 
		Test.stopTest();
        
        List<Task> tareaRecurrente = [
			SELECT Id, RecordTypeId, Subject,
			WhatId, Priority, Status, ActivityDate
			FROM Task
			WHERE RecordType.DeveloperName = 'Llamado_de_seguimiento'
		];

		Account cuenta = [
			SELECT Ultimo_llamado_de_seguimiento__c 
			FROM Account 
			WHERE Id = :pacienteTest1.Id 
			LIMIT 1
		];

		System.assertEquals(1, tareaRecurrente.size());
		System.assertEquals(llamadaSeguimiento.Id, tareaRecurrente[0].RecordTypeId);
		System.assertEquals('Llamado de seguimiento', tareaRecurrente[0].Subject);
		System.assertEquals(pacienteTest1.Id, tareaRecurrente[0].WhatId);
		System.assertEquals('Normal', tareaRecurrente[0].Priority);
		System.assertEquals('Abierta', tareaRecurrente[0].Status);
		System.assertEquals(cuenta.Ultimo_llamado_de_seguimiento__c.addMonths(3), tareaRecurrente[0].ActivityDate);
    }
    
	@isTest
    Public static void crearTareaLlamadoDeSeguimientoUnDiaAntesYTresMesesDespuesDeLaFechaDeCreacionDeLaCuentaBestCare(){

		Test.setCreatedDate(pacienteTest1.Id, hace3Meses);
        Test.startTest();
		BatchTareaRecurrente batch = new BatchTareaRecurrente();
        database.executeBatch(batch, 200); 
		Test.stopTest();
        
        List<Task> tareaRecurrente = [
			SELECT Id, RecordTypeId, Subject, 
			WhatId, Priority, Status, ActivityDate
			FROM Task
			WHERE RecordType.DeveloperName = 'Llamado_de_seguimiento'
		];

		Account cuenta = [
			SELECT CreatedDate 
			FROM Account 
			WHERE Id = :pacienteTest1.Id 
			LIMIT 1
		];

		System.assertEquals(1, tareaRecurrente.size());
		System.assertEquals(llamadaSeguimiento.Id, tareaRecurrente[0].RecordTypeId);
		System.assertEquals('Llamado de seguimiento', tareaRecurrente[0].Subject);
		System.assertEquals(pacienteTest1.Id, tareaRecurrente[0].WhatId);
		System.assertEquals('Normal', tareaRecurrente[0].Priority);
		System.assertEquals('Abierta', tareaRecurrente[0].Status);
		System.assertEquals(cuenta.CreatedDate.dateGmt().addMonths(3), tareaRecurrente[0].ActivityDate);

    }

	@isTest
    Public static void noCreaTareaLlamadoDeseguimientoSiNoTieneTresMesesDespuesDeLaFechaDelCampoUltimoLlamadoDeSeguimientoDeLaCuentaBestCare(){
        
        Test.startTest();
		BatchTareaRecurrente batch = new BatchTareaRecurrente();
        database.executeBatch(batch, 200); 
		Test.stopTest();
        
        List<Task> tareaRecurrente = [
			SELECT Id, RecordTypeId, Subject, WhatId,Priority,Status
			FROM Task
			WHERE RecordType.DeveloperName = 'Llamado_de_seguimiento'
		];
		System.assertEquals(0, tareaRecurrente.size());
    }

	@isTest
    Public static void noCreaTareaLlamadoDeseguimientoSiNoTieneTresMesesDespuesDeLafechaDeCreacionDeLaCuentaBestCare(){
        
        Test.startTest();
		BatchTareaRecurrente batch = new BatchTareaRecurrente();
        database.executeBatch(batch, 200); 
		Test.stopTest();
        
        List<Task> tareaRecurrente = [
			SELECT Id, RecordTypeId, Subject, WhatId,Priority,Status
			FROM Task
			WHERE RecordType.DeveloperName = 'Llamado_de_seguimiento'
		];
		System.assertEquals(0, tareaRecurrente.size());
    }

	static Account pacienteTest1;
	static task tareaTest;
	static Date hoy, hace3Meses;
	static RecordType llamadaSeguimiento;

	static {

		llamadaSeguimiento = [
			SELECT Id, Name 
			FROM RecordType 
			WHERE SobjectType = 'Task' 
				AND Name = 'Llamado de seguimiento'
		];

		hoy = Date.today();
		hace3Meses = Date.today().addMonths(-3).addDays(1);

		pacienteTest1 = Build.anAccountPacienteBestCare()
			.withLastName('Paciente')
			.build();
		insert pacienteTest1;
	}

}