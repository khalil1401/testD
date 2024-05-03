@isTest
private class AddProductsControllerTest  {
	
	private static testmethod void whenProductsAreSearchedAndThereAreNoProductsSaved_itShouldReturnAnEmptyList() {
		controller = new AddProductsController(stdController);
		List<Product2> products = controller.getProductsBy('asd');
		System.assert(products.isEmpty());
	}
	
	private static testmethod void givenACriterion_itShouldBePossibleToObtainProductsThatContainIt() {
		controller = new AddProductsController(stdController);
		product = Build.aProduct2().withProductoPara('Best Care').withName('Name').withDescription('Producto').build();
		insert product;

		Id [] fixedSearchResults = new Id[]{product.Id};
        Test.setFixedSearchResults(fixedSearchResults);
		
		Test.startTest();
		List<Product2> products = controller.getProductsBy('Prod');
		Test.stopTest();
		System.assertEquals(products.size(), 1);		
	}

	private static testmethod void ifThereAreNoSelectedItems_theGetSelectedMethodReturnsAnEmptyList() {
		controller = new AddProductsController(stdController);
		product = Build.aProduct2().withName('Name').withDescription('Producto').build();
		insert product;
		
		Test.startTest();
		List<AddProductsController.WrapperProduct> products = controller.productsToConfirmById.values();
		Test.stopTest();
		System.assert(products.isEmpty());		
	}
	
	private static testmethod void ifThereIsAnItemSelected_TheGetSelectedMethodReturnsThatItem() {
		controller = new AddProductsController(stdController);
		product = Build.aProduct2().withName('Name').withDescription('Producto').build();
		insert product;

		AddProductsController.WrapperProduct item = new AddProductsController.WrapperProduct(product);
		item.isSelected = true;
		controller.productsToConfirmById.put(item.product.Id, item);
		
		Test.startTest();
		List<AddProductsController.WrapperProduct> products = controller.productsToConfirmById.values();
		Test.stopTest();
		System.assertEquals(1, products.size());		
	}
	
	private static testmethod void ifThereIsASelectedProduct_itShouldBePossibleToAssociateItWithTheModule() {
		controller = new AddProductsController(stdController);
		product = Build.aProduct2().withName('Name').withDescription('Producto').build();
		insert product;
		AddProductsController.WrapperProduct item = new AddProductsController.WrapperProduct(product);
		item.isSelected = true;
		controller.productsToConfirmById.put(item.product.Id, item);
		
		Test.startTest();
		controller.addProducts();
		Test.stopTest();
		List<Producto_de_modulo__c> newProducts = [SELECT id FROM Producto_de_modulo__c];
		System.assertEquals(1, newProducts.size());		
	}
	
	private static testmethod void ifThereAreTwoSelectedProducts_itShouldBePossibleToAssociateThemWithTheModule() {
		controller = new AddProductsController(stdController);
		product = Build.aProduct2().withName('Name').withDescription('Producto').build();
		Product2 product1 = Build.aProduct2().withName('Name').withDescription('Producto').build();
		
		List<Product2> products = new List<Product2> {product, product1}; 
		insert products;
		AddProductsController.WrapperProduct item = new AddProductsController.WrapperProduct(product);
		AddProductsController.WrapperProduct item1 = new AddProductsController.WrapperProduct(product1);
		item.isSelected = true;
		item1.isSelected = true;
		controller.productsToConfirmById.put(item.product.Id, item);
		controller.productsToConfirmById.put(item1.product.Id, item1);
		
		Test.startTest();
		controller.addProducts();
		Test.stopTest();
		List<Producto_de_modulo__c> newProducts = [SELECT id FROM Producto_de_modulo__c];
		System.assertEquals(2, newProducts.size());		
	}

	@IsTest
	private static void doSelectAllMethod_ShouldSelectAllProductOfTheList() {
		List<Product2> products = new List<Product2>(); 
		for(Integer i = 0; i < 10; i++){
			product = Build.aProduct2()
				.withName('Name' + i)
				.withDescription('Producto' + i)
				.withProductoParaBestCare()
			.build();
			products.add(product);
		}
		insert products;
		
		controller = new AddProductsController(stdController);

		Test.startTest();
		controller.selectAll = true;
		controller.doSelectAll();
		Test.stopTest();
		
		List<AddProductsController.WrapperProduct> productsToAssert = controller.productsToConfirmById.values();

		System.assertEquals(10, productsToAssert.size());	
	}

	@IsTest
	private static void deselectAllMethod_ShoulddeselectAllProductOfTheList() {
		List<Product2> products = new List<Product2>(); 
		for(Integer i = 0; i < 10; i++){
			product = Build.aProduct2()
				.withName('Name' + i)
				.withDescription('Producto' + i)
				.withProductoParaBestCare()
			.build();
			products.add(product);
		}
		insert products;
		
		controller = new AddProductsController(stdController);
		controller.selectAll = true;
		controller.doSelectAll();

		Test.startTest();
		controller.deselectAll();
		Test.stopTest();
		
		List<AddProductsController.WrapperProduct> productsToAssert = controller.productsToConfirmById.values();

		System.assertEquals(0, productsToAssert.size());	
	}

	private static testmethod void ifThereAreElevenProductsAndThePageSizeIsTen_theActualPageShouldBeHaveTenItems() {
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				Build.aProduct2().withName('Name'+i).withProductoPara('Best Care').withDescription('Producto'+i).build());
		}
		insert listProd;

		controller = new AddProductsController(stdController);
		System.assert(controller.actualPage.size() == 10);
		System.assert(controller.wrapperProductsList.size() == 11);		
	}

	private static testmethod void ifThereAreElevenProductsAndThePageSizeIsTen_theLastPageShouldBeHaveOneItems() {
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				Build.aProduct2().withProductoPara('Best Care').withName('Name'+i).withDescription('Producto'+i).build());
		}
		insert listProd;
		controller = new AddProductsController(stdController);

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
				Build.aProduct2().withProductoPara('Best Care').withName('Name'+i).withDescription('Producto'+i).build());
		}
		insert listProd;
		controller = new AddProductsController(stdController);

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
				Build.aProduct2().withProductoPara('Best Care').withName('Name'+i).withDescription('Producto'+i).build());
		}
		insert listProd;
		controller = new AddProductsController(stdController);

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
				Build.aProduct2().withProductoPara('Best Care').withName('Name'+i).withDescription('Producto'+i).build());
		}
		insert listProd;
		controller = new AddProductsController(stdController);

		Test.startTest();
		controller.pageSizeStr = '25';
		controller.changePageSize();
		Test.stopTest();
		System.assert(controller.actualPage.size() == 11);
		System.assert(controller.wrapperProductsList.size() == 11);		
	}

	private static testmethod void theGetItemsMethodShouldBeReturnAListOfOptions() {
		controller = new AddProductsController(stdController);
		Test.startTest();
		List<SelectOption> options = controller.getItems();
		Test.stopTest();

		System.assert(options != null);		
	}

	@IsTest
	private static void whenASearchedProductIsSelected_HaveToBeAddToTheConfirmTable(){
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				Build.aProduct2().withProductoPara('Best Care').withName('Name'+i).withDescription('Producto'+i).build());
		}
		insert listProd;
		
		controller = new AddProductsController(stdController);

		AddProductsController.WrapperProduct wrapperProductToTest = controller.actualPage.values()[0];

		PageReference pageRef = Page.AddProducts;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		wrapperProductToTest.isSelected = true;
		ApexPages.currentPage().getParameters().put(
			'searchProductIdSelect', 
			wrapperProductToTest.product.Id
		);
		ApexPages.currentPage().getParameters().put(
			'searchProductQuantity', 
			String.valueOf(wrapperProductToTest.quantity)
		);
		controller.saveSelectedProducts();
		Test.stopTest();

		System.assertEquals(1, controller.productsToConfirmById.size());
	}

	@IsTest
	private static void whenASearchedProductAlredySelectedIsDeselected_HaveToBeRemoveFromTheConfirmTable(){
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				Build.aProduct2().withProductoPara('Best Care').withName('Name'+i).withDescription('Producto'+i).build());
		}
		insert listProd;
		
		controller = new AddProductsController(stdController);

		AddProductsController.WrapperProduct wrapperProductToTest = controller.actualPage.values()[0];

		PageReference pageRef = Page.AddProducts;
		Test.setCurrentPage(pageRef);
		Test.startTest();

		wrapperProductToTest.isSelected = true;
		ApexPages.currentPage().getParameters().put(
			'searchProductIdSelect', 
			wrapperProductToTest.product.Id
		);
		ApexPages.currentPage().getParameters().put(
			'searchProductQuantity', 
			String.valueOf(wrapperProductToTest.quantity)
		);
		controller.saveSelectedProducts();

		wrapperProductToTest.isSelected = false;
		ApexPages.currentPage().getParameters().put(
			'searchProductIdSelect', 
			wrapperProductToTest.product.Id
		);
		ApexPages.currentPage().getParameters().put(
			'searchProductQuantity', 
			String.valueOf(wrapperProductToTest.quantity)
		);
		controller.saveSelectedProducts();

		Test.stopTest();

		System.assertEquals(0, controller.productsToConfirmById.size());
	}

	@IsTest
	private static void whenASearchedProductSelectedChangeQuantity_HaveToChangeInTheConfirmTableToo(){
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				Build.aProduct2().withProductoPara('Best Care').withName('Name'+i).withDescription('Producto'+i).build());
		}
		insert listProd;
		
		controller = new AddProductsController(stdController);

		AddProductsController.WrapperProduct wrapperProductToTest = controller.actualPage.values()[0];

		PageReference pageRef = Page.AddProducts;
		Test.setCurrentPage(pageRef);
		Test.startTest();
		
		wrapperProductToTest.isSelected = true;
		ApexPages.currentPage().getParameters().put(
			'searchProductIdSelect', 
			wrapperProductToTest.product.Id
		);
		ApexPages.currentPage().getParameters().put(
			'searchProductQuantity', 
			String.valueOf(wrapperProductToTest.quantity)
		);
		controller.saveSelectedProducts();

		wrapperProductToTest.quantity = 50;
		ApexPages.currentPage().getParameters().put(
			'searchProductIdSelect', 
			wrapperProductToTest.product.Id
		);
		ApexPages.currentPage().getParameters().put(
			'searchProductQuantity', 
			String.valueOf(wrapperProductToTest.quantity)
		);
		controller.saveSelectedProducts();

		Test.stopTest();

		System.assertEquals(50, controller.productsToConfirmById.get(wrapperProductToTest.product.Id).quantity);
	}

	static Product2 product;
	static Account acc;
	static AddProductsController controller;
	static Modulo_de_paciente__c modulo;
	static ApexPages.StandardController stdController;

	static {
		acc = Build.anAccountPacienteBestCare()
				   .withLastName('Name Test')
				   .withRegimenDeInternacionDomiciliaria('Sí')
				   .withEmpresadeinternaciondomiciliaria('Best care')				   
				   .build();
        acc.DNI__c = '123456';
        acc.Canal_para_Consumidor_Baby__c = 'Farmacias';
        
		insert acc;
		modulo = Build.aModulodepaciente().withCuenta(acc).build();
		insert modulo;
		stdController = new ApexPages.StandardController(modulo);		
	}
}