@isTest
public class ChangeOfProfessionalsTest {
	
	@IsTest public static void ShouldShowSelectedProfessionals() {

		List<Account> listAccountProfesionales = new List<Account> {
			cuentaProfesional1, cuentaProfesional2, cuentaProfesional3, cuentaProfesional4
		};

		insert listAccountProfesionales;

		List<Account> selectedAccount = new List<Account> {
			cuentaProfesional1, cuentaProfesional2, cuentaProfesional3
		};

		ApexPages.StandardSetController standarController = new ApexPages.StandardSetController(listAccountProfesionales);
		standarController.setSelected(selectedAccount);
		ChangeOfProfessionalsController controller = new ChangeOfProfessionalsController(standarController);

		Test.startTest();
		controller.getCuentas();
		Test.stopTest();

		System.assert(!controller.getCuentas().isEmpty());
		System.assertEquals(3, controller.getCuentas().size());

	}

	@IsTest public static void ListOfSelectedAccounts() {

		List<Account> listAccountProfesionales = new List<Account> {
			cuentaProfesional1, cuentaProfesional2, cuentaProfesional3, cuentaProfesional4
		};

		insert listAccountProfesionales;

		List<Account> selectedAccount = new List<Account> {
			cuentaProfesional1, cuentaProfesional2, cuentaProfesional3
		};

		ApexPages.StandardSetController standarController = new ApexPages.StandardSetController(listAccountProfesionales);
		standarController.setSelected(selectedAccount);
		ChangeOfProfessionalsController controller = new ChangeOfProfessionalsController(standarController);
		
		Test.startTest();
		controller.accountList[1].selected = false;
		Test.stopTest();

		System.assertEquals(true, controller.accountList[0].selected);
        System.assertEquals(false, controller.accountList[1].selected);
        System.assertEquals(true, controller.accountList[2].selected);

	}

	@IsTest public static void ShouldTransferProfessionalAccountsToNewMedicalVisitor() {

		Profile perfilVisitadorMedico = [
			SELECT Id 
			FROM Profile
			WHERE Name = 'Visitador Medico Adulto'
		];

		User usuario = Build.aUser()
			.withContactId(contacto)
			.withUserName(
				'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
			)
			.withLastName('Contacto')
			.withEmail('contacto@xappia.com')
			.withAlias('contact1')
			.withTimeZoneSidKey('America/Argentina/Buenos_Aires')
			.withLocaleSidKey('es_AR')
			.withCommunityNickname('prueba1.xappia')
			.withEmailEncodingKey('ISO-8859-1')
			.withProfileId(perfilVisitadorMedico.Id)
			.withLanguageLocaleKey('es')
			.build();
		insert usuario;

		List<Account> listAccountProfesionales = new List<Account> {
			cuentaProfesional1, cuentaProfesional2, cuentaProfesional3, cuentaProfesional4
		};

		insert listAccountProfesionales;

		List<Account> selectedAccount = new List<Account> {
			cuentaProfesional1, cuentaProfesional2, cuentaProfesional3
		};

		ApexPages.StandardSetController standarController = new ApexPages.StandardSetController(listAccountProfesionales);
		standarController.setSelected(selectedAccount);
		ChangeOfProfessionalsController controller = new ChangeOfProfessionalsController(standarController);
		
		controller.accountList[0].selected = true;
		controller.accountList[1].selected = true;
		controller.accountList[2].selected = true;
		controller.acct.Usuario_Visitador_medico__c = usuario.Id;

		Test.startTest();
		controller.save();
		Test.stopTest();

		List<Account> cuentaProfesionalBD = [
			SELECT Id, Name, OwnerId
			FROM Account
			WHERE Id = :listAccountProfesionales
		];

		System.assertEquals(usuario.Id, cuentaProfesionalBD[0].OwnerId);
		System.assertEquals(usuario.Id, cuentaProfesionalBD[1].OwnerId);
		System.assertEquals(usuario.Id, cuentaProfesionalBD[2].OwnerId);
		System.assertEquals(UserInfo.getUserId(), cuentaProfesionalBD[3].OwnerId);

	}

	@IsTest public static void WhenSelectingAnAccountThatIsNotProfessionalYouMustSendAMsgOfErrorInTheVFAndDisplayAnEmptyList() {

		List<Account> listAccountProfesionales = new List<Account> {
			cuentaProfesional1, cuentaProfesional2, cuentaProfesional3, cuentaProfesional4, cuentaProfesional5
		};

		insert listAccountProfesionales;

		List<Account> selectedAccount = new List<Account> {
			cuentaProfesional5
		};

		ApexPages.StandardSetController standarController = new ApexPages.StandardSetController(listAccountProfesionales);
		standarController.setSelected(selectedAccount);

		PageReference pageRef = Page.ChangeOfProfessionalsPage;
		Test.setCurrentPage(pageRef);

		ChangeOfProfessionalsController controller = new ChangeOfProfessionalsController(standarController);
		
		Test.startTest();
		controller.getCuentas();
		Test.stopTest();

		list<ApexPages.Message> msgList = ApexPages.getMessages();

		System.assert(controller.accountList.isEmpty());
		for (ApexPages.Message msg : ApexPages.getMessages()){
			System.assertEquals('Esta funcionalidad solo permite cambiar el propietario de Profesionales', msg.getSummary());
			System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
		}
	}

	@IsTest public static void ShouldGoBackToThePreviousPage() {
		
		List<Account> listAccountProfesionales = new List<Account> {
			cuentaProfesional1, cuentaProfesional2, cuentaProfesional3, cuentaProfesional4
		};

		insert listAccountProfesionales;

		List<Account> selectedAccount = new List<Account> {
			cuentaProfesional1, cuentaProfesional2, cuentaProfesional3
		};

		ApexPages.StandardSetController standarController = new ApexPages.StandardSetController(listAccountProfesionales);
		standarController.setSelected(selectedAccount);
		ChangeOfProfessionalsController controller = new ChangeOfProfessionalsController(standarController);

		Test.startTest();
		PageReference pr = controller.volver();
		Test.stopTest();
		
		System.assertNotEquals(null, pr);

	}

	static Account cuenta, cuentaProfesional1, cuentaProfesional2, cuentaProfesional3, cuentaProfesional4, cuentaProfesional5;
	static Contact contacto;

	static {

		cuenta = Build.anAccountCuentacommunity()
			.withName('Xappia1')
			.build();
		insert cuenta;

		contacto = Build.aContactContactodesucursal()
			.withFirstName('Primer')
			.withLastName('Contacto')
			.forAccount(cuenta)
			.build();
		insert contacto;

		cuentaProfesional1 = Build.anAccountProfesionaldelasalud()
		.withLastName('Profesional de la Salud 1')
		.build();

		cuentaProfesional2 = Build.anAccountProfesionaldelasalud()
		.withLastName('Profesional de la Salud 2')
		.build();

		cuentaProfesional3 = Build.anAccountProfesionaldelasalud()
		.withLastName('Profesional de la Salud 3')
		.build();

		cuentaProfesional4 = Build.anAccountProfesionaldelasalud()
		.withLastName('Profesional de la Salud 4')
		.build();

		cuentaProfesional5 = Build.anAccountPacienteRegular()
		.withLastName('Profesional de la Salud 5')
		.build();

	}

}