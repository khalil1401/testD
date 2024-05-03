public class RenovarModuloDePacienteCtrl{
	//Used in the pagination
	public List<WrapperProduct> existProducts {get; set;}
	public List<WrapperProduct> searchProducts {get; set;}
	
	//Used in the layout in the value of the apex:pageBlockTable
	public Map<String, WrapperProduct> existProductsById {get; set;}
	public Map<String, WrapperProduct> actualSearchProductsPage {get; set;}
	public Map<String, WrapperProduct> productsToConfirm {get; set;}
	
	//Used to count the selected products
	public Map<String, WrapperProduct> selectedExistProductById {get; set;}
	public Map<String, WrapperProduct> selectedSearchedProductsById {get; set;}
	
	public String criteria {get; set;}
	private String oldCriteria;

	public Integer counter;
	public Integer endPage = 0;
	public Integer pageSize;
	public String pageSizeStr {get; set;}
	
	public Integer existProductsTotal {get; set;}
	public Integer existProductSelected {get; set;}
	public Boolean existProductSelectAll {get; set;}
	public Boolean thereAreExistRecords {get; set;}

	public Integer total {get; set;}
	public Integer searchProductSelected {get; set;}
	public Boolean searchSelectAll {get; set;}
	public Boolean thereAreRecords {get; set;}

	public Integer totalProductSelected {get; set;}

	public Boolean hasPrevious {get; set;}
	public Boolean hasNext {get; set;}
	public Integer numPages {get; set;}
	public Integer actualPageNumber {get; set;}

	private Modulo_de_paciente__c modulo;
	private ApexPages.StandardController stdController;

	public String renewModuloUrl {get; set;}
	public String previousTabTitle {get; set;}

	public RenovarModuloDePacienteCtrl(ApexPages.StandardController stdController) {
		this.modulo = (Modulo_de_paciente__c)stdController.getRecord();
		this.stdController = stdController;
		
		searchProducts = new List<WrapperProduct>();
		
		selectedExistProductById = new Map<String, WrapperProduct>();
		actualSearchProductsPage = new Map<String, WrapperProduct>();
		productsToConfirm = new Map<String, WrapperProduct>();
		selectedSearchedProductsById = new Map<String, WrapperProduct>();
		
		thereAreExistRecords = false;
		getExistProducts(modulo.Id);
		existProductsTotal = existProducts.size();
		existProductSelected = existProducts.size();
		searchProductSelected = 0;
		totalProductSelected = 0;

		thereAreRecords = false;
		total = 0;
		
		pageSize = 10;
		pageSizeStr = '10';
		numPages = 1;
		actualPageNumber = 1;
		counter	= 0;
		criteria = '';
		oldCriteria = 'differentCriteria';
		hasPrevious = false;
		hasNext = false;
		findProducts();
		
		previousTabTitle = [
			SELECT Name 
			FROM Modulo_de_paciente__c 
			WHERE Id = :modulo.Id][0].Name;
	}

	//--MODIFICAR PRODUCTOS EXISTENTES-----------------------------------------------------------------------
	public void getExistProducts(Id moduloId){
		existProducts =  new List<WrapperProduct>(); 
		existProductsById = new Map<String, WrapperProduct>();
		List<Producto_de_modulo__c> productosDeModulos = [
			SELECT	Formula__c,
					Cantidad__c
			FROM Producto_de_modulo__c
			WHERE Modulo_de_paciente__c = :moduloId
 		];
		if(!productosDeModulos.isEmpty()){
			Map<Id, String> cantidadByproductId = new Map<Id,String>();
			for(Producto_de_modulo__c productoDeModulo : productosDeModulos){
				cantidadByproductId.put(productoDeModulo.Formula__c, productoDeModulo.Cantidad__c);	
			}
			List<Product2> productosExistentes = [
				SELECT	Id,
						Name,
						Description
				FROM Product2
				WHERE Id IN :cantidadByproductId.keySet()
				AND Producto_SAP__c =true
			];
			for(Product2 producto : productosExistentes){
				WrapperProduct wrapperProduct = new WrapperProduct(
					producto, 
					Integer.valueOf(cantidadByproductId.get(producto.Id)), 
					true,
                    false
				);
				existProducts.add(wrapperProduct);
				existProductsById.put(producto.Id, wrapperProduct);
				productsToConfirm.put(producto.Id, wrapperProduct);
				selectedExistProductById.put(producto.Id, wrapperProduct);
			}
			thereAreExistRecords = true;
			existProductSelectAll = true;
		}
	}

	public void doExistProductSelectAll() {
		for(WrapperProduct wrapper : existProducts) {
			wrapper.isSelected = existProductSelectAll;
            if(wrapper.isSelected){
				wrapper.isDisabled = false;
				if(!selectedExistProductById.containsKey(wrapper.product.Id)){
					selectedExistProductById.put(wrapper.product.Id, wrapper);
				}
				productsToConfirm.put(wrapper.product.Id, wrapper);
				existProductsById.put(wrapper.product.Id, wrapper);
            }else{
				wrapper.isDisabled = true;
				selectedExistProductById.remove(wrapper.product.Id);
				productsToConfirm.remove(wrapper.product.Id);
				existProductsById.put(wrapper.product.Id, wrapper);
			}
		}
        countSelected();
	}

	public void setProductsToConfirmThruExistSelected(){
		String existProductIdSelect = ApexPages.currentPage().getParameters().get('existProductIdSelect');
		String existProductQuantity = ApexPages.currentPage().getParameters().get('existProductQuantity');
        WrapperProduct existProduct = existProductsById.get(existProductIdSelect);
        if(existProduct.isSelected){
            existProduct.isDisabled = false;
            if(String.isNotBlank(existProductQuantity)){
				System.debug(existProduct.quantity);
				System.debug(Integer.valueOf(existProductQuantity));
				Boolean isQuantityChange =
					existProductsById.containsKey(existProductIdSelect) 
						&& existProduct.quantity != Integer.valueOf(existProductQuantity);
				if(isQuantityChange){
					existProduct.quantity = Integer.valueOf(existProductQuantity);
                }
			}
			selectedExistProductById.put(existProductIdSelect, existProduct);
            productsToConfirm.put(existProductIdSelect, existProduct);
            existProductsById.put(existProductIdSelect, existProduct);
			if(existProductSelected == selectedExistProductById.size()){
				existProductSelectAll = true;
			}
        }
		else{
            existProduct.isDisabled = true;
            selectedExistProductById.remove(existProductIdSelect);
            productsToConfirm.remove(existProductIdSelect);
            existProductsById.put(existProductIdSelect, existProduct);
			if(existProductSelectAll){
				existProductSelectAll = false;
			}
        }
		countSelected();
	}

	//--AGREGAR PRODUCTOS------------------------------------------------------------------------------------
	public void findProducts() {
		if(this.criteria == this.oldCriteria) {
			firstPage();
			return;
		}
		this.oldCriteria = this.criteria;
		searchProducts.clear();
        searchSelectAll = false;
        
		List<Product2> products = getProductsBy(this.criteria);
		for(Product2 p : products) {
			if(selectedSearchedProductsById.containsKey(p.Id)){
				searchProducts.add(
					selectedSearchedProductsById.get(p.Id)
				);
			}
			else{
				searchProducts.add(new WrapperProduct(p));
			}
		}
		setValues();
		numPages();
		setActualPage();
	}

	public void doSearchProductsSelectAll() {
		if(searchSelectAll){
			for(WrapperProduct wrapper : actualSearchProductsPage.values()){
				wrapper.isSelected = searchSelectAll;
				wrapper.isDisabled = false;
				if(!selectedSearchedProductsById.containsKey(wrapper.product.Id)){
					selectedSearchedProductsById.put(wrapper.product.Id, wrapper);
					productsToConfirm.put(wrapper.product.Id, wrapper);
				}
			}
		}
		else{
			doSearchedDeselectAll();
		}
		countSelected();
	}

	public void doSearchedDeselectAll(){
		searchSelectAll = false;
		for(WrapperProduct wrapper : actualSearchProductsPage.values()){
			wrapper.isSelected = searchSelectAll;
			wrapper.isDisabled = true;
			if(selectedSearchedProductsById.containsKey(wrapper.product.Id)){
				selectedSearchedProductsById.remove(wrapper.product.Id);
				productsToConfirm.remove(wrapper.product.Id);
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
			SELECT	Id, 
					Name, 
					Description
			FROM Product2
			WHERE (
				Description LIKE :value
				OR Name LIKE :value
			)
			AND Id NOT IN :existProductsById.keySet()
            AND Producto_SAP__c = true
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
		actualSearchProductsPage.clear();
		if(counter != 0) {
			actualPageNumber = (counter / pageSize) + 1;
		}
		else {
			actualPageNumber = 1;
		}
		for(Integer i = counter; i < endPage; i++) {
			if(selectedSearchedProductsById.containsKey(searchProducts[i].product.Id)){
				searchProducts[i].isSelected = true;
			}
			actualSearchProductsPage.put(searchProducts[i].product.Id, searchProducts[i]);
		}
	}

	public void numPages() {
		if(searchProducts.size() != 0 && searchProducts.size() > pageSize) {
			numPages = (searchProducts.size() / pageSize) + 1;
		}
		else {
			numPages = 1;
		}
	}

	public void setValues() {
		counter = 0;
		hasPrevious = false;
		total = searchProducts.size();
		countSelected();
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

	public void setProductsToConfirmThruSelectedSearchedProducts(){
		String searchProductIdSelect = ApexPages.currentPage().getParameters().get('searchProductIdSelect');
		String searchProductQuantity = ApexPages.currentPage().getParameters().get('searchProductQuantity');
		WrapperProduct product = actualSearchProductsPage.get(searchProductIdSelect);
		if(product.isSelected){
			product.isDisabled = false;
			if(String.isNotBlank(searchProductQuantity)){
				Boolean isQuantityChange =
					selectedSearchedProductsById.containsKey(searchProductIdSelect) 
						&& (selectedSearchedProductsById.get(searchProductIdSelect).quantity != Integer.valueOf(searchProductQuantity));
				if(isQuantityChange){
					product.quantity = Integer.valueOf(searchProductQuantity);
				}
			}
			selectedSearchedProductsById.put(searchProductIdSelect, product);
			productsToConfirm.put(searchProductIdSelect, product);
		}else{
			if(product.isDisabled == false){
				product.isDisabled = true;
				if(selectedSearchedProductsById.containsKey(searchProductIdSelect)){
					selectedSearchedProductsById.remove(searchProductIdSelect);
					productsToConfirm.remove(searchProductIdSelect);
				}
			}
		}
		countSelected();
	}

	public void insertServiciosDelModulo(Modulo_de_paciente__c newMdp, List<Servicios_del_Modulo__c> serviciosDeModuloList){
		
		List<Servicios_del_Modulo__c> serviciosToInsert = new List<Servicios_del_Modulo__c>();

			
			for(Servicios_del_Modulo__c newServMod : serviciosDeModuloList){

				Servicios_del_Modulo__c newServicio = new Servicios_del_Modulo__c();
				newServicio.Modulo_de_paciente__c = newMdp.id;
				newServicio.Servicios_disponibles__c = newServMod.Servicios_disponibles__c;
				newServicio.Cantidad__c = newServMod.Cantidad__c;
				
				serviciosToInsert.add(newServicio);

			}

		if(!serviciosToInsert.isEmpty()){

			Database.insert(serviciosToInsert);
		}

	}
	
	public void countSelected(){
		existProductSelected = selectedExistProductById.size();
		searchProductSelected = selectedSearchedProductsById.values().size();
		totalProductSelected = existProductSelected + searchProductSelected;
	}
	//------------------------------------------------------------------------------------------------------
	public void renewModuloDePaciente() {
		clearMessage();

		modulo = [
			SELECT	Modulo_Hasta__c,
            		Tipo__c,
					Modulo__c,
					Duracion_modulo__c,
					Cuenta__c,
            		Estado__c,
            		Modulo_tipo_de_producto__c,
            		Modulo_tipo_de_servicio__c
			FROM Modulo_de_paciente__c
			WHERE Id = :modulo.Id
		];

		Date Fechadesde = Date.today();

		if(modulo.Modulo_hasta__c > Fechadesde){
			Fechadesde = modulo.Modulo_hasta__c;
		}
		
        Modulo_de_paciente__c renewModulo = modulo.clone(false, true);  
		renewModulo.Modulo_desde__c = Fechadesde;
		renewModulo.Modulo_hasta__c = date.today().addDays(Integer.valueOf(modulo.Duracion_modulo__c));
		renewModulo.Modulo__c = modulo.Modulo__c;
		renewModulo.Duracion_modulo__c = modulo.Duracion_modulo__c;
		renewModulo.Cuenta__c = modulo.Cuenta__c;
        renewModulo.Estado__c = 'Activo';
        renewModulo.Tipo__c = modulo.Tipo__c;
		renewModulo.Renovacion__c = 'Renovacion';
        renewModulo.Modulo_tipo_de_servicio__c = modulo.Modulo_tipo_de_servicio__c;
        renewModulo.Modulo_tipo_de_producto__c = modulo.Modulo_tipo_de_producto__c;
		insert renewModulo;

		List<Producto_de_modulo__c> productosDeModulo = new List<Producto_de_modulo__c>();
		if(!productsToConfirm.isEmpty()){
			for(WrapperProduct wrpProduct : productsToConfirm.values()) {
				Producto_de_modulo__c productoDeModulo = new Producto_de_modulo__c(
					Modulo_de_paciente__c = renewModulo.Id,
					Formula__c = wrpProduct.product.Id, 
					Cantidad__c = String.valueOf(wrpProduct.quantity)
				);
				productosDeModulo.add(productoDeModulo);
			}
			insert productosDeModulo;
		}
		renewModuloUrl = '/' + renewModulo.Id;

		List<Servicios_del_Modulo__c> serviciosDeModuloList=[ 
	    	SELECT id,Modulo_de_paciente__c,Servicios_disponibles__c,Cantidad__c
			FROM Servicios_del_Modulo__c 
			WHERE Modulo_de_paciente__c = :modulo.id
		];
		
		if(!serviciosDeModuloList.isEmpty()){

			insertServiciosDelModulo(renewModulo, serviciosDeModuloList);

		}
	}
    /*----*/
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

		public WrapperProduct(Product2 product, Integer quantity, Boolean isSelected, Boolean isDisabled){
			this.product = product;
			this.isSelected = isSelected;
			this.quantity = quantity;
            this.isDisabled = isDisabled;
		}
	}
}