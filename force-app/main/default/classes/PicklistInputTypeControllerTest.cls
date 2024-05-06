@IsTest
private with sharing class PicklistInputTypeControllerTest {
	@TestSetup
	static void makeData(){

	}

	@IsTest
	private static void cuandoRequieroPicklistDeberiaDevolverListadoConValores() {
		Test.startTest();
			List<Object> fieldValues = PicklistInputTypeController.getPicklistFieldsValues('Order', 'Dan360_UnidadNegocio__c');
		Test.stopTest();

		System.assertNotEquals(null, fieldValues, 'No existen picklist.');
		System.assertNotEquals(0, fieldValues.size(), 'No se encontraron valores de la picklist seleccionada.');
	}

	@IsTest
	private static void deberiaDevolverSObjectReferenceDelApiIngresado() {
		Test.startTest();
			String reference = PicklistInputTypeController.getSObjectFieldReference('Dan360_Sucursal__c');
		Test.stopTest();

		System.assertNotEquals('', reference, 'No se encontró referencia.');
	}
}