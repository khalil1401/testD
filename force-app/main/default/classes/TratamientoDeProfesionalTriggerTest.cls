@isTest
public class TratamientoDeProfesionalTriggerTest {

	@isTest
    public static void siSeInsertaUnTRatamientoDeProfesionalSeDebeActualizarElCampoCantidadEnElProfesionalCOrrespondiente(){

		Account profesional = New Account();
		profesional.lastName = 'Prueba prof';
		profesional.RecordTypeId = XappiaHelper.getRecordType('Account', 'Profesional de la salud').id;

        insert profesional;

        Account testAcc = new Account();
        testAcc.lastName = 'paciente';
        testAcc.Canal_para_Consumidor_Baby__c = 'Farmacias';
		testAcc.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Best Care').id;
        
        insert testAcc;
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Name Test')
            .withDNI('1234677789')
            .withCanalParaConsumidorBaby('Farmacias')
            .build();
        
        insert accObraSocial;
        
        Tratamiento__c tratamiento = new Tratamiento__c();
        tratamiento.Activo__c = true;
        tratamiento.Cuenta__c=testAcc.id;
        tratamiento.Obra_social__c = accObraSocial.id;
        
        insert tratamiento;
        
        Tratamiento_de_profesional__c tratProf = new Tratamiento_de_profesional__c();
        tratProf.Tratamiento__c = Tratamiento.id;
        tratProf.Profesional__c = profesional.id;
        
		insert tratProf;
        
        Tratamiento_de_profesional__c tratProf2 = new Tratamiento_de_profesional__c();
        tratProf2.Tratamiento__c = Tratamiento.id;
        tratProf2.Profesional__c = profesional.id;
        
		insert tratProf2;
        
		Test.StartTest();       
		
		Test.StopTest();

        Account profesionalDb = [
            SELECT id, Cantidad_de_tratamientos_Profesional__c
            FROM Account
            WHERE id =:profesional.id
        ];
        
		System.assertEquals('2', profesionalDb.Cantidad_de_tratamientos_Profesional__c);

    }
    
    	@isTest
    public static void siSeEliminaUnTratamientoDeProfesionalSeDebeActualizarElCampoCantidadEnElProfesionalCOrrespondiente(){

		Account profesional = New Account();
		profesional.lastName = 'Prueba prof';
		profesional.RecordTypeId = XappiaHelper.getRecordType('Account', 'Profesional de la salud').id;

        insert profesional;

        Account testAcc = new Account();
        testAcc.lastName = 'paciente';
        testAcc.Canal_para_Consumidor_Baby__c = 'Farmacias';
		testAcc.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Best Care').id;
        
        insert testAcc;
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Name Test')
            .withDNI('1234677789')
            .withCanalParaConsumidorBaby('Farmacias')
            .build();
        
        insert accObraSocial;
        
        Tratamiento__c tratamiento = new Tratamiento__c();
        tratamiento.Activo__c = true;
        tratamiento.Cuenta__c=testAcc.id;
        tratamiento.Obra_social__c = accObraSocial.id;
        
        insert tratamiento;
        
        Tratamiento_de_profesional__c tratProf = new Tratamiento_de_profesional__c();
        tratProf.Tratamiento__c = Tratamiento.id;
        tratProf.Profesional__c = profesional.id;
        
		insert tratProf;
        
        Tratamiento_de_profesional__c tratProf2 = new Tratamiento_de_profesional__c();
        tratProf2.Tratamiento__c = Tratamiento.id;
        tratProf2.Profesional__c = profesional.id;
        
		insert tratProf2;
        
		Test.StartTest();       
		
        delete tratProf;
        
		Test.StopTest();

        Account profesionalDb = [
            SELECT id, Cantidad_de_tratamientos_Profesional__c
            FROM Account
            WHERE id =:profesional.id
        ];
        
		System.assertEquals('1', profesionalDb.Cantidad_de_tratamientos_Profesional__c);

    }
    
    
}