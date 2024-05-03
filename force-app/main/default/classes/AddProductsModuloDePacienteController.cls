public class AddProductsModuloDePacienteController {
    
	//Used in the pagination
	public List<WrapperProduct> wrapperProductsList { get; set; }
	
	//Used in the layout in the value of the apex:pageBlockTable
	public Map<String, WrapperProduct> actualPage { get; set; }
	public Map<Id, WrapperProduct> productsToConfirmById {get; set;}

	public String criteria {get;set;}
	private String oldCriteria;

	public Boolean selectAll {get; set;}
	public Integer counter;
	public Integer endPage = 0;
	public Integer pageSize;
	public String pageSizeStr { get; set;}
	public Integer total {get;set;}
	public Integer selected {get;set;}
	public Boolean thereAreRecords {get;set;}

	public Boolean hasPrevious {get;set;}
	public Boolean hasNext {get;set;}
	public Integer numPages {get;set;}
	public Integer actualPageNumber {get;set;}

	private final Modulo_de_paciente__c modulo;
	private ApexPages.StandardController stdController;

	public String previousTabTitle {get; set;}

	public AddProductsModuloDePacienteController(ApexPages.StandardController stdController) {
		this.modulo = (Modulo_de_paciente__c)stdController.getRecord();
		this.stdController = stdController;
		thereAreRecords = false;
		selectAll = false;
		total = 0;
		selected = 0;
		pageSize = 10;
		pageSizeStr = '10';
		numPages = 1;
		actualPageNumber = 1;
		counter	= 0;
		criteria = '';
		oldCriteria = 'differentCriteria';
		wrapperProductsList = new List<WrapperProduct>();
		actualPage = new Map<String, WrapperProduct>();
		productsToConfirmById = new Map<Id, WrapperProduct>();
		hasPrevious = false;
		hasNext = false;
		findProducts();

		previousTabTitle = [SELECT Name FROM Modulo_de_paciente__c WHERE Id = :modulo.Id][0].Name;
	}

	public void doSelectAll() {
		if(selectAll){
			for(WrapperProduct wrapper : actualPage.values()) {
				wrapper.isSelected = selectAll;
				wrapper.isDisabled = false;
				if(!productsToConfirmById.containsKey(wrapper.product.Id)){
					actualPage.put(wrapper.product.Id, wrapper);
					productsToConfirmById.put(wrapper.product.Id, wrapper);
				}
			}
		}
		else{
			deselectAll();
		}
		countSelected();
	}

	public void deselectAll(){
		selectAll = false;
		for(WrapperProduct wrapper : actualPage.values()) {
			wrapper.isSelected = selectAll;
			wrapper.isDisabled = true;
			if(productsToConfirmById.containsKey(wrapper.product.Id)){
				actualPage.put(wrapper.product.Id, wrapper);
				productsToConfirmById.remove(wrapper.product.Id);
			}
		}
	}

	public void changePageSize() {
		pageSize = Integer.valueOf(pageSizeStr);
		actualPageNumber = 1;
		setValues();
		numPages();
		setActualPage();
	}

	public List<Product2> getProductsBy(String criteria) {
		String value = '%'+criteria+'%';
		List<Product2> result = [
			SELECT
				Id, 
				Name,Codigo_producto_Id_externo__c,Modulo__c,
				Description
			FROM Product2
			WHERE Producto_SAP__c = true
            AND name like :value
			LIMIT 15000
		];
		return result;
	}
			
			      	 
	public List<SelectOption> getItems() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('10', '10'));
		options.add(new SelectOption('25', '25'));
		options.add(new SelectOption('50', '50'));
		options.add(new SelectOption('100', '100'));
		return options;
	}

	public void findProducts() {
		if(this.criteria == this.oldCriteria) {
			firstPage();
			return;
		}
		this.oldCriteria = this.criteria;
		wrapperProductsList.clear();
		List<Product2> products = getProductsBy(this.criteria);
		for(Product2 p : products) {
			if(productsToConfirmById.containsKey(p.Id)){
				wrapperProductsList.add(
					productsToConfirmById.get(p.Id)
				);
			}
			else{
				wrapperProductsList.add(new WrapperProduct(p));
			}
		}
		setValues();
		numPages();
		setActualPage();
	}

	public void firstPage() {
		setValues();
		setActualPage();
	}

	public void lastPage() {
		counter = (numPages - 1) * pageSize;
		hasNext = false;
		hasPrevious = true;
		endPage = total;
		setActualPage();
	}

	public void setActualPage() {
		clearMessage();
		actualPage.clear();
		if(counter != 0) {
			actualPageNumber = (counter / pageSize) + 1;
		}
		else {
			actualPageNumber = 1;
		}
		for(Integer i = counter; i < endPage; i++) {
			if(productsToConfirmById.containsKey(wrapperProductsList[i].product.Id)){
				wrapperProductsList[i].isSelected = true;
				wrapperProductsList[i].isDisabled = false;
				wrapperProductsList[i].quantity = productsToConfirmById.get(wrapperProductsList[i].product.Id).quantity;
			}
			actualPage.put(wrapperProductsList[i].product.Id, wrapperProductsList[i]);
		}
	}

	public void numPages() {
		if(wrapperProductsList.size() != 0 && wrapperProductsList.size() > pageSize) {
			numPages = (wrapperProductsList.size() / pageSize) + 1;
		}
		else {
			numPages = 1;
		}
	}

	public void setValues() {
		counter = 0;
		hasPrevious = false;
		total = wrapperProductsList.size();
		selected = productsToConfirmById.values().size();
		if(counter + pageSize < total) {
			endPage = counter + pageSize;
			hasNext = true;
		}
		else {
			endPage = total;
			hasNext = false;
		}
		thereAreRecords = total > 0;
	}

	public void previous() {
		counter = counter - pageSize;
		hasNext = true;
		endPage = counter + pageSize;
		if(counter < pageSize) {
			hasPrevious = false;
		}
		setActualPage();
	}

	public void next() {
		hasPrevious = true;
		counter = counter + pageSize;
		if(counter + pageSize < total) {
			endPage = counter + pageSize;
		}
		else {
			endPage = total;
			hasNext = false;
		}
		setActualPage();
	}

	public void clearMessage(){
		ApexPages.getMessages().clear();
	}

	public void saveSelectedProducts(){
		String searchProductIdSelect = ApexPages.currentPage().getParameters().get('searchProductIdSelect');
		String searchProductQuantity = ApexPages.currentPage().getParameters().get('searchProductQuantity');
		WrapperProduct wrapperProduct = actualPage.get(searchProductIdSelect);
		if(wrapperProduct.isSelected){
			wrapperProduct.isDisabled = false;
			if(String.isNotBlank(searchProductQuantity)){
				Boolean isQuantityChange =
					productsToConfirmById.containsKey(searchProductIdSelect) 
						&& (productsToConfirmById.get(searchProductIdSelect).quantity != Integer.valueOf(searchProductQuantity));
				if(isQuantityChange){
					wrapperProduct.quantity = Integer.valueOf(searchProductQuantity);
				}
			}
			productsToConfirmById.put(
				wrapperProduct.product.Id,
				wrapperProduct
			);
			if(productsToConfirmById.size() == actualPage.size()){
				selectAll = true;
			}
		}
		else{
			if(productsToConfirmById.containsKey(wrapperProduct.product.Id)){
				wrapperProduct.isDisabled = true;
				productsToConfirmById.remove(wrapperProduct.product.Id);
				actualPage.put(wrapperProduct.product.Id, wrapperProduct);
				if(selectAll){
					selectAll = false;
				}
			}
		}
		countSelected();
	}

	public void countSelected(){
		selected = productsToConfirmById.values().size();
	}

	//------------------------------------------------------------------------------------------------------------------------
	public PageReference addProducts() {
		clearMessage();
		List<WrapperProduct> selectedProducts = productsToConfirmById.values();
		Id moduloId = modulo.Id;
		List<Producto_de_modulo__c> newProducts = new List<Producto_de_modulo__c>();
		if(selectedProducts.isEmpty()) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Debe seleccionar algún producto'));
			return null;
		}
		for(WrapperProduct wrpProduct : selectedProducts) {
			Id formulaId = wrpProduct.product.id;
			String cantidad = String.valueOf(wrpProduct.quantity);
			Producto_de_modulo__c newProductoDeModulo =
				new Producto_de_modulo__c(Formula__c = formulaId, Cantidad__c = cantidad, Modulo_de_paciente__c = moduloId);
			newProducts.add(newProductoDeModulo);
		}
		insert newProducts;
		return nexPage();
	}

	public PageReference nexPage() {
		Id moduloId = modulo.Id;
		PageReference nextPage = new PageReference('/' + moduloId);
		return nextPage;
	}

	public class WrapperProduct{
		public Product2 product {get;set;}
		public Boolean isSelected {get;set;}
		public Integer quantity {get;set;}
		public Boolean isDisabled {get;set;}

		public WrapperProduct(Product2 product){
			this.product = product;
			this.isSelected = false;
			this.quantity = 1;
			this.isDisabled = true;
		}
	}


}