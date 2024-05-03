@isTest
public class CreateContactAccountControllerTest {

	@isTest
	Public static void mostrarMensajeDeErrorCuandoNoCargaIdDelPaciente(){
	
		Test.startTest();
		CreateContactAccountController controller = new CreateContactAccountController();
		Test.stopTest();
        
		List<ApexPages.Message> ListaMensaje = ApexPages.getMessages();
		System.assertNotEquals(0, ListaMensaje.size());
		for(ApexPages.Message msg :  ListaMensaje) {
			System.assertEquals('¡Error al cargar datos del paciente!', msg.getSummary());
			System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
		}
    }

	@isTest
	Public static void mostrarMensajeDeErrorCuandoNoGuardaCorrectamenteElContactoDePaciente(){
		
		PageReference pagina = new PageReference('/apex/CreateContactAccount');
		pagina.getParameters().put('id', cuenta.Id);
		Test.setCurrentPage(pagina);
        
		CreateContactAccountController controller = new CreateContactAccountController();
		controller.contactoDePaciente.Principal__c = True;
		controller.contactoDePaciente.Relacion__c = 'Padre';

		Test.startTest();
		controller.guardar();
		Test.stopTest();
        
		List<ApexPages.Message> ListaMensaje = ApexPages.getMessages();
		System.assertNotEquals(0, ListaMensaje.size());
		for(ApexPages.Message msg :  ListaMensaje) {
			System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
		}
    }

	@isTest
	Public static void mostrarMensajeDeGuardadoCorrectoCuandoSeCreaElContactoDePaciente(){
  
		PageReference pagina = new PageReference('/apex/CreateContactAccount');
		pagina.getParameters().put('id', cuenta.Id);
		Test.setCurrentPage(pagina);
		CreateContactAccountController controller = new CreateContactAccountController();
		controller.contactoDePaciente.Contacto__c = contacto.Id;
		controller.contactoDePaciente.Principal__c = True;
		controller.contactoDePaciente.Relacion__c = 'Padre';

		Test.startTest();
		controller.guardar();
		Test.stopTest();

		List<ApexPages.Message> ListaMensaje = ApexPages.getMessages();
		System.assertNotEquals(0, ListaMensaje.size());
		for(ApexPages.Message msg :  ListaMensaje) {
			System.assertEquals('¡Se insertaron los datos correctamente!', msg.getSummary());
			System.assertEquals(ApexPages.Severity.CONFIRM, msg.getSeverity()); 
		}
    }


	static Account cuenta;
	static Contact contacto;
	static {
	
		cuenta = Build.anAccountPacienteBestCare()
            .withEmpresadeinternaciondomiciliaria('Best Care')
            .withRegimenDeInternacionDomiciliaria('Sí')
			.withLastName('Apellido')
            .build();
        insert cuenta;
		
		Codigo_Postal__c codigoPostal = Build.aCodigoPostal()
			.withName('B2700AAG')
			.withProvincia('BUENOS AIRES')
			.withLocalidad('PERGAMINO')
			.withCalles('AV ALSINA 601-699')
            .build();
        insert codigoPostal;

		contacto = Build.aContactContactodepaciente()
			.withLastName('Test'+String.valueOf(System.now().getTime() + (Math.random() * 10)))
			.withDepartamento('D')
			.withPiso('5')
			.withCalle('Santa Fe 897')
			.withPais('Argentina')
			.withCodigoPostal(codigoPostal)
			.withReferencia('al lado del Dia')
			.build();
        insert contacto;
	}
}