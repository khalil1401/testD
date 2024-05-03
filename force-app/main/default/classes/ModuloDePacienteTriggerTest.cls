@isTest
private class ModuloDePacienteTriggerTest {

	public static List<Account> listNewAccounts = new List<Account> ();
	public static List<Product2> listNewProductos = new List<Product2> ();
	public static List<Modulo_de_paciente__c> listNewModuloPacientes = new List<Modulo_de_paciente__c> ();
	public static List<Producto_de_modulo__c> listNewProductoModulo = new List<Producto_de_modulo__c> ();
	public static String expectedResult;


 /*EL TRIGGER DE PRODUCTODEMODULO EN PRODUCCION ESTABA DESACTIVADO, LO ACTIVE NUEVAMENTE PERO COMENTE LA FUNCIONALIDAD VIEJA*/
	/*@isTest static void UpdateModuloPacienteInactivo() {

		CreateSimpleScheme();
		GetAccounts();
        
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);

		Test.startTest();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;
       
		Test.stopTest();

		GetAccounts();
		System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}


	@isTest static void UpdateModuloPacienteInactivoConVariasModulosYProductos() {

		CreateMultiScheme();

		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);

		Test.startTest();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;
		Test.stopTest();

		GetAccounts();
		System.assertEquals('ProductName-I512, 4 Unidades', listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);
		System.assertEquals(null, listNewAccounts[1].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}

	@isTest static void UpdateModuloPacienteInactivoConVariosModulos() {

		CreateSimpleSchemeMultiModulesAccount();

		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);

		Test.startTest();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;
		Test.stopTest();

		GetAccounts();
		System.assertEquals('ProductName-P128, 3 Unidades' + '\r\n' + 'ProductName-P128, 4 Unidades', 
			listNewAccounts[0].Formulas_actuales__c, System.label.testmsgNotMach);
	}

	@isTest static void UpdateModuloPacienteInactivoConVariosProductos() {

		CreateSimpleSchemeMultiProducts();

		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);

		Test.startTest();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;
		Test.stopTest();

		GetAccounts();
		System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testsmgInvalidNull);
	}*/

	@isTest static void UpdateModuloPacienteActivo() {

		CreateSimpleScheme();

		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		Test.startTest();
		listNewModuloPacientes[0].Estado__c = 'Activo';
		update listNewModuloPacientes;
		Test.stopTest();

		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);
	}

	@isTest static void UpdateModuloPacienteActivoConVariosProductosYModulos() {

		CreateMultiScheme();

		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		Test.startTest();
		listNewModuloPacientes[0].Estado__c = 'Activo';
		update listNewModuloPacientes;
		Test.stopTest();

		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);
		System.assertEquals(null, listNewAccounts[1].Formulas_actuales__c, 
			System.label.testsmgInvalidNull);
	}

	@isTest static void UpdateModuloPacienteActivoConVariosModulos() {

		CreateSimpleSchemeMultiModulesAccount();

		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		Test.startTest();
		listNewModuloPacientes[0].Estado__c = 'Activo';
		update listNewModuloPacientes;
		Test.stopTest();

		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);
	}


	@isTest static void UpdateModuloPacienteActivoConVariosProductos() {

		CreateSimpleSchemeMultiProducts();

		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		Test.startTest();
		listNewModuloPacientes[0].Estado__c = 'Activo';
		update listNewModuloPacientes;
		Test.stopTest();

		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);
	}

	/*@isTest static void DeleteModuloPacienteInactivo() {

		CreateSimpleScheme();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		Test.startTest();
		delete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}*/

	@isTest static void DeleteModuloPacienteInactivoConVariosProductosYModulos() {

		CreateMultiScheme();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		Test.startTest();
		delete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals('ProductName-I512, 4 Unidades', listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);
		System.assertEquals(null, listNewAccounts[1].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}

	@isTest static void DeleteModuloPacienteInactivoConVariosModulos() {

		CreateSimpleSchemeMultiModulesAccount();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		Test.startTest();
		delete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals('ProductName-P128, 3 Unidades' + '\r\n' + 'ProductName-P128, 4 Unidades', 
			listNewAccounts[0].Formulas_actuales__c, System.label.testmsgNotMach);
	}

	@isTest static void DeleteDeTodosLosModuloPacienteInactivoConVariosModulos() {

		CreateSimpleSchemeMultiModulesAccount();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		Test.startTest();
		delete listNewModuloPacientes;
		Test.stopTest();

		GetAccounts();
		System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}

	@isTest static void DeleteModuloPacienteInactivoConVariosProductos() {

		CreateSimpleSchemeMultiProducts();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		Test.startTest();
		delete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}


	/*@isTest static void DeleteModuloPacienteActivo() {

		CreateSimpleScheme();
		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c,
			 System.label.testmsgNotMach);

		Test.startTest();
		delete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}*/

/*	@isTest static void DeleteModuloPacienteActivoConVariosProductosYModulos() {

		CreateMultiScheme();
		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);

		Test.startTest();
		delete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals('ProductName-I512, 4 Unidades',
			 listNewAccounts[0].Formulas_actuales__c, System.label.testmsgNotMach);
		System.assertEquals(null, listNewAccounts[1].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}*/

	/*@isTest static void DeleteModuloPacienteActivoConVariosModulos() {

		CreateSimpleSchemeMultiModulesAccount();
		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c,
			 System.label.testmsgNotMach);

		Test.startTest();
		delete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals('ProductName-P128, 3 Unidades' + '\r\n' + 'ProductName-P128, 4 Unidades', 
			listNewAccounts[0].Formulas_actuales__c, System.label.testmsgNotMach);
	}
*/
/*	@isTest static void DeleteModuloPacienteActivoConVariosProductos() {

		CreateSimpleSchemeMultiProducts();
		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);

		Test.startTest();
		delete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}*/

	@isTest static void UnDeleteModuloPacienteInactivo() {

		CreateSimpleScheme();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		GetAccounts();
		System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, System.label.testsmgInvalidNull);
		delete listNewModuloPacientes[0];

		Test.startTest();
		undelete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}

	@isTest static void UnDeleteModuloPacienteInactivoConVariosProductosYModulos() {

		CreateMultiScheme();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		GetAccounts();
		System.assertEquals('ProductName-I512, 4 Unidades', 
			listNewAccounts[0].Formulas_actuales__c, System.label.testmsgNotMach);
		delete listNewModuloPacientes[0];

		Test.startTest();
		undelete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals('ProductName-I512, 4 Unidades', 
			listNewAccounts[0].Formulas_actuales__c, System.label.testmsgNotMach);
		System.assertEquals(null, listNewAccounts[1].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}

	@isTest static void UnDeleteModuloPacienteInactivoConVariosModulos() {

		CreateSimpleSchemeMultiModulesAccount();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		GetAccounts();
		System.assertEquals('ProductName-P128, 3 Unidades' + '\r\n' + 'ProductName-P128, 4 Unidades', 
			listNewAccounts[0].Formulas_actuales__c, System.label.testmsgNotMach);
		delete listNewModuloPacientes[0];

		Test.startTest();
		undelete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals('ProductName-P128, 3 Unidades' + '\r\n' + 'ProductName-P128, 4 Unidades', 
			listNewAccounts[0].Formulas_actuales__c, System.label.testmsgNotMach);

		listNewModuloPacientes = [select id, Estado__c from Modulo_de_paciente__c];
		System.assertEquals('Inactivo', listNewModuloPacientes[0].Estado__c,
			 'El estado del modulo al recuperarlo no es el mismo.');
	}

	@isTest static void UnDeleteModuloPacienteInactivoConVariosProductos() {

		CreateSimpleSchemeMultiProducts();
		listNewModuloPacientes[0].Estado__c = 'Inactivo';
		update listNewModuloPacientes;

		GetAccounts();
		System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, System.label.testsmgInvalidNull);
		delete listNewModuloPacientes[0];

		Test.startTest();
		undelete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals(null, listNewAccounts[0].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}

	/*@isTest static void UnDeleteModuloPacienteActivo() {

		CreateSimpleScheme();
		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);

		delete listNewModuloPacientes[0];

		Test.startTest();
		undelete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);
	}
*/
/*	@isTest static void UnDeleteModuloPacienteActivoConVariosProductosYModulos() {

		CreateMultiScheme();
		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);

		delete listNewModuloPacientes[0];

		Test.startTest();
		undelete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);
		System.assertEquals(null, listNewAccounts[1].Formulas_actuales__c, System.label.testsmgInvalidNull);
	}
*/
/*	@isTest static void UnDeleteModuloPacienteActivoConVariosModulos() {

		CreateSimpleSchemeMultiModulesAccount();
		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c,
			 System.label.testmsgNotMach);
		delete listNewModuloPacientes[0];

		Test.startTest();
		undelete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c,
			 System.label.testmsgNotMach);
	}
*/
	/*@isTest static void UnDeleteModuloPacienteActivoConVariosProductos() {

		CreateSimpleSchemeMultiProducts();
		GetAccounts();

		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c,
			 System.label.testmsgNotMach);

		delete listNewModuloPacientes[0];

		Test.startTest();
		undelete listNewModuloPacientes[0];
		Test.stopTest();

		GetAccounts();
		System.assertEquals(expectedResult, listNewAccounts[0].Formulas_actuales__c, 
			System.label.testmsgNotMach);
	}*/
	@IsTest
	static void whenInsertModuloActivoIsFull_AccountUltimoModuloFull(){
		newAccount();
		GetAccounts();
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo('CUIDADO COMPLETO').build());

		Test.startTest();
			insert listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Ultimo_Modulo__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('Full', cuenta.Ultimo_Modulo__c);
		
	}
	@IsTest
	static void whenUpsertModuloActivoIsFull_AccountUltimoModuloFull(){
		newAccount();
		GetAccounts();
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Inactivo').withTipo('CUIDADO COMPLETO').build());
		insert listNewModuloPacientes;
		
		listNewModuloPacientes[0].Estado__c = 'Activo';

		Test.startTest();
			update listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Ultimo_Modulo__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('Full', cuenta.Ultimo_Modulo__c);
		
	}
	@IsTest
	static void whenInsertModuloActivoIsNotFull_AccountUltimoModuloLogistico(){
		string tipo;
		newAccount();
		GetAccounts();
		
		for( Schema.PicklistEntry pickListVal : Modulo_de_paciente__c.Tipo__c.getDescribe().getPicklistValues()){
            if(pickListVal.getValue() != 'CUIDADO COMPLETO'){
				tipo = pickListVal.getValue();
				break;
			}
        } 
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo(tipo).build());
		
		Test.startTest();
			insert listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Ultimo_Modulo__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('Logistico', cuenta.Ultimo_Modulo__c);
		
	}
	@IsTest
	static void whenUpdateModuloActivoIsNotFull_AccountUltimoModuloLogistico(){
		string tipo;
		newAccount();
		GetAccounts();
		
		for( Schema.PicklistEntry pickListVal : Modulo_de_paciente__c.Tipo__c.getDescribe().getPicklistValues()){
            if(pickListVal.getValue() != 'CUIDADO COMPLETO'){
				tipo = pickListVal.getValue();
				break;
			}
        } 
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Inactivo').withTipo(tipo).build());
		insert listNewModuloPacientes;
		
		listNewModuloPacientes[0].Estado__c = 'Activo';

		Test.startTest();
			update listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Ultimo_Modulo__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('Logistico', cuenta.Ultimo_Modulo__c);
		
	}
	@IsTest
	static void whenInsertModuloActivoFullAndInsertModuloNotFullActivo_AccountUltimoModuloFull(){
		string tipo;
		newAccount();
		GetAccounts();
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo('CUIDADO COMPLETO').build());
		for( Schema.PicklistEntry pickListVal : Modulo_de_paciente__c.Tipo__c.getDescribe().getPicklistValues()){
            if(pickListVal.getValue() != 'CUIDADO COMPLETO'){
				tipo = pickListVal.getValue();
				break;
			}
        }
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo(tipo).build());

		Test.startTest();
			insert listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Ultimo_Modulo__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('Full', cuenta.Ultimo_Modulo__c);
		
	}
	@IsTest
	static void whenInsertModuloNotFullActivoAndUpdateModuloActivoFull_AccountUltimoModuloFull(){
		string tipo;
		newAccount();
		GetAccounts();
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Inactivo').withTipo('CUIDADO COMPLETO').build());
		for( Schema.PicklistEntry pickListVal : Modulo_de_paciente__c.Tipo__c.getDescribe().getPicklistValues()){
            if(pickListVal.getValue() != 'CUIDADO COMPLETO'){
				tipo = pickListVal.getValue();
				break;
			}
        }
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo(tipo).build());
		insert listNewModuloPacientes;

		listNewModuloPacientes[0].Estado__c = 'Activo';
		Test.startTest();
		update listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Ultimo_Modulo__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('Full', cuenta.Ultimo_Modulo__c);
		
		
	}
	@IsTest
	static void whenInsertModuloNotFullActivoAndModuloInactivoFull_AccountUltimoModuloLogistico(){
		string tipo;
		newAccount();
		GetAccounts();
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Inactivo').withTipo('CUIDADO COMPLETO').build());
		for( Schema.PicklistEntry pickListVal : Modulo_de_paciente__c.Tipo__c.getDescribe().getPicklistValues()){
            if(pickListVal.getValue() != 'CUIDADO COMPLETO'){
				tipo = pickListVal.getValue();
				break;
			}
        }
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo(tipo).build());

		Test.startTest();
			insert listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Ultimo_Modulo__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('Logistico', cuenta.Ultimo_Modulo__c);
		
	}
	@IsTest
	static void whenModuloFullIsActive_AccountChangeToStatusEnTratamientoAndSubStatusTratamientoEfectivo(){
		newAccount();
		GetAccounts();
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo('CUIDADO COMPLETO').build());

		Test.startTest();
			insert listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Estado_de_paciente__c, Subestado_del_paciente__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('En tratamiento', cuenta.Estado_de_paciente__c);
		System.assertEquals('Tratamiento Efectivo', cuenta.Subestado_del_paciente__c);
	}
	@IsTest
	static void whenModuloNotFullIsActive_AccountChangeToStatusEnTratamientoAndSubStatusTratamientoEfectivo(){
		string tipo;
		newAccount();
		GetAccounts();
		
		for( Schema.PicklistEntry pickListVal : Modulo_de_paciente__c.Tipo__c.getDescribe().getPicklistValues()){
            if(pickListVal.getValue() != 'CUIDADO COMPLETO'){
				tipo = pickListVal.getValue();
				break;
			}
        } 
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo(tipo).build());
		
		Test.startTest();
			insert listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Estado_de_paciente__c, Subestado_del_paciente__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('En tratamiento', cuenta.Estado_de_paciente__c);
		System.assertEquals('Tratamiento Efectivo', cuenta.Subestado_del_paciente__c);
	}
	@IsTest
	static void whenModuloIsInactiveSubestadoInternado_AccountNotChange(){
		string tipo;
		newAccount();
		GetAccounts();
		
		for( Schema.PicklistEntry pickListVal : Modulo_de_paciente__c.Tipo__c.getDescribe().getPicklistValues()){
            if(pickListVal.getValue() != 'CUIDADO COMPLETO'){
				tipo = pickListVal.getValue();
				break;
			}
        } 
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo(tipo).build());
		insert listNewModuloPacientes;

		listNewAccounts[0].Estado_de_paciente__c = 'En Seguimiento';
		listNewAccounts[0].Subestado_del_paciente__c = 'Tramite iniciado';
		update listNewAccounts;

		listNewModuloPacientes[0].Estado__c = 'Inactivo';

		Test.startTest();
			update listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Estado_de_paciente__c, Subestado_del_paciente__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('En Seguimiento', cuenta.Estado_de_paciente__c);
		System.assertEquals('Tramite iniciado', cuenta.Subestado_del_paciente__c);
	}
	@IsTest
	static void whenModuloIsInactiveAccountEstadoNotratamiento_AccountNotChange(){
		string tipo;
		newAccount();
		GetAccounts();
		
		for( Schema.PicklistEntry pickListVal : Modulo_de_paciente__c.Tipo__c.getDescribe().getPicklistValues()){
            if(pickListVal.getValue() != 'CUIDADO COMPLETO'){
				tipo = pickListVal.getValue();
				break;
			}
        } 
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo(tipo).build());
		insert listNewModuloPacientes;

		listNewAccounts[0].Estado_de_paciente__c = 'No tratamiento';
		listNewAccounts[0].Subestado_del_paciente__c = 'No tolera';
		listNewAccounts[0].Fecha_de_baja__c = date.today();
        listNewAccounts[0].Fecha_de_obito__c = date.today();
        system.debug('-------------------Fecha de baja '+listNewAccounts[0].Fecha_de_baja__c);
		update listNewAccounts;

		listNewModuloPacientes[0].Estado__c = 'Inactivo';

		Test.startTest();
			update listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Estado_de_paciente__c, Subestado_del_paciente__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('No tratamiento', cuenta.Estado_de_paciente__c);
		System.assertEquals('No tolera', cuenta.Subestado_del_paciente__c);
	}
	@IsTest
	static void whenModuloIsInactiveAccountEstadoFindetratamiento_AccountNotChange(){
		string tipo;
		newAccount();
		GetAccounts();
		
		for( Schema.PicklistEntry pickListVal : Modulo_de_paciente__c.Tipo__c.getDescribe().getPicklistValues()){
            if(pickListVal.getValue() != 'CUIDADO COMPLETO'){
				tipo = pickListVal.getValue();
				break;
			}
        } 
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo(tipo).build());
		insert listNewModuloPacientes;

		listNewAccounts[0].Estado_de_paciente__c = 'Fin de tratamiento';
		listNewAccounts[0].Subestado_del_paciente__c = 'Fallecido';
		listNewAccounts[0].Fecha_de_obito__c = date.today();
		update listNewAccounts;

		listNewModuloPacientes[0].Estado__c = 'Inactivo';

		Test.startTest();
			update listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Estado_de_paciente__c, Subestado_del_paciente__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('Fin de tratamiento', cuenta.Estado_de_paciente__c);
		System.assertEquals('Fallecido', cuenta.Subestado_del_paciente__c);
	}
	
	@IsTest
	static void whenModuloIsInactiveButOtherModuloActive_AccountNotChange(){
		string tipo;
		newAccount();
		GetAccounts();
		
		for( Schema.PicklistEntry pickListVal : Modulo_de_paciente__c.Tipo__c.getDescribe().getPicklistValues()){
            if(pickListVal.getValue() != 'CUIDADO COMPLETO'){
				tipo = pickListVal.getValue();
				break;
			}
        } 
		
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo(tipo).build());
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo('CUIDADO COMPLETO').build());
		insert listNewModuloPacientes;
		
		listNewModuloPacientes[0].Estado__c = 'Inactivo';

		Test.startTest();
		update listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [SELECT Estado_de_paciente__c, Subestado_del_paciente__c FROM account WHERE id =:listNewAccounts[0].id];
		System.assertEquals('En tratamiento', cuenta.Estado_de_paciente__c);
		System.assertEquals('Tratamiento Efectivo', cuenta.Subestado_del_paciente__c);
	}

	@IsTest
	static void whenMDPIsInsertAccountIsUpdate(){
		newAccount();
		GetAccounts();

		Modulo__c testModulo = new modulo__c();
        testModulo.Name = 'Alergia';
        testModulo.N_de_Material__c = 123456;
        insert testModulo;

		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').withTipo('CUIDADO PERSONALIZADO').build());
		
		listNewModuloPacientes[0].Estado_de_modulo__c = 'Ingresado';
		listNewModuloPacientes[0].modulo__c= testModulo.id;

		Test.startTest();
		insert listNewModuloPacientes;
		Test.stopTest();

		Account cuenta = [
			SELECT Estado_de_paciente__c, Subestado_del_paciente__c ,Estado_del_ultimo_modulo__c,Modulo_activo__c,Modulo__c
			FROM account 
			WHERE id =:listNewAccounts[0].id
			LIMIT 1
			];

		System.assertEquals('Ingresado', cuenta.Estado_del_ultimo_modulo__c);
		System.assertEquals(listNewModuloPacientes[0].id, cuenta.Modulo_activo__c);
		System.assertEquals(testModulo.id, cuenta.Modulo__c);
	}



	static public void GetAccounts() {
		listNewAccounts = [SELECT id, Formulas_actuales__c FROM Account];
	}
	static public void newAccount(){
		listNewAccounts.add(Build.anAccountPacienteBestCare().withLastName('CuentaLastName').withCanalParaConsumidorBaby('Farmacias').withDNI('123456').build());
		insert listNewAccounts;
	}


	static public void CreateSimpleScheme() {

		listNewAccounts.add(Build.anAccountPacienteBestCare().withLastName('CuentaLastName').withCanalParaConsumidorBaby('Farmacias').withDNI('123456').build());
		insert listNewAccounts;

		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
		insert listNewModuloPacientes;

		listNewProductos.add(Build.aProduct2().withName('ProductName-P128').withhProductoSAP(true).withProductoPara('Best Care').build());
		insert listNewProductos;

		listNewProductoModulo.add(
			Build.aProductodemodulo()
		    .withFormula(listNewProductos[0])
		    .withCantidad('1 Unidad')
		    .withModulodepaciente(listNewModuloPacientes[0]).build()
		);
		insert listNewProductoModulo;
        

		expectedResult = 'ProductName-P128, 1 Unidad';
	}

	static public void CreateSimpleSchemeMultiProducts() {

		listNewAccounts.add(Build.anAccountPacienteBestCare().withLastName('CuentaLastName').withCanalParaConsumidorBaby('Farmacias').withDNI('123456').build());
		insert listNewAccounts;

		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
		insert listNewModuloPacientes;

		listNewProductos.add(Build.aProduct2().withName('ProductName-P128').withhProductoSAP(true).withProductoPara('Best Care').build());
		listNewProductos.add(Build.aProduct2().withName('ProductName-O256').withhProductoSAP(true).withProductoPara('Best Care').build());
		listNewProductos.add(Build.aProduct2().withName('ProductName-I512').withhProductoSAP(true).withProductoPara('Best Care').build());
		insert listNewProductos;

		listNewProductoModulo.add(
			Build.aProductodemodulo()
		    .withFormula(listNewProductos[0])
		    .withCantidad('2 Unidades')
		    .withModulodepaciente(listNewModuloPacientes[0]).build()
		);

		listNewProductoModulo.add(
			Build.aProductodemodulo()
		    .withFormula(listNewProductos[1])
		    .withCantidad('3 Unidades')
		    .withModulodepaciente(listNewModuloPacientes[0]).build()
		);

		listNewProductoModulo.add(
			Build.aProductodemodulo()
		    .withFormula(listNewProductos[2])
		    .withCantidad('4 Unidades')
		    .withModulodepaciente(listNewModuloPacientes[0]).build()
		);

		insert listNewProductoModulo;
		expectedResult = 'ProductName-P128, 2 Unidades' + '\r\n' + 'ProductName-O256, 3 Unidades' + '\r\n' + 'ProductName-I512, 4 Unidades';
	}

	static public void CreateSimpleSchemeMultiModulesAccount() {

		listNewAccounts.add(Build.anAccountPacienteBestCare().withLastName('CuentaLastName').withCanalParaConsumidorBaby('Farmacias').withDNI('123456').build());
		insert listNewAccounts;

		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
		insert listNewModuloPacientes;

		listNewProductos.add(Build.aProduct2().withName('ProductName-P128').withhProductoSAP(true).withProductoPara('Best Care').build());
		insert listNewProductos;

		listNewProductoModulo.add(
			Build.aProductodemodulo()
		    .withFormula(listNewProductos[0])
		    .withCantidad('2 Unidades')
		    .withModulodepaciente(listNewModuloPacientes[0]).build()
		);

		listNewProductoModulo.add(
			Build.aProductodemodulo()
		    .withFormula(listNewProductos[0])
		    .withCantidad('3 Unidades')
		    .withModulodepaciente(listNewModuloPacientes[1]).build()
		);

		listNewProductoModulo.add(
			Build.aProductodemodulo()
		    .withFormula(listNewProductos[0])
		    .withCantidad('4 Unidades')
		    .withModulodepaciente(listNewModuloPacientes[2]).build()
		);

		insert listNewProductoModulo;
		expectedResult = 'ProductName-P128, 2 Unidades' + '\r\n' + 'ProductName-P128, 3 Unidades' + '\r\n' + 'ProductName-P128, 4 Unidades';
	}

	static public void CreateMultiScheme() {

		listNewAccounts.add(Build.anAccountPacienteBestCare().withLastName('CuentaLastName').withCanalParaConsumidorBaby('Farmacias').withDNI('123452436').build());
		listNewAccounts.add(Build.anAccountPacienteBestCare().withLastName('CuentaLastNameClear').withCanalParaConsumidorBaby('Farmacias').withDNI('12345644').build());
		insert listNewAccounts;

		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[0]).withEstado('Activo').build());
		listNewModuloPacientes.add(Build.aModulodepaciente().withCuenta(listNewAccounts[1]).withEstado('Activo').build());
		insert listNewModuloPacientes;

		listNewProductos.add(Build.aProduct2().withName('ProductName-P128').withhProductoSAP(true).withProductoPara('Best Care').build());
		listNewProductos.add(Build.aProduct2().withName('ProductName-O256').withhProductoSAP(true).withProductoPara('Best Care').build());
		listNewProductos.add(Build.aProduct2().withName('ProductName-I512').withhProductoSAP(true).withProductoPara('Best Care').build());
		insert listNewProductos;

		listNewProductoModulo.add(
			Build.aProductodemodulo()
		    .withFormula(listNewProductos[0])
		    .withCantidad('2 Unidades')
		    .withModulodepaciente(listNewModuloPacientes[0]).build()
		);

		listNewProductoModulo.add(
			Build.aProductodemodulo()
		    .withFormula(listNewProductos[1])
		    .withCantidad('3 Unidades')
		    .withModulodepaciente(listNewModuloPacientes[0]).build()
		);

		listNewProductoModulo.add(
			Build.aProductodemodulo()
		    .withFormula(listNewProductos[2])
		    .withCantidad('4 Unidades')
		    .withModulodepaciente(listNewModuloPacientes[1]).build()
		);

		insert listNewProductoModulo;
		expectedResult = 'ProductName-O256, 3 Unidades' + '\r\n' + 'ProductName-P128, 2 Unidades' + '\r\n' + 'ProductName-I512, 4 Unidades';
	}
}