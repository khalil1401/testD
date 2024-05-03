@isTest
private class AddProductsTratamientoControllerTest  {
	
	private static testmethod void whenProductsAreSearchedAndThereAreNoProductsSaved_itShouldReturnAnEmptyList() {
		controller = new AddProductsTratamientoController(stdController);
		List<Product2> products = controller.getProductsBy('asd');
		System.assert(products.isEmpty());
	}
	
	private static testmethod void givenACriterion_itShouldBePossibleToObtainProductsThatContainIt() {
		controller = new AddProductsTratamientoController(stdController);
		product = Build.aProduct2().withName('Name').withDescription('Producto').withhProductoSAP(true).build();
		product.Producto_para__c = 'Best Care';
		insert product;

		Id [] fixedSearchResults = new Id[]{product.Id};
        Test.setFixedSearchResults(fixedSearchResults);
		
		Test.startTest();
		List<Product2> products = controller.getProductsBy('Prod');
		Test.stopTest();
		System.assertEquals(products.size(), 1);		
	}

	private static testmethod void ifThereAreNoSelectedItems_theGetSelectedMethodReturnsAnEmptyList() {
		controller = new AddProductsTratamientoController(stdController);
		product = Build.aProduct2().withName('Name').withDescription('Producto').withhProductoSAP(true).build();
		insert product;
		
		Test.startTest();
		List<AddProductsTratamientoController.WrapperProduct> products = controller.getSelected();
		Test.stopTest();
		System.assert(products.isEmpty());		
	}
	
	private static testmethod void ifThereIsAnItemSelected_TheGetSelectedMethodReturnsThatItem() {
		controller = new AddProductsTratamientoController(stdController);
		product = Build.aProduct2().withName('Name').withDescription('Producto').withhProductoSAP(true).build();
		insert product;

		AddProductsTratamientoController.WrapperProduct item = new AddProductsTratamientoController.WrapperProduct(product);
		item.isSelected = true;
		controller.wrapperProductsList = new List<AddProductsTratamientoController.WrapperProduct> {item};
		
		Test.startTest();
		List<AddProductsTratamientoController.WrapperProduct> products = controller.getSelected();
		Test.stopTest();
		System.assert(products.size() == 1);		
	}
	
	private static testmethod void ifThereIsASelectedProduct_itShouldBePossibleToAssociateItWithTheModule() {
		controller = new AddProductsTratamientoController(stdController);
		product = Build.aProduct2().withName('Name').withDescription('Producto').withhProductoSAP(true).build();
		insert product;
		AddProductsTratamientoController.WrapperProduct item = new AddProductsTratamientoController.WrapperProduct(product);
		item.isSelected = true;
		controller.wrapperProductsList = new List<AddProductsTratamientoController.WrapperProduct> {item};
		
		Test.startTest();
		controller.addProducts();
		Test.stopTest();
		List<Producto_de_paciente__c> newProducts = [SELECT id FROM Producto_de_paciente__c];
		System.assert(newProducts.size() == 1);		
	}
	
	private static testmethod void ifThereAreTwoSelectedProducts_itShouldBePossibleToAssociateThemWithTheModule() {
		controller = new AddProductsTratamientoController(stdController);
		product = Build.aProduct2().withName('Name').withDescription('Producto').withhProductoSAP(true).build();
		Product2 product1 = Build.aProduct2().withName('Name').withDescription('Producto').withhProductoSAP(true).build();
		
		List<Product2> products = new List<Product2> {product, product1}; 
		insert products;
		AddProductsTratamientoController.WrapperProduct item = new AddProductsTratamientoController.WrapperProduct(product);
		AddProductsTratamientoController.WrapperProduct item1 = new AddProductsTratamientoController.WrapperProduct(product1);
		item.isSelected = true;
		item1.isSelected = true;
		controller.wrapperProductsList = new List<AddProductsTratamientoController.WrapperProduct> {item, item1};
		
		Test.startTest();
		controller.addProducts();
		Test.stopTest();
		List<Producto_de_paciente__c> newProducts = [SELECT id FROM Producto_de_paciente__c];
		System.assert(newProducts.size() == 2);		
	}

	private static testmethod void ifThereAreElevenProductsAndThePageSizeIsTen_theActualPageShouldBeHaveTenItems() {
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				Build.aProduct2().withProductoParaBestCare().withName('Name'+i).withDescription('Producto'+i).withhProductoSAP(true).build());
		}
		insert listProd;

		controller = new AddProductsTratamientoController(stdController);
		System.assert(controller.actualPage.size() == 10);
		System.assert(controller.wrapperProductsList.size() == 11);		
	}

	private static testmethod void ifThereAreElevenProductsAndThePageSizeIsTen_theLastPageShouldBeHaveOneItems() {
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				Build.aProduct2().withProductoParaBestCare().withName('Name'+i).withDescription('Producto'+i).withhProductoSAP(true).build());
		}
		insert listProd;
		controller = new AddProductsTratamientoController(stdController);

		Test.startTest();
		controller.lastPage();
		Test.stopTest();

		System.assert(controller.actualPage.size() == 1);
		System.assert(controller.wrapperProductsList.size() == 11);		
	}

	private static testmethod void ifThereAreElevenProductsAndTheActualPageSizeIsTen_theNextPageShouldBeHaveOneItems() {
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				Build.aProduct2().withProductoParaBestCare().withName('Name'+i).withDescription('Producto'+i).withhProductoSAP(true).build());
		}
		insert listProd;
		controller = new AddProductsTratamientoController(stdController);

		Test.startTest();
		controller.next();
		Test.stopTest();

		System.assert(controller.actualPage.size() == 1);
		System.assert(controller.wrapperProductsList.size() == 11);		
	}

	private static testmethod void ifThereAreElevenProductsAndTheActualPageSizeIsOne_thePreviousPageShouldBeHaveTenItems() {
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				Build.aProduct2().withProductoParaBestCare().withName('Name'+i).withDescription('Producto'+i).withhProductoSAP(true).build());
		}
		insert listProd;
		controller = new AddProductsTratamientoController(stdController);

		Test.startTest();
		controller.next();
		controller.previous();
		Test.stopTest();

		System.assert(controller.actualPage.size() == 10);
		System.assert(controller.wrapperProductsList.size() == 11);		
	}

	private static testmethod void ifThereAreElevenProductsAndThePageSizeIsTwentyFive_theActualPageShouldBeHaveElevenItems() {
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				Build.aProduct2().withProductoParaBestCare().withName('Name'+i).withDescription('Producto'+i).withhProductoSAP(true).build());
		}
		insert listProd;
		controller = new AddProductsTratamientoController(stdController);

		Test.startTest();
		controller.pageSizeStr = '25';
		controller.changePageSize();
		Test.stopTest();
		System.assert(controller.actualPage.size() == 11);
		System.assert(controller.wrapperProductsList.size() == 11);		
	}

	private static testmethod void theGetItemsMethodShouldBeReturnAListOfOptions() {
		controller = new AddProductsTratamientoController(stdController);
		Test.startTest();
		List<SelectOption> options = controller.getItems();
		Test.stopTest();

		System.assert(options != null);		
	}

	static Product2 product;
	static Account acc, accObraSocial;
	static AddProductsTratamientoController controller;
	static Tratamiento__c Tratamiento;
	static ApexPages.StandardController stdController;

	static {
		acc = Build.anAccountPacienteRegular()
			.withLastName('LastName')
			.withRegimenDeInternacionDomiciliaria('Sí')
			.withEmpresadeinternaciondomiciliaria('Otra')				   
			.build();
		accObraSocial = Build.anAccountObrasocial()
			.withName('Prueba Xappia')			   
			.build();

		insert acc;
		insert accObraSocial;

		Tratamiento = Build.aTratamientoTratamientoRegular()
		.withObraSocial(accObraSocial)
		.withAccount(acc)
		.build();
		insert Tratamiento;
		stdController = new ApexPages.StandardController(Tratamiento);		
	}
}