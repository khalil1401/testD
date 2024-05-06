/**
 * Created by: Diego Rene Valle
 * Created Date: 26-08-2021
 * Update Date: --
 *
 * Description: Class to store all test scenarios for Danone360Helper class methods.
 *
 * Suggestions:
 *      -Add a region to identify every test cases for every method from Danone360Helper.
 *      -Add only test scenarios for methods from Danone360Helper.
 *
 * Related class: Danone360Helper
 */

@IsTest
private with sharing class Danone360HelperTest {
	// #region getApiNameFields
	@IsTest
	private static void cuandoIngresoNombreDeObjetoDeberiaObtenerCadenaDeCampos() {
		Test.startTest();
			String result = Danone360Helper.getApiNameFields('Order');
		Test.stopTest();

		System.assertNotEquals('', result, 'No se obtuvieron los campos del objeto.');
	}

	@IsTest
	private static void cuandoNombreDeObjetoEsVacioDeberiaMostrarMensajeDeError() {
		Test.startTest();
			String result = Danone360Helper.getApiNameFields('');
		Test.stopTest();

		System.assertEquals(Label.Nombre_de_API, result, 'Mensaje erróneo.');
	}

	@IsTest
	private static void cuandoNombreDeObjetoErroneoDeberiaMostrarMensajeDeError() {
		Test.startTest();
			String result = Danone360Helper.getApiNameFields('Oder');
		Test.stopTest();

		System.assertEquals(Label.Esquema_de_campos, result, 'Mensaje erróneo.');
	}
	// #endregion

	// #region Columns
	@IsTest
	private static void cuandoEnvioVariosApiNamesDeberiaDevolvermeColumnas() {
		List<String> apiNames = new List<String>{
			'AccountId',
			'OrderNumber',
			'Dan360_UnidadNegocio__c'
		};

		Danone360Helper helper = new Danone360Helper('Order');
		Test.startTest();
			List<GridColumn> columns = helper.getColumns(apiNames);
		Test.stopTest();

		System.assertEquals(3, columns.size(), 'No se generaron las columnas esperadas.');
	}

	@IsTest
	private static void cuandoEnvioApiNameDeberiaGenerarUnaColumna() {
		Danone360Helper helper = new Danone360Helper('Order');

		Test.startTest();
			GridColumn column = helper.getColumn('AccountId');
		Test.stopTest();

		System.assertEquals(true, column != null, 'No se generaron las columnas esperadas.');
	}

	@IsTest
	private static void cuandoCuandoInstanciaHelperConObjetoDeberiaTraerTodosLosCampos() {
		Danone360Helper helper = new Danone360Helper('Order');
		List<String> fields = Danone360Helper.getApiNameFields('Order').split(',');

		Test.startTest();
			List<GridColumn> columns = helper.getColumns();
		Test.stopTest();

		System.assertEquals(fields.size(), columns.size(), 'No se generaron las columnas esperadas.');
	}

	@IsTest
	private static void deberiaObtenerColumnaConInitialWith() {
		Danone360Helper helper = new Danone360Helper('Dan360_DocumentosCuentaCorriente__c');

		Test.startTest();
			GridColumn column = helper.getColumn('Dan360_TipoDeDocumento__c', 100);
		Test.stopTest();

		System.assertEquals(true, column != null, 'No se generaron las columnas esperadas.');
		System.assertEquals(100, column.initialWidth, 'Columna sin \'InitialWith\'.');
	}

	@IsTest
	private static void deberiaObtenerColumnaSinDefaultActions() {
		Danone360Helper helper = new Danone360Helper('Dan360_DocumentosCuentaCorriente__c');

		Test.startTest();
			GridColumn column = helper.getColumn('Dan360_TipoDeDocumento__c', false);
		Test.stopTest();

		System.assertEquals(true, column != null, 'No se generaron las columnas esperadas.');
		System.assertNotEquals(true, column.hideDefaultActions, 'Columna con \'DefaultActions\'.');
	}

	@IsTest
	private static void deberiaObtenerColumnaConCustomTypeYSinDefaultActions() {
		Danone360Helper helper = new Danone360Helper('Dan360_DocumentosCuentaCorriente__c');

		Test.startTest();
			GridColumn column = helper.getColumn('Dan360_TipoDeDocumento__c', 'url', true);
		Test.stopTest();

		System.assertEquals(true, column != null, 'No se generaron las columnas esperadas.');
		System.assertEquals('url', column.type, 'Columna sin \'CustomType\'.');
		System.assertNotEquals(false, column.hideDefaultActions, 'Columna con \'DefaultActions\'.');
	}

	@IsTest
	private static void deberiaObtenerColumnaConCustomTypeAttributesYDefaultActions() {
		Danone360Helper helper = new Danone360Helper('Dan360_DocumentosCuentaCorriente__c');

		Test.startTest();
			GridColumn column = helper.getColumn('Dan360_TipoDeDocumento__c', 'url', true, null);
		Test.stopTest();

		System.assertEquals(true, column != null, 'No se generaron las columnas esperadas.');
		System.assertEquals('url', column.type, 'Columna con diferente \'Type\'.');
		System.assertNotEquals(false, column.hideDefaultActions, 'Columna con \'DefaultActions\'.');
	}

	@IsTest
	private static void deberiaGenerarColumnaPersonalizada() {
		Danone360Helper helper = new Danone360Helper('Account');

		Test.startTest();
			GridColumn column = helper.getCustomColumn('ProofNumberLink', 'url', 'Número de documento', true,  null);
		Test.stopTest();

		System.assertNotEquals(null, column, 'No se generó columna.');
		System.assertEquals('ProofNumberLink', column.fieldName, 'Columna con api name erróneo.');
	}

	// #endregion

	// #region Field Set

	// @IsTest
	// private static void deberiaObtenerFieldSet() {
	// 	Danone360Helper helper = new Danone360Helper('Case');

	// 	Test.startTest();
	// 		String fieldSet = helper.getFieldsFromFieldSet('Dan360_Devoluciones');
	// 		Map<String, Id> recordTypes = helper.getRecordTypes();
	// 	Test.stopTest();

	// 	Map<String, Id> testMap = new Map<String, Id>();

	// 	System.assertNotEquals(null, fieldSet, 'No se encontró el fieldset.');
	// 	System.assertNotEquals(testMap.isEmpty(), recordTypes.isEmpty(), 'No existen RecordTypes');
	// }

	@IsTest
	private static void deberiaObtenerSoloUnFieldSet() {
		Danone360Helper helper = new Danone360Helper('Dan360_DocumentosCuentaCorriente__c');

		Test.startTest();
			List<Object> fieldSet = helper.getFieldSetMembers('Dan360_FiltrosCuentaCorriente');
		Test.stopTest();

		System.assertNotEquals(null, fieldSet, 'No se encontró el fieldset.');
	}

	// #endregion

	// #region Convertion

	// #endregion

	// #region Picklists

	@IsTest
	private static void cuandoIngresoApiDePicklistDeberiaObtenerValores() {
		Danone360Helper helper = new Danone360Helper('Dan360_DocumentosCuentaCorriente__c');
		List<String> sobjectsAndPicklists = new List<String>{
			'Dan360_TipoDeDocumento__c'
		};

		Test.startTest();
			Map<String, List<Schema.PicklistEntry>> entries = helper.getPicklistValues(sobjectsAndPicklists);
		Test.stopTest();

		System.assertNotEquals(null, entries, 'No se encontraron valores de picklist o picklist no existe.');
		System.assertNotEquals(0, entries.size(), 'No se encontraron valores de picklist.');
	}

	// #endregion

	// #region Lookups

	@IsTest
	private static void cuandoIngresoApiDeLookupDeberiaObtenerNombreDeObjetoDeReferencia() {
		Danone360Helper helper = new Danone360Helper('Dan360_DocumentosCuentaCorriente__c');

		Test.startTest();
			String reference = helper.getFieldReference('Dan360_Pedido__c');
		Test.stopTest();

		System.assertNotEquals('', reference, 'No se encontró la referencia ingresada.');
	}

	// #endregion

	// #region Icons

	@IsTest
	private static void cuandoIngresoApiNameDeSObjectDeberiaDevolverNombreDeIcono() {
		Test.startTest();
			String icon = Danone360Helper.getSObjectIcon('Dan360_Sucursal__c');
		Test.stopTest();

		System.assertNotEquals('', icon, 'No se encontró ícono para el objeto ingresado.');
	}

	// #endregion
}