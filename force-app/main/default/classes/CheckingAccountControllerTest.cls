@IsTest
private with sharing class CheckingAccountControllerTest {
	@TestSetup
	static void makeData(){			

		
		UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		Profile profile1 = [Select Id from Profile where Name = 'System Administrator' or name = 'Administrador del sistema' ];

		User userOwner = Build.aUser()
                .withUsername(
                    'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
                )               
                .withEmail('contacto1@xappia.com')
                .withAlias('contact1')
				.withLastName('Contacto1')
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('prueba2.xappia')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(profile1.Id)
				.withUserRoleId(portalRole)				
                .withLanguageLocaleKey('es')
                .build();           
        insert userOwner;
                        
         System.runAs(userOwner){
			Id pricebookId = Test.getStandardPricebookId();

		Account account = Build.anAccount()
			.withName('Test 1')
			.build();

		insert account;

		Order order = Build.anOrder()
			.withAccount(account)
			.withStatus('Borrador')
			.withEffectiveDate(Date.Today())			
			.withBusinessUnit('5800')
			.withPricebook(pricebookId)
			.withPurchaseOrder('123456789')			
			.build();

		insert order;

		Dan360_Remito__c deliveryNote = Build.aRemito()
			.withPedido(order)
			.withSucursal(account)
			.withFecha(Date.Today())
			.build();

		insert deliveryNote;

		Dan360_DocumentosCuentaCorriente__c checkingAccountDocument = Build.aDocumentoCuentaCorriente()
			.withTipoDeDocumento('Factura')
			.withNroComprobante('0005')
			.withCliente(account)
			.withFechaDocumento(Date.Today())
			.withVencimiento(Date.Today().addDays(10))
			.withRemito(deliveryNote)
			.withImporteDocumento(5000.00)
			.withSaldo(5000)
			.withPedido(order)
			.build();

		insert checkingAccountDocument;
            
            Account cuenta = Build.anAccount()                
                .withName('Account Test')
                .build();
            insert cuenta;
        
            Contact contacto1 = Build.aContact()
                .withLastName('Apellido Test')
                .withAccount(cuenta)
                .build();
			contacto1.VisMed_DNI__c = '22222333';
                       
            insert contacto1;

            Profile perfil = [
                SELECT Id 
                FROM Profile 
                WHERE Name = 'APM' 
                LIMIT 1
            ];

            User userTest = Build.aUser()
                .withUsername(
                    'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
                )
                .withContactId(contacto1)
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

            userTest.IsActive = true;
            userTest.VisMed_ContrasenaApp__c = 'Test';

            insert userTest;
        }
		
	}

	@IsTest
	private static void cuandoConsultoDocumentosDeCuentaCorrienteDeberiaDevolverListadoDeDocumentos() {
		Map<String, String> criteria = new Map<String, String>();
		criteria.put('Dan360_NroComprobante__c', '0005');

		Test.startTest();
			ServerResponse response = CheckingAccountController.getCheckingAccountDocuments(criteria);
		Test.stopTest();

		System.assertEquals('SUCCESS', response.state, 'Estado no esperado.');
		System.assertNotEquals(null, response.data, 'No se obtuvo información de cuenta corriente.');
	}
	@IsTest
	private static void cuandoConsultoGetFieldSetberiaDevolverLosCamposDeCuentaCorriente() {
		
		String fieldSet = 'Dan360_FiltrosCuentaCorriente';
		

		Test.startTest();
			String response = CheckingAccountController.getFieldSet(fieldSet);
		Test.stopTest();
		

		System.assertEquals(true, response.contains('type') , 'Estado no esperado.');
				
	}
	@IsTest
	private static void cuandoConsultoUserInfoberiaDevolverUserStateSuccess() {
		
		Contact aContact = [
            SELECT Id, LastName 
            FROM Contact 
            WHERE LastName = 'Apellido Test'
        ];

        User aUser = [SELECT id, Username, VisMed_ContrasenaApp__c, ContactId FROM User 
            WHERE ContactId = :aContact.Id LIMIT 1];
		

		Test.startTest();
			ServerResponse response = CheckingAccountController.getUserInfo(aUser.Id);
		Test.stopTest();
		
		System.assertEquals('SUCCESS', response.state, 'Estado no esperado.');
		
	}
}