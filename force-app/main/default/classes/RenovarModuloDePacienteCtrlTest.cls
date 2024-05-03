@IsTest
public class RenovarModuloDePacienteCtrlTest {

	@IsTest
	static void inTheView_renewModuloDePacienteAndReleatedProducts_SearchProductEmpty_RenewModuloDePacienteDesdeEqualsOriginModuloDePacienteHasta() {
		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);
		Test.startTest();
		controller.renewModuloDePaciente();
		Test.stopTest();

		System.assertEquals(true, controller.searchProducts.isEmpty());

		String renewModuloDePacienteId = controller.renewModuloUrl.substringAfter('/');
		Modulo_de_paciente__c moduloDePacienteToAssert = [
            SELECT Id,
            Modulo_desde__c,
            Modulo__c,
            Duracion_modulo__c,
            Renovacion__c,
            Cuenta__c,
            Estado__c
            FROM Modulo_de_paciente__c
            WHERE Id = :renewModuloDePacienteId
		                                                 ];

		System.assertEquals(accountToTest.Id, moduloDePacienteToAssert.Cuenta__c);
		System.assertEquals(moduloDePacienteToTest.Modulo__c, moduloDePacienteToAssert.Modulo__c);
		System.assertEquals(moduloDePacienteToTest.Duracion_modulo__c, moduloDePacienteToAssert.Duracion_modulo__c);
		System.assertEquals('Renovacion', moduloDePacienteToAssert.Renovacion__c);
		System.assertEquals(Date.today(), moduloDePacienteToAssert.Modulo_desde__c);
		System.assertEquals('Activo', moduloDePacienteToAssert.Estado__c);

		List<Producto_de_modulo__c> productosDeModuloToAssert = [
		                                                         SELECT Id,
		                                                         Modulo_de_paciente__c
		                                                         FROM Producto_de_modulo__c
		                                                         WHERE Modulo_de_paciente__c = :renewModuloDePacienteId
		                                                        ];

		System.assertEquals(5, productosDeModuloToAssert.size());
	}

	@IsTest
	static void inTheView_renewModuloDePaciente_DeSelectOriginModuloDePacienteReleatedProducts_SelectAllNewProduct() {

		List<Product2> newProductOfModuloDePacienteToTest = new List<Product2> ();
		for (Integer i = 5; i< 10; i++) {
			newProductOfModuloDePacienteToTest.add(
			                                       Build.aProduct2()
			                                       .withProductoPara('Best Care')
			                                       .withName('Product Test' + i)
			                                       .withDescription('To Testing' + i)
                								   .withhProductoSAP(true)
			                                       .build()
			);
		}
		insert newProductOfModuloDePacienteToTest;

		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);

		controller.existProductSelectAll = false;
		controller.doExistProductSelectAll();

		controller.searchSelectAll = true;
		controller.doSearchProductsSelectAll();

		Test.startTest();
		controller.renewModuloDePaciente();
		Test.stopTest();

		System.assertEquals(false, controller.searchProducts.isEmpty());
		System.assertEquals(5, controller.searchProducts.size());

		String renewModuloDePacienteId = controller.renewModuloUrl.substringAfter('/');
		Modulo_de_paciente__c moduloDePacienteToAssert = [
		                                                  SELECT Id,
		                                                  Modulo_desde__c,
		                                                  Modulo__c,
		                                                  Duracion_modulo__c,
		                                                  Renovacion__c,
		                                                  Cuenta__c,
		                                                  Estado__c
		                                                  FROM Modulo_de_paciente__c
		                                                  WHERE Id = :renewModuloDePacienteId
		                                                 ];

		System.assertEquals(accountToTest.Id, moduloDePacienteToAssert.Cuenta__c);
		System.assertEquals(moduloDePacienteToTest.Modulo__c, moduloDePacienteToAssert.Modulo__c);
		System.assertEquals(moduloDePacienteToTest.Duracion_modulo__c, moduloDePacienteToAssert.Duracion_modulo__c);
		System.assertEquals('Renovacion', moduloDePacienteToAssert.Renovacion__c);
		System.assertEquals(Date.today(), moduloDePacienteToAssert.Modulo_desde__c);
		System.assertEquals('Activo', moduloDePacienteToAssert.Estado__c);

		List<Producto_de_modulo__c> productosDeModuloToAssert = [
		                                                         SELECT Id,
		                                                         Modulo_de_paciente__c
		                                                         FROM Producto_de_modulo__c
		                                                         WHERE Modulo_de_paciente__c = :renewModuloDePacienteId
		                                                        ];

		System.assertEquals(5, productosDeModuloToAssert.size());
	}

	@IsTest
	static void inTheView_renewModuloDePaciente_DeselectOriginModuloDePacienteReleatedProducts_SelectOneNewProductOnly() {

		List<Product2> newProductOfModuloDePacienteToTest = new List<Product2> ();
		for (Integer i = 5; i< 10; i++) {
			newProductOfModuloDePacienteToTest.add(
			                                       Build.aProduct2()
			                                       .withProductoPara('Best Care')
			                                       .withName('Product Test' + i)
			                                       .withDescription('To Testing' + i)
                								   .withhProductoSAP(true)
			                                       .build()
			);
		}
		insert newProductOfModuloDePacienteToTest;

		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);

		controller.existProductSelectAll = false;
		controller.doExistProductSelectAll();

		RenovarModuloDePacienteCtrl.WrapperProduct newProductSelected = controller.actualSearchProductsPage.values() [0];
		ApexPages.currentPage().getParameters().put('searchProductIdSelect', newProductSelected.product.Id);
		newProductSelected.isSelected = true;
		controller.setProductsToConfirmThruSelectedSearchedProducts();

		Test.startTest();
		controller.renewModuloDePaciente();
		Test.stopTest();

		String renewModuloDePacienteId = controller.renewModuloUrl.substringAfter('/');
		Modulo_de_paciente__c moduloDePacienteToAssert = [
		                                                  SELECT Id,
		                                                  Modulo_desde__c,
		                                                  Modulo__c,
		                                                  Duracion_modulo__c,
		                                                  Renovacion__c,
		                                                  Cuenta__c,
		                                                  Estado__c
		                                                  FROM Modulo_de_paciente__c
		                                                  WHERE Id = :renewModuloDePacienteId
		                                                 ];

		System.assertEquals(accountToTest.Id, moduloDePacienteToAssert.Cuenta__c);
		System.assertEquals(moduloDePacienteToTest.Modulo__c, moduloDePacienteToAssert.Modulo__c);
		System.assertEquals(moduloDePacienteToTest.Duracion_modulo__c, moduloDePacienteToAssert.Duracion_modulo__c);
		System.assertEquals('Renovacion', moduloDePacienteToAssert.Renovacion__c);
		System.assertEquals(Date.today(), moduloDePacienteToAssert.Modulo_desde__c);
		System.assertEquals('Activo', moduloDePacienteToAssert.Estado__c);

		List<Producto_de_modulo__c> productosDeModuloToAssert = [
		                                                         SELECT Id,
		                                                         Modulo_de_paciente__c
		                                                         FROM Producto_de_modulo__c
		                                                         WHERE Modulo_de_paciente__c = :renewModuloDePacienteId
		                                                        ];

		System.assertEquals(1, productosDeModuloToAssert.size());
	}

	@IsTest
	static void givenACriterion_itShouldBePossibleToObtainProductsThatContainIt() {
		Product2 product = Build.aProduct2()
		.withProductoPara('Best Care')
		.withName('Name')
		.withDescription('Producto')
        .withhProductoSAP(true)
		.build();
		insert product;

		Id[] fixedSearchResults = new Id[] { product.Id };
		Test.setFixedSearchResults(fixedSearchResults);

		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);

		controller.criteria = 'Prod';

		Test.startTest();
		controller.findProducts();
		Test.stopTest();

		System.assertEquals(1, controller.actualSearchProductsPage.size());
	}

	@IsTest
	static void ifThereAreElevenProductsAndThePageSizeIsTen_theLastPageShouldBeHaveOneItems() {
		List<Product2> productsToTest = new List<Product2> ();
		for (Integer i = 0; i< 11; i++) {
			productsToTest.add(
			                   Build.aProduct2()
			                   .withProductoPara('Best Care')
			                   .withName('Name' + i)
			                   .withDescription('Producto' + i)
                			   .withhProductoSAP(true)
			                   .build()
			);
		}
		insert productsToTest;

		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);

		Test.startTest();
		controller.lastPage();
		Test.stopTest();

		System.assertEquals(1, controller.actualSearchProductsPage.size());
		System.assertEquals(11, controller.searchProducts.size());
	}

	@IsTest
	static void inTheView_setCantidadDeRegistrosMostradosIn25_navegateWithNextButtonToTheLastPage_theLastPageShouldBeHave10Items() {
		List<Product2> productsToTest = new List<Product2> ();
		for (Integer i = 0; i< 60; i++) {
			productsToTest.add(
			                   Build.aProduct2()
			                   .withProductoPara('Best Care')
			                   .withName('Name' + i)
			                   .withDescription('Producto' + i)
                			   .withhProductoSAP(true)
			                   .build()
			);
		}
		insert productsToTest;

		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);

		SelectOption pageSizeViewOptionSelected = controller.getItems() [1];
		String pageSizeView = pageSizeViewOptionSelected.getValue();
		controller.pageSizeStr = pageSizeView;

		Test.startTest();
		controller.changePageSize();
		controller.next();
		controller.next();
		Test.stopTest();

		System.assertEquals(10, controller.actualSearchProductsPage.size());
		System.assertEquals(60, controller.searchProducts.size());
		System.assertEquals(3, controller.actualPageNumber);
		System.assertEquals(3, controller.numPages);
	}

	@IsTest
	static void givenACriterion_NavegateTheResult_searchAgainByTheSameCriterionShouldGoToTheFirstPage() {
		List<Product2> productsToTest = new List<Product2> ();
		for (Integer i = 0; i< 60; i++) {
			productsToTest.add(
			                   Build.aProduct2()
			                   .withProductoPara('Best Care')
			                   .withName('Name' + i)
			                   .withDescription('Producto' + i)
                			   .withhProductoSAP(true)
			                   .build()
			);
		}
		insert productsToTest;

		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);

		controller.criteria = 'Prod';
		controller.findProducts();
		controller.next();
		controller.next();
		controller.previous();

		Test.startTest();
		controller.criteria = 'Prod';
		controller.findProducts();
		Test.stopTest();

		System.assertEquals(10, controller.actualSearchProductsPage.size());
		System.assertEquals(60, controller.searchProducts.size());
		System.assertEquals(1, controller.actualPageNumber);
		System.assertEquals(7, controller.numPages);
	}

	@IsTest
	static void whenAModuloHaveExistProduct_DeselectOneProduct_confirmProductNotHaveTheDeselectedProduct() {
		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);
		RenovarModuloDePacienteCtrl.WrapperProduct wrapperProductToTest =
		controller.existProductsById.values() [0];

		wrapperProductToTest.isSelected = false;

		PageReference pageRef = Page.RenovarModuloDePaciente;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		ApexPages.currentPage().getParameters().put(
		                                            'existProductIdSelect',
		                                            wrapperProductToTest.product.Id
		);
		ApexPages.currentPage().getParameters().put(
		                                            'existProductQuantity',
		                                            String.valueOf(wrapperProductToTest.quantity)
		);
		controller.setProductsToConfirmThruExistSelected();
		Test.stopTest();

		System.assertEquals(5, controller.existProductsById.size());
		System.assertEquals(4, controller.productsToConfirm.size());
	}

	@IsTest
	static void whenAModuloHaveExistProduct_ChangeQuantityOfOneProduct_confirmProductHaveTheProductQuantityChangedToo() {
		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);
		RenovarModuloDePacienteCtrl.WrapperProduct wrapperProductToTest =
		controller.existProductsById.values() [0];

		PageReference pageRef = Page.RenovarModuloDePaciente;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		wrapperProductToTest.quantity = 50;
		ApexPages.currentPage().getParameters().put(
		                                            'existProductIdSelect',
		                                            wrapperProductToTest.product.Id
		);
		ApexPages.currentPage().getParameters().put(
		                                            'existProductQuantity',
		                                            String.valueOf(wrapperProductToTest.quantity)
		);
		controller.setProductsToConfirmThruExistSelected();
		Test.stopTest();

		System.assertEquals(wrapperProductToTest.quantity, controller.existProductsById.get(wrapperProductToTest.product.Id).quantity);
	}

	@IsTest
	static void inTheView_selectAllSearchedProduct_ThenDeselectAll_ProductToConfirmHaveOnlyExistingProducts() {
		List<Product2> productsToTest = new List<Product2> ();
		for (Integer i = 0; i< 60; i++) {
			productsToTest.add(
			                   Build.aProduct2()
			                   .withProductoPara('Best Care')
			                   .withName('Name' + i)
			                   .withDescription('Producto' + i)
                			   .withhProductoSAP(true)
			                   .build()
			);
		}
		insert productsToTest;

		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);

		RenovarModuloDePacienteCtrl.WrapperProduct wrapperProductToTest = controller.actualSearchProductsPage.values() [0];

		PageReference pageRef = Page.RenovarModuloDePaciente;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		ApexPages.currentPage().getParameters().put(
		                                            'searchProductIdSelect',
		                                            wrapperProductToTest.product.Id
		);
		ApexPages.currentPage().getParameters().put(
		                                            'searchProductQuantity',
		                                            String.valueOf(wrapperProductToTest.quantity)
		);
		controller.doSearchProductsSelectAll();
		controller.doSearchedDeselectAll();
		Test.stopTest();

		System.assertEquals(controller.existProductsById.size(), controller.productsToConfirm.size());
	}

	@IsTest
	static void whenAModuloDePaciente_SelectSearchedProduct_ThenChangeTheQuantity_confirmProductHaveProductAndTheProductQuantityChangedToo() {
		List<Product2> productsToTest = new List<Product2> ();
		for (Integer i = 0; i< 60; i++) {
			productsToTest.add(
			                   Build.aProduct2()
			                   .withProductoPara('Best Care')
			                   .withName('Name' + i)
			                   .withDescription('Producto' + i)
                			   .withhProductoSAP(true)
			                   .build()
			);
		}
		insert productsToTest;

		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);

		RenovarModuloDePacienteCtrl.WrapperProduct wrapperProductToTest = controller.actualSearchProductsPage.values() [0];

		PageReference pageRef = Page.RenovarModuloDePaciente;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		//Select the searched product
		wrapperProductToTest.isSelected = true;
		ApexPages.currentPage().getParameters().put(
		                                            'searchProductIdSelect',
		                                            wrapperProductToTest.product.Id
		);
		ApexPages.currentPage().getParameters().put(
		                                            'searchProductQuantity',
		                                            String.valueOf(wrapperProductToTest.quantity)
		);
		controller.setProductsToConfirmThruSelectedSearchedProducts();
		//Change quantity in searched product
		wrapperProductToTest.quantity = 50;
		ApexPages.currentPage().getParameters().put(
		                                            'searchProductIdSelect',
		                                            wrapperProductToTest.product.Id
		);
		ApexPages.currentPage().getParameters().put(
		                                            'searchProductQuantity',
		                                            String.valueOf(wrapperProductToTest.quantity)
		);
		controller.setProductsToConfirmThruSelectedSearchedProducts();
		Test.stopTest();

		System.assertEquals(50, controller.productsToConfirm.get(wrapperProductToTest.product.Id).quantity);
	}

	@IsTest
	static void inTheView_renewModuloDePaciente_SelectAllNewProduct() {

		List<Product2> newProductOfModuloDePacienteToTest = new List<Product2> ();
		for (Integer i = 0; i< 500; i++) {
			newProductOfModuloDePacienteToTest.add(
			                                       Build.aProduct2()
			                                       .withProductoPara('Best Care')
			                                       .withName('Product Test' + i)
			                                       .withDescription('To Testing' + i)
                								   .withhProductoSAP(true)
			                                       .build()
			);
		}
		insert newProductOfModuloDePacienteToTest;

		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);

		Test.startTest();
		//deselect all exist products
		controller.existProductSelectAll = false;
		controller.doExistProductSelectAll();

		//select all searchedProducts
		//First page
		controller.searchSelectAll = true;
		controller.doSearchProductsSelectAll();

		for (Integer i = 1; i< 50; i++) {
			controller.next();
			controller.searchSelectAll = true;
			controller.doSearchProductsSelectAll();
		}
		//click Renovar button
		controller.renewModuloDePaciente();
		Test.stopTest();

		System.assertEquals(false, controller.searchProducts.isEmpty());
		System.assertEquals(500, controller.searchProducts.size());

		String renewModuloDePacienteId = controller.renewModuloUrl.substringAfter('/');
		Modulo_de_paciente__c moduloDePacienteToAssert = [
		                                                  SELECT Id,
		                                                  Modulo_desde__c,
		                                                  Modulo__c,
		                                                  Duracion_modulo__c,
		                                                  Renovacion__c,
		                                                  Cuenta__c,
		                                                  Estado__c
		                                                  FROM Modulo_de_paciente__c
		                                                  WHERE Id = :renewModuloDePacienteId
		                                                 ];

		System.assertEquals(accountToTest.Id, moduloDePacienteToAssert.Cuenta__c);
		System.assertEquals(moduloDePacienteToTest.Modulo__c, moduloDePacienteToAssert.Modulo__c);
		System.assertEquals(moduloDePacienteToTest.Duracion_modulo__c, moduloDePacienteToAssert.Duracion_modulo__c);
		System.assertEquals('Renovacion', moduloDePacienteToAssert.Renovacion__c);
		System.assertEquals(Date.today(), moduloDePacienteToAssert.Modulo_desde__c);
		System.assertEquals('Activo', moduloDePacienteToAssert.Estado__c);

		List<Producto_de_modulo__c> productosDeModuloToAssert = [
		                                                         SELECT Id,
		                                                         Modulo_de_paciente__c
		                                                         FROM Producto_de_modulo__c
		                                                         WHERE Modulo_de_paciente__c = :renewModuloDePacienteId
		                                                        ];

		System.assertEquals(500, productosDeModuloToAssert.size());
	}


	@IsTest
	static void verifyThatModuloDesdeSameThatModuloHasta() {

		moduloDePacienteToTest.Modulo_hasta__c = System.today().addDays(2);
		update moduloDePacienteToTest;

		List<Product2> newProductOfModuloDePacienteToTest = new List<Product2> ();
		for (Integer i = 0; i< 500; i++) {
			newProductOfModuloDePacienteToTest.add(
			                                       Build.aProduct2()
			                                       .withProductoPara('Best Care')
			                                       .withName('Product Test' + i)
			                                       .withDescription('To Testing' + i)
                								   .withhProductoSAP(true)
			                                       .build()
			);
		}
		insert newProductOfModuloDePacienteToTest;

		stdController = new ApexPages.StandardController(moduloDePacienteToTest);
		controller = new RenovarModuloDePacienteCtrl(stdController);

		Test.startTest();
		//deselect all exist products
		controller.existProductSelectAll = false;
		controller.doExistProductSelectAll();

		//select all searchedProducts
		//First page
		controller.searchSelectAll = true;
		controller.doSearchProductsSelectAll();

		for (Integer i = 1; i< 50; i++) {
			controller.next();
			controller.searchSelectAll = true;
			controller.doSearchProductsSelectAll();
		}
		controller.renewModuloDePaciente();
		Test.stopTest();


		String renewModuloDePacienteId = controller.renewModuloUrl.substringAfter('/');
		Modulo_de_paciente__c moduloDePacienteToAssert = [
		                                                  SELECT Id,
		                                                  Modulo_desde__c,
		                                                  Modulo__c,
		                                                  Duracion_modulo__c,
		                                                  Renovacion__c,
		                                                  Cuenta__c,
		                                                  Estado__c
		                                                  FROM Modulo_de_paciente__c
		                                                  WHERE Id = :renewModuloDePacienteId
		                                                 ];

		System.assertEquals(accountToTest.Id, moduloDePacienteToAssert.Cuenta__c);
		System.assertEquals(moduloDePacienteToTest.Modulo__c, moduloDePacienteToAssert.Modulo__c);
		System.assertEquals(moduloDePacienteToTest.Duracion_modulo__c, moduloDePacienteToAssert.Duracion_modulo__c);
		System.assertEquals('Renovacion', moduloDePacienteToAssert.Renovacion__c);
		System.assertEquals(moduloDePacienteToTest.Modulo_hasta__c, moduloDePacienteToAssert.Modulo_desde__c);
		System.assertEquals('Activo', moduloDePacienteToAssert.Estado__c);
	}
    
    
    

	static ApexPages.StandardController stdController;
	static RenovarModuloDePacienteCtrl controller;
	static Account accountToTest;
	static Modulo__c moduloToTest;
	static Modulo_de_paciente__c moduloDePacienteToTest;
	static List<Product2> productOfModuloDePacienteToTest;
	static List<Producto_de_modulo__c> productosDeModuloToTest;

	static {
		accountToTest = Build.anAccountPacienteBestCare()
		.withLastName('Name Test')
		.withRegimenDeInternacionDomiciliaria('Sí')
		.withEmpresadeinternaciondomiciliaria('Best care')
		.withCanalParaConsumidorBaby('Almacen')
		.build();
		insert accountToTest;

		moduloToTest = Build.aModulo()
		.withName('A-Care 1.10')
		.withDescripcion('Despacho de productos para terapia nutricional: APLV/Alergias alimentarias múltiples Gold- oral h/10')
		.build();
		insert moduloToTest;

		moduloDePacienteToTest = Build.aModulodepaciente()
		.withModulodesde(Date.newInstance(2019, 5, 11))
		.withModulo(moduloToTest)
		.withDuracion(20)
		.withCuenta(accountToTest)
		.withModulohasta(Date.newInstance(2019, 5, 31))
		.build();
		insert moduloDePacienteToTest;
        
        Servicios_del_Modulo__c servicioToTest = new Servicios_del_Modulo__c();
        servicioToTest.Modulo_de_paciente__c = moduloDePacienteToTest.id;
        servicioToTest.Servicios_disponibles__c = 'Servicio visita nutricional';
        servicioToTest.Cantidad__c = 5;
		
        insert servicioToTest;
        
		productOfModuloDePacienteToTest = new List<Product2> ();
		for (Integer i = 0; i< 5; i++) {
			productOfModuloDePacienteToTest.add(
			                                    Build.aProduct2()
			                                    .withProductoPara('Best Care')
			                                    .withName('Test' + i)
			                                    .withDescription('To Testing' + i)
                								.withhProductoSAP(true)
			                                    .build()
			);
		}
		insert productOfModuloDePacienteToTest;

		productosDeModuloToTest = new List<Producto_de_modulo__c> ();
		for (Product2 product : productOfModuloDePacienteToTest) {
			Producto_de_modulo__c productoDeModuloToTest = new Producto_de_modulo__c();
			productoDeModuloToTest.Formula__c = product.Id;
			productoDeModuloToTest.Cantidad__c = '10';
			productoDeModuloToTest.Modulo_de_paciente__c = moduloDePacienteToTest.Id;
			productosDeModuloToTest.add(productoDeModuloToTest);
		}
		insert productosDeModuloToTest;
	}
}