@isTest
private class ProductosActivosCompaniaTriggerTest {


	@isTest static void ifAProductosActivosWithStatusEntregadoOrPorRetirarAndModuloDePacienteAssociatedIsInsertedTheModuloPacienteIsUpdatedTheCountFieldOfProducts() {

		Productos_Activos_Compania__c productosActivos = Build.aProductosActivosCompania()
			.withEstado('Entregado')
			.withModulodepaciente(moduloPaciente)
			.build();
		
		Test.startTest();
		insert productosActivos;
		Test.stopTest();

		Modulo_de_paciente__c updateModuloPaciente = [
			SELECT Cont_Productos_Activos_Compania__c 
			FROM Modulo_de_paciente__c 
			WHERE Id = :moduloPaciente.Id
		];

		System.assertEquals(1, updateModuloPaciente.Cont_Productos_Activos_Compania__c);
	}

	@isTest static void whenANewProductosActivosCompaniaIsCreatedTheModuloPacienteFieldContProductosActivosCompaniaIsUpdated() {

		Productos_Activos_Compania__c productosActivos = Build.aProductosActivosCompania()
			.withEstado('Entregado')
			.withModulodepaciente(moduloPaciente)
			.build();
		insert productosActivos;

		Modulo_de_paciente__c updateModuloPaciente = [
			SELECT Cont_Productos_Activos_Compania__c 
			FROM Modulo_de_paciente__c 
			WHERE Id = :moduloPaciente.Id
		];
		
		Productos_Activos_Compania__c productosActivos2 = Build.aProductosActivosCompania()
			.withEstado('Por retirar')
			.withModulodepaciente(moduloPaciente)
			.build();

		Test.startTest();
		insert productosActivos2;
		Test.stopTest();

		Modulo_de_paciente__c updateModuloPaciente2 = [
			SELECT Cont_Productos_Activos_Compania__c 
			FROM Modulo_de_paciente__c 
			WHERE Id = :moduloPaciente.Id
		];
		
		System.assertEquals(2, updateModuloPaciente2.Cont_Productos_Activos_Compania__c);
		System.assertNotEquals(
			updateModuloPaciente.Cont_Productos_Activos_Compania__c,
			updateModuloPaciente2.Cont_Productos_Activos_Compania__c
		);
		
	}

	@isTest static void ifAProductosActivosWithoutStatusAndModuloDePacienteAssociatedIsInserted_TheModuloPacienteNotUpdatedTheFieldCountOfProducts() {

		Productos_Activos_Compania__c productosActivos = Build.aProductosActivosCompania()
			.withEstado('Retirado')
			.withModulodepaciente(moduloPaciente)
			.build();

		Test.startTest();
		insert productosActivos;
		Test.stopTest();

		Modulo_de_paciente__c updateModuloPaciente = [
			SELECT Cont_Productos_Activos_Compania__c 
			FROM Modulo_de_paciente__c 
			WHERE Id = :moduloPaciente.Id
		];

		System.assertEquals(0, updateModuloPaciente.Cont_Productos_Activos_Compania__c);
	}

	@isTest static void ifAProductosActivosWithoutModuloDePacienteAssociatedIsInserted_TheModuloPacienteNotUpdatedTheFieldCountOfProducts() {

		Productos_Activos_Compania__c productosActivos = Build.aProductosActivosCompania()
			.withEstado('Entregado')
			.build();

		Test.startTest();
		insert productosActivos;
		Test.stopTest();

		Modulo_de_paciente__c updateModuloPaciente = [
			SELECT Cont_Productos_Activos_Compania__c 
			FROM Modulo_de_paciente__c 
			WHERE Id = :moduloPaciente.Id
		];

		System.assertEquals(0, updateModuloPaciente.Cont_Productos_Activos_Compania__c);
	}

	@isTest static void whenAProductosActivosIsDeleteTheModuloPacienteFieldCountFieldCountOfProductsIsUpdated() {

		Productos_Activos_Compania__c productosActivos = Build.aProductosActivosCompania()
			.withEstado('Por retirar')
			.withModulodepaciente(moduloPaciente)
			.build();
		insert productosActivos;

		Productos_Activos_Compania__c productosActivos2 = Build.aProductosActivosCompania()
			.withEstado('Entregado')
			.withModulodepaciente(moduloPaciente)
			.build();
		insert productosActivos2;

		Test.startTest();
		delete productosActivos2;
		Test.stopTest();

		Modulo_de_paciente__c updateModuloPaciente = [
			SELECT Cont_Productos_Activos_Compania__c 
			FROM Modulo_de_paciente__c 
			WHERE Id = :moduloPaciente.Id
		];

		System.assertEquals(1, updateModuloPaciente.Cont_Productos_Activos_Compania__c);
	}

	@isTest static void whenAProductosActivosIsChangedStatusTheModuloPacienteFieldCountFieldCountOfProductsIsUpdated() {

		Productos_Activos_Compania__c productosActivos = Build.aProductosActivosCompania()
			.withEstado('Por retirar')
			.withModulodepaciente(moduloPaciente)
			.build();
		insert productosActivos;

		Modulo_de_paciente__c updateModuloPaciente = [
			SELECT Cont_Productos_Activos_Compania__c 
			FROM Modulo_de_paciente__c 
			WHERE Id = :moduloPaciente.Id
		];

		productosActivos.Estado__c = 'Retirado';
		Test.startTest();
		update productosActivos;
		Test.stopTest();

		Modulo_de_paciente__c updateModuloPaciente2 = [
			SELECT Cont_Productos_Activos_Compania__c 
			FROM Modulo_de_paciente__c 
			WHERE Id = :moduloPaciente.Id
		];

		System.assertEquals(1, updateModuloPaciente.Cont_Productos_Activos_Compania__c);
		System.assertEquals(0, updateModuloPaciente2.Cont_Productos_Activos_Compania__c);
	}

	@isTest static void whenAProductosActivosIsUndeleteTheModuloPacienteFieldCountFieldCountOfProductsIsUpdated() {

		Productos_Activos_Compania__c productosActivos = Build.aProductosActivosCompania()
			.withEstado('Por retirar')
			.withModulodepaciente(moduloPaciente)
			.build();
		insert productosActivos;
		delete productosActivos;

		Test.startTest();
		undelete productosActivos;
		Test.stopTest();

		Modulo_de_paciente__c updateModuloPaciente = [
			SELECT Cont_Productos_Activos_Compania__c 
			FROM Modulo_de_paciente__c 
			WHERE Id = :moduloPaciente.Id
		];

		System.assertEquals(1, updateModuloPaciente.Cont_Productos_Activos_Compania__c);
	}

	static Modulo_de_paciente__c moduloPaciente;
	static Account cuentaTest;
	static {

		cuentaTest = Build.anAccountPacienteBestCare()
						.withLastName('Name Test')
						.withRegimenDeInternacionDomiciliaria('Sí')
						.withEmpresadeinternaciondomiciliaria('Best care')				   
						.build();
		insert cuentaTest;

		moduloPaciente = Build.aModulodepaciente()
			.withCuenta(cuentaTest)
			.build();
		insert moduloPaciente;

	}

}