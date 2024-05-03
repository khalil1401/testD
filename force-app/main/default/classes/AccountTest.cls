@isTest
public class AccountTest {

	@isTest
	Public static void creoCuentaTipoShipTo() {

		Account cuenta = Build.anAccountSucursaldeenvio()
		.withIdSucursalOracle('idTest')
		.withName('Name Test')
		.withTipoDeSucursal('SHIP_TO')
		.build();
		cuenta.Canal_para_Consumidor_Baby__c = 'Farmacias';
		test.startTest();
		insert cuenta;
		test.stopTest();

		Id sucursalEnvioRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal de envío').getRecordTypeId();

		Account nuevaCuenta = [SELECT RecordTypeId FROM Account WHERE Id = :cuenta.Id];

		System.assertEquals(sucursalEnvioRecTypeId, nuevaCuenta.RecordTypeId);


	}

	@isTest
	Public static void creoCuentaTipoBillTo() {

		Account cuenta = Build.anAccountSucursaldefacturacion()
		.withIdSucursalOracle('idTest')
		.withName('Name Test')
		.withTipoDeSucursal('BILL_TO')
		.build();
		cuenta.Canal_para_Consumidor_Baby__c = 'Farmacias';
		test.startTest();
		insert cuenta;
		test.stopTest();

		Id sucursalFactRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal de facturación').getRecordTypeId();

		Account nuevaCuenta = [SELECT RecordTypeId FROM Account WHERE Id = :cuenta.Id];

		System.assertEquals(sucursalFactRecTypeId, nuevaCuenta.RecordTypeId);


	}

	@isTest
	Public static void creoCuentaTipoCustomer() {

		Account cuenta = New Account();
		cuenta.Name = 'Prueba cuenta pedido';
		cuenta.Id_customer_oracle__c = 'aaa';
		cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal de envío').getRecordTypeId();
		cuenta.Canal_para_Consumidor_Baby__c = 'Farmacias';

		test.startTest();

		insert cuenta;

		test.stopTest();

		Id clienteRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();

		Account nuevaCuenta = [SELECT RecordTypeId FROM Account WHERE Id = :cuenta.Id];

		System.assertEquals(clienteRecTypeId, nuevaCuenta.RecordTypeId);


	}



	@isTest
	Public static void noDebeHaberDuplicadosEnLosPropietariosDeLaCUenta() {
		String status;
		Profile profileIdTest = [SELECT Id FROM Profile WHERE Name = 'Usuario de Platform estándar' LIMIT 1];

		User user1 = Build.aUser()
		.withUsername('test32451test1danonearg@gmail.com')
		.withEmail('test1test1were@gmail.com')
		.withAlias('Ts')
		.withTimeZoneSidKey('GMT')
		.withLocaleSidKey('en_US')
		.withLastName('test apellido')
		.withCommunityNickname('test123')
		.withEmailEncodingKey('UTF-8')
		.withProfileId(profileIdTest.id)
		.withLanguageLocaleKey('en_US')
		.Build();

		insert user1;

		User user2 = Build.aUser()
		.withUsername('test2test2danonearg@gmail.com')
		.withEmail('test2test2@gmail.com')
		.withAlias('Ts2')
		.withTimeZoneSidKey('GMT')
		.withLocaleSidKey('en_US')
		.withLastName('test apellido2')
		.withCommunityNickname('test1232')
		.withEmailEncodingKey('UTF-8')
		.withProfileId(profileIdTest.id)
		.withLanguageLocaleKey('en_US')
		.Build();
		insert user2;

		User user3 = Build.aUser()
		.withUsername('test3test2@gmail.com')
		.withEmail('test2te33t2@gmail.com')
		.withAlias('Ts3332')
		.withTimeZoneSidKey('GMT')
		.withLocaleSidKey('en_US')
		.withLastName('te3st apellido2')
		.withCommunityNickname('te3st1232')
		.withEmailEncodingKey('UTF-8')
		.withProfileId(profileIdTest.id)
		.withLanguageLocaleKey('en_US')
		.Build();

		insert user3;

		Account testAcc1 = new Account();
		testAcc1.Name = 'cuenta 1 test';
		testAcc1.Canal_para_Consumidor_Baby__c = 'Farmacias';
		testAcc1.Propietario_Nicho__c = user1.id;
		testAcc1.Propietario_adulto__c = null;
		testAcc1.Propietario_3__c = null;
		insert testAcc1;

		test.startTest();

		testAcc1.Propietario_adulto__c = user2.Id;
		testAcc1.Propietario_3__c = user3.Id;

		Database.SaveResult result = Database.update(testAcc1, false);


		test.stopTest();

		System.assert(result.isSuccess() == true);
	}
	@isTest
	Public static void siAgregoUnPropietarioTieneQueaparecerEnLaRelacionadaTambien() {
		String status;

		Profile profileIdTest = [SELECT Id FROM Profile WHERE Name = 'Usuario de Platform estándar' LIMIT 1];

		User user1 = Build.aUser()
		.withUsername('test1test2453631danonearg@gmail.com')
		.withEmail('test1test12225@gmail.com')
		.withAlias('Ts')
		.withTimeZoneSidKey('GMT')
		.withLocaleSidKey('en_US')
		.withLastName('test apellido')
		.withCommunityNickname('test123')
		.withEmailEncodingKey('UTF-8')
		.withProfileId(profileIdTest.id)
		.withLanguageLocaleKey('en_US')
		.Build();

		insert user1;


		Account testAcc3 = new Account();
		testAcc3.Name = 'cuenta 3 test';
		testAcc3.Canal_para_Consumidor_Baby__c = 'Farmacias';


		insert testAcc3;

		test.startTest();

		testAcc3.Propietario_Nicho__c = user1.id;
		update testAcc3;


		test.stopTest();

		AccountTeamMember accountteamDb = [SELECT userID FROM AccountTeamMember where accountId = :testAcc3.id];


		System.assertEquals(testAcc3.Propietario_Nicho__c, accountteamDb.userId);

	}

	@isTest
	Public static void siEliminoUnPropietarioTieneQueeliminarseEnLaRelacionadaTambien() {
		String status;

		Profile profileIdTest = [SELECT Id FROM Profile WHERE Name = 'Usuario de Platform estándar' LIMIT 1];

		User user1 = Build.aUser()
		.withUsername('test1344test1danonearg@gmail.com')
		.withEmail('test1tes231@gmail.com')
		.withAlias('Ts')
		.withTimeZoneSidKey('GMT')
		.withLocaleSidKey('en_US')
		.withLastName('test apellido')
		.withCommunityNickname('test123')
		.withEmailEncodingKey('UTF-8')
		.withProfileId(profileIdTest.id)
		.withLanguageLocaleKey('en_US')
		.Build();

		insert user1;

		Account testAcc3 = new Account();
		testAcc3.Name = 'cuenta 3 test';
		testAcc3.Canal_para_Consumidor_Baby__c = 'Farmacias';
		testAcc3.Propietario_Nicho__c = user1.id;
		insert testAcc3;


		test.startTest();

		testAcc3.Propietario_Nicho__c = null;
		update testAcc3;

		test.stopTest();

		List<AccountTeamMember> accountteamDb = [SELECT userID FROM AccountTeamMember where accountId = :testAcc3.id];

		System.assertEquals(0, accountteamDb.size());

	}

	@isTest
	Public static void cargarUnPropietarioyDespuesCambiarlo() {
		List<User> usuarios = [
		                       SELECT Id
		                       FROM User
							   WHERE Username LIKE '%testaccount@gmail.com'
		                      ];

		System.debug(usuarios.size());

		Account testAcc = new Account();
		testAcc.Name = 'cuenta actualizada';
		testAcc.Canal_para_Consumidor_Baby__c = 'Farmacias';
		testAcc.Propietario_Nicho__c = usuarios.get(0).id;
		insert testAcc;


		Test.startTest();
		testAcc.Propietario_Nicho__c = usuarios.get(1).id;
		update testAcc;
		Test.stopTest();


		List<AccountTeamMember> accountteamDb = [SELECT Id, userID FROM AccountTeamMember where accountId = :testAcc.id];
		List<Account> cuenta = [
		                        SELECT Id, Propietario_Nicho__c
		                        FROM Account
		                        WHERE Id = :testAcc.Id
		                       ];

		System.assertEquals(1, accountteamDb.size());

		System.assertEquals(usuarios.get(1).Id, cuenta.get(0).Propietario_Nicho__c);


	}

	@TestSetup
	public static void SetupMethod() {

		Profile profileIdTest = [SELECT Id FROM Profile WHERE Name = 'Usuario de Platform estándar' LIMIT 1];

		List<User> usersToInsert = new List<User> ();

		User user1 = Build.aUser()
		.withUsername('usuario1testaccount@gmail.com')
		.withEmail('usuario1testaccount@gmail.com')
		.withAlias('u1ta')
		.withTimeZoneSidKey('GMT')
		.withLocaleSidKey('en_US')
		.withLastName('test apellido')
		.withCommunityNickname('usuario1testaccount')
		.withEmailEncodingKey('UTF-8')
		.withProfileId(profileIdTest.id)
		.withLanguageLocaleKey('en_US')
		.Build();

		usersToInsert.add(user1);

		User user2 = Build.aUser()
		.withUsername('usuario2testaccount@gmail.com')
		.withEmail('usuario2testaccount@gmail.com')
		.withAlias('u2ta')
		.withTimeZoneSidKey('GMT')
		.withLocaleSidKey('en_US')
		.withLastName('test apellido')
		.withCommunityNickname('usuario2testaccount')
		.withEmailEncodingKey('UTF-8')
		.withProfileId(profileIdTest.id)
		.withLanguageLocaleKey('en_US')
		.Build();

		usersToInsert.add(user2);

		User user3 = Build.aUser()
		.withUsername('usuario3testaccount@gmail.com')
		.withEmail('usuario3testaccount@gmail.com')
		.withAlias('u3ta')
		.withTimeZoneSidKey('GMT')
		.withLocaleSidKey('en_US')
		.withLastName('test apellido')
		.withCommunityNickname('usuario3testaccount')
		.withEmailEncodingKey('UTF-8')
		.withProfileId(profileIdTest.id)
		.withLanguageLocaleKey('en_US')
		.Build();

		usersToInsert.add(user3);

		User user4 = Build.aUser()
		.withUsername('usuario4testaccount@gmail.com')
		.withEmail('usuario4testaccount@gmail.com')
		.withAlias('u4ta')
		.withTimeZoneSidKey('GMT')
		.withLocaleSidKey('en_US')
		.withLastName('test apellido')
		.withCommunityNickname('usuario4testaccount')
		.withEmailEncodingKey('UTF-8')
		.withProfileId(profileIdTest.id)
		.withLanguageLocaleKey('en_US')
		.Build();

		usersToInsert.add(user4);

		User user5 = Build.aUser()
		.withUsername('usuario5testaccount@gmail.com')
		.withEmail('usuario5testaccount@gmail.com')
		.withAlias('u5ta')
		.withTimeZoneSidKey('GMT')
		.withLocaleSidKey('en_US')
		.withLastName('test apellido')
		.withCommunityNickname('usuario5testaccount')
		.withEmailEncodingKey('UTF-8')
		.withProfileId(profileIdTest.id)
		.withLanguageLocaleKey('en_US')
		.Build();

		usersToInsert.add(user5);


		insert usersToInsert;
	}


}