public with sharing class AddProductsTratamientoController  {
	public List<WrapperProduct> wrapperProductsList { get; set; }
	public List<WrapperProduct> actualPage { get; set; }
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

	private final Tratamiento__c tratamiento;
	private ApexPages.StandardController stdController;

	public AddProductsTratamientoController(ApexPages.StandardController stdController) {
		this.tratamiento = (Tratamiento__c)stdController.getRecord();
		this.stdController = stdController;
		thereAreRecords = false;
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
		actualPage = new List<WrapperProduct>();
		hasPrevious = false;
		hasNext = false;
		findProducts();
	}

	public void doSelectAll() {
		for(WrapperProduct wrapper : actualPage) {
			wrapper.isSelected = selectAll;
		}
		countSelected();
	}

	public void deselectAll() {
		selectAll = false;
		for(WrapperProduct wrapper : wrapperProductsList) {
			wrapper.isSelected = selectAll;
		}
		countSelected();
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
				id, Name, Description
			FROM Product2
			WHERE Producto_para__c = 'Best Care'
            	AND (Description LIKE :value
					OR Name LIKE :value
               	)
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
			deselectAll();
			firstPage();
			return;
		}
		this.oldCriteria = this.criteria;
		wrapperProductsList.clear();
		List<Product2> products = getProductsBy(this.criteria);
		for(Product2 p : products) {
			wrapperProductsList.add(new WrapperProduct(p));
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
			actualPage.add(wrapperProductsList[i]);
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
		selected = 0;
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

	public PageReference addProducts() {
		clearMessage();
		List<WrapperProduct> selectedProducts = getSelected();
		Id tratamientoId = tratamiento.Id;
		List<Producto_de_paciente__c> newProducts = new List<Producto_de_paciente__c>();
		if(selectedProducts.isEmpty()) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Debe seleccionar algún producto'));
			return null;
		}
		for(WrapperProduct wrpProduct : selectedProducts) {
			Id formulaId = wrpProduct.product.id;
			Integer cantidad = wrpProduct.quantity;
			Producto_de_paciente__c newProductoDePaciente =
				new Producto_de_paciente__c(
					Formula__c = formulaId,
					Cantidad_de_producto__c = cantidad,
					Tratamiento__c = tratamientoId
				);
			newProducts.add(newProductoDePaciente);
		}
		insert newProducts;
		return nexPage();
	}

	public List<WrapperProduct> getSelected(){
		List<WrapperProduct> selectedProducts = new List<WrapperProduct>();
		for(WrapperProduct wrapper : wrapperProductsList) {
			if(wrapper.isSelected) {
				selectedProducts.add(wrapper);
			}
		}
		return selectedProducts;
	}

	public void countSelected(){
		selected = getSelected().size();
	}

	public PageReference nexPage() {
		Id tratamientoId = tratamiento.Id;
		PageReference nextPage = new PageReference('/' + tratamientoId);
		return nextPage;
	}

	public class WrapperProduct{
		public Product2 product {get;set;}
		public Boolean isSelected {get;set;}
		public Integer quantity {get;set;}

		public WrapperProduct(Product2 product){
			this.product = product;
			this.isSelected = false;
			this.quantity = 1;
		}
	}
}