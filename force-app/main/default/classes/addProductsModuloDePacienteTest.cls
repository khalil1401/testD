@isTest
private class addProductsModuloDePacienteTest  {
	
	private static testmethod void whenProductsAreSearchedAndThereAreNoProductsSaved_itShouldReturnAnEmptyList() {
		controller = new AddProductsModuloDePacienteController(stdController);
		List<Product2> products = controller.getProductsBy('asd');
		System.assert(products.isEmpty());
	}
	

	private static testmethod void ifThereAreNoSelectedItems_theGetSelectedMethodReturnsAnEmptyList() {
		controller = new AddProductsModuloDePacienteController(stdController);
		product =  new Product2(name ='Name',Producto_SAP__c= true);
		insert product;
		
		Test.startTest();
		List<AddProductsModuloDePacienteController.WrapperProduct> products = controller.productsToConfirmById.values();
		Test.stopTest();
		System.assert(products.isEmpty());		
	}
	
	private static testmethod void ifThereIsAnItemSelected_TheGetSelectedMethodReturnsThatItem() {
		controller = new AddProductsModuloDePacienteController(stdController);
		product =  new Product2(name ='Name',Producto_SAP__c= true);
		insert product;

		AddProductsModuloDePacienteController.WrapperProduct item = new AddProductsModuloDePacienteController.WrapperProduct(product);
		item.isSelected = true;
		controller.productsToConfirmById.put(item.product.Id, item);
		
		Test.startTest();
		List<AddProductsModuloDePacienteController.WrapperProduct> products = controller.productsToConfirmById.values();
		Test.stopTest();
		System.assertEquals(1, products.size());		
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
            
            product.Producto_SAP__c= true;
            
			products.add(product);
		}
		insert products;
		
		controller = new AddProductsModuloDePacienteController(stdController);

		Test.startTest();
		controller.selectAll = true;
		controller.doSelectAll();
		Test.stopTest();
		
		List<AddProductsModuloDePacienteController.WrapperProduct> productsToAssert = controller.productsToConfirmById.values();

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
            
            product.Producto_SAP__c= true;
			products.add(product);
		}
		insert products;
		
		controller = new AddProductsModuloDePacienteController(stdController);
		controller.selectAll = true;
		controller.doSelectAll();

		Test.startTest();
		controller.deselectAll();
		Test.stopTest();
		
		List<AddProductsModuloDePacienteController.WrapperProduct> productsToAssert = controller.productsToConfirmById.values();

		System.assertEquals(0, productsToAssert.size());	
	}

	private static testmethod void ifThereAreElevenProductsAndThePageSizeIsTen_theActualPageShouldBeHaveTenItems() {
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				 new Product2(name ='Name'+i,Producto_SAP__c= true));
		}
		insert listProd;

		controller = new AddProductsModuloDePacienteController(stdController);
		System.assert(controller.actualPage.size() == 10);
		System.assert(controller.wrapperProductsList.size() == 11);		
	}

	private static testmethod void ifThereAreElevenProductsAndThePageSizeIsTen_theLastPageShouldBeHaveOneItems() {
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add(
				 new Product2(name ='Name'+i,Producto_SAP__c= true));
		}
		insert listProd;
		controller = new AddProductsModuloDePacienteController(stdController);

		Test.startTest();
		controller.lastPage();
		Test.stopTest();

		System.assert(controller.actualPage.size() == 1);
		System.assert(controller.wrapperProductsList.size() == 11);		
	}

	private static testmethod void ifThereAreElevenProductsAndTheActualPageSizeIsTen_theNextPageShouldBeHaveOneItems() {
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add( new Product2(name ='Name'+i,Producto_SAP__c= true));
		}
		insert listProd;
		controller = new AddProductsModuloDePacienteController(stdController);

		Test.startTest();
		controller.next();
		Test.stopTest();

		System.assert(controller.actualPage.size() == 1);
		System.assert(controller.wrapperProductsList.size() == 11);		
	}

	private static testmethod void ifThereAreElevenProductsAndTheActualPageSizeIsOne_thePreviousPageShouldBeHaveTenItems() {
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add( new Product2(name ='Name'+i,Producto_SAP__c= true));
		}
		insert listProd;
		controller = new AddProductsModuloDePacienteController(stdController);

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
			listProd.add( new Product2(name ='Name'+i,Producto_SAP__c= true));
		}
		insert listProd;
		controller = new AddProductsModuloDePacienteController(stdController);

		Test.startTest();
		controller.pageSizeStr = '25';
		controller.changePageSize();
		Test.stopTest();
		System.assert(controller.actualPage.size() == 11);
		System.assert(controller.wrapperProductsList.size() == 11);		
	}

	private static testmethod void theGetItemsMethodShouldBeReturnAListOfOptions() {
		controller = new AddProductsModuloDePacienteController(stdController);
		Test.startTest();
		List<SelectOption> options = controller.getItems();
		Test.stopTest();

		System.assert(options != null);		
	}

	@IsTest
	private static void whenASearchedProductIsSelected_HaveToBeAddToTheConfirmTable(){
		List<Product2> listProd = new List<Product2>();
		for(Integer i = 0; i < 11; i++) {
			listProd.add( new Product2(name ='Name'+i,Producto_SAP__c= true));
		}
		insert listProd;
		
		controller = new AddProductsModuloDePacienteController(stdController);

		AddProductsModuloDePacienteController.WrapperProduct wrapperProductToTest = controller.actualPage.values()[0];

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
			listProd.add( new Product2(name ='Name'+i,Producto_SAP__c= true));
		}
		insert listProd;
		
		controller = new AddProductsModuloDePacienteController(stdController);

		AddProductsModuloDePacienteController.WrapperProduct wrapperProductToTest = controller.actualPage.values()[0];

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
			listProd.add( new Product2(name ='Name'+i,Producto_SAP__c= true));
		}
		insert listProd;
		
		controller = new AddProductsModuloDePacienteController(stdController);

		AddProductsModuloDePacienteController.WrapperProduct wrapperProductToTest = controller.actualPage.values()[0];

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
	static AddProductsModuloDePacienteController controller;
	static Producto_de_modulo__c producto;
	static ApexPages.StandardController stdController;

	static {
		acc = Build.anAccountPacienteBestCare()
				   .withLastName('Name Test')
				   .withRegimenDeInternacionDomiciliaria('Sí')
				   .withEmpresadeinternaciondomiciliaria('Best care')				   
				   .build();
        acc.DNI__c= '45642123';
        acc.Canal_para_Consumidor_Baby__c ='Farmacias';
		insert acc;
		//modulo = Build.aModulodepaciente().withCuenta(acc).build();
		
		Modulo_de_paciente__c mdp = new Modulo_de_paciente__c();
        mdp.Cuenta__c = acc.id;
        
        insert mdp;
        
        producto = new Producto_de_modulo__c();
		producto.Modulo_de_paciente__c = mdp.id;
         
		insert producto;
        
		stdController = new ApexPages.StandardController(mdp);		
	}
}