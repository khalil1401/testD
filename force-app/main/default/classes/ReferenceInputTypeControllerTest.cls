@IsTest
private with sharing class ReferenceInputTypeControllerTest {
	@TestSetup
	static void makeData(){
		Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal').getRecordTypeId();
		Account accountOne = Build.anAccount()
			.withName('TEST1')
			.withRecordTypeId(recordTypeId)	
			.withIdSap('11111')
			.build();	

		insert accountOne;

		
	}

	@IsTest
	private static void cuandoIngresoPalabraClaveDeberiaDevolverArreglo() {
		String keyword = 'TEST';
		String sobj = 'Account';
		List<String> fields = new List<String>{ 'Name' };

		Test.startTest();
			List<Object> result = ReferenceInputTypeController.find(sobj, fields, keyword);
		Test.stopTest();

		System.assertEquals(1, result.size(), 'No se encontraron resultados con los datos ingresados.');
	}

	@IsTest
	private static void cuandoIngresoPalabraClaveDeberiaDevolverArregloVacioSiNoHayResultados() {
		String keyword = 'MEDI';
		String sobj = 'Account';
		List<String> fields = new List<String>{ 'Name' };

		Test.startTest();
			List<Object> result = ReferenceInputTypeController.find(sobj, fields, keyword);
		Test.stopTest();

		System.assertNotEquals(1, result.size(), 'Se encontraron resultados con el término ingresado.');
	}
	@IsTest
	private static void cuandoIngresoPalabraClaveDeberiaDevolverArregloVacioDeRemitos() {
		String recordId = [SELECT Id FROM Account WHERE Name = 'TEST1'].Id;
		String keyword = 'MEDI';
		String sobj = 'Account';
		List<String> fields = new List<String>{ 'Name' };

		Test.startTest();
			List<Object> result = ReferenceInputTypeController.findRemitoSucursal(sobj, fields, keyword, recordId);
		Test.stopTest();

		System.assertEquals(0, result.size(), 'Se encontraron resultados con el término ingresado.');
	}
	@IsTest
	private static void cuandoIngresoPalabraClaveDeberiaDevolverArregloConUnRemito() {
		Account anAccount = [SELECT Id, Name FROM Account WHERE Name = 'TEST1'];
		String sobj = 'Account';
		String keyword ='Test';
		List<String> fields = new List<String>{ 'Name' };
		Order order = Build.anOrder()
		.withAccount(anAccount)
		.withStatus('Borrador')
		.withBusinessUnit('5771')
		.withEffectiveDate(Date.today())
		.build();
		insert order;
		
		
		Dan360_Remito__c remito = Build.aRemito()
		.withPedido(order)
		.withSucursal(anAccount)
		.withDelivery('Rem0000')
		.build();
		insert remito;
		
		Dan360_DocumentosCuentaCorriente__c checkingAccountDocument = Build.aDocumentoCuentaCorriente()
			.withTipoDeDocumento('Factura')
			.withNroComprobante('0005')
			.withCliente(anAccount)
			.withFechaDocumento(Date.Today())
			.withVencimiento(Date.Today().addDays(10))
			.withRemito(remito)
			.withImporteDocumento(5000.00)
			.withSaldo(5000)
			.withPedido(order)
			.build();
		checkingAccountDocument.Dan360_Sucursal__c = anAccount.Id;

		insert checkingAccountDocument;

		Test.startTest();
			List<Object> result = ReferenceInputTypeController.findRemitoSucursal(sobj, fields, keyword, anAccount.id);
		Test.stopTest();

		System.assertEquals(1, result.size(), 'Se encontraron resultados con el término ingresado.');
	}
	@IsTest
	private static void cuandoIngresoPalabraClavePorTipoDeRegistroDeberiaDevolverArreglo() {
		String keyword = 'TEST';
		String sobj = 'Account';
		List<String> fields = new List<String>{ 'Name' };
		Id recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal').getRecordTypeId();
		List<String> recordTypeId = new List<String>{ recordType };

		Test.startTest();
			List<Object> result = ReferenceInputTypeController.find(sobj, fields, keyword, recordTypeId);
		Test.stopTest();

		System.assertEquals(1, result.size(), 'No se encontraron resultados con los datos ingresados.');
	}

	@IsTest
	private static void cuandoIngresoPalabraClavePorTipoDeRegistroDeberiaDevolverArregloVacioSiNoHayResultados() {
		String keyword = 'MEDI';
		String sobj = 'Account';
		List<String> fields = new List<String>{ 'Name' };
		List<String> recordTypeId = new List<String>{ 'Sucursal' };

		Test.startTest();
			List<Object> result = ReferenceInputTypeController.find(sobj, fields, keyword, recordTypeId);
		Test.stopTest();

		System.assertNotEquals(1, result.size(), 'No se encontro el remito.');
	}

	@IsTest
	private static void deberiaDevolverSObjectReferenceDelApiIngresado() {
		Test.startTest();
			String reference = PicklistInputTypeController.getSObjectFieldReference('Dan360_Sucursal__c');
		Test.stopTest();

		System.assertNotEquals('', reference, 'No se encontró referencia.');
	}
	@IsTest
	private static void deberiaDevolverListOfString() {
		Account anAccount = [SELECT Id, Name FROM Account WHERE Name = 'TEST1'];
		String sobj = 'Account';
		String keyword ='Test';
		List<String> fields = new List<String>{ 'Name' };
		Order order = Build.anOrder()
		.withAccount(anAccount)
		.withStatus('Borrador')
		.withBusinessUnit('5771')
		.withEffectiveDate(Date.today())
		.build();
		insert order;
		
		
		Dan360_Remito__c remito = Build.aRemito()
		.withPedido(order)
		.withSucursal(anAccount)
		.withDelivery('Rem0000')
		.build();
		insert remito;
		
		Dan360_DocumentosCuentaCorriente__c checkingAccountDocument = Build.aDocumentoCuentaCorriente()
			.withTipoDeDocumento('Factura')
			.withNroComprobante('0005')
			.withCliente(anAccount)
			.withFechaDocumento(Date.Today())
			.withVencimiento(Date.Today().addDays(10))
			.withRemito(remito)
			.withImporteDocumento(5000.00)
			.withSaldo(5000)
			.withPedido(order)
			.build();
		checkingAccountDocument.Dan360_Sucursal__c = anAccount.Id;		
		insert checkingAccountDocument;
		
		Test.startTest();
			List<String> reference = ReferenceInputTypeController.getRemitosFromCC();
		Test.stopTest();

		System.assertEquals(1, reference.size(), 'No se encontró referencia.');
	}
	@IsTest
	private static void deberiaDevolverIconName() {
		Test.startTest();
			String iconName = ReferenceInputTypeController.getIconInfo('Account');
		Test.stopTest();

		System.assertEquals('standard:account', iconName, 'No se encontró referencia.');
	}
}