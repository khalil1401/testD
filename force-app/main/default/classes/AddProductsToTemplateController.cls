public with sharing class AddProductsToTemplateController {
    @AuraEnabled
    public static List<WrapProduct> getProducts(String recordId) {
        List<WrapProduct> listProducts = new List<WrapProduct>();

        List<String> salesAreaIds = new List<String>();
        List<String> productSalesAreaRecordIds = new List<String>();
        Set<String> productsToFilter = new Set<String>();        
                
        List<Dan360_PlantillaDeProductos__c> plantillaDeProductos = [
            SELECT Id, Dan360_UnidadNegocio__c
            FROM Dan360_PlantillaDeProductos__c
            WHERE Id = :recordId
            LIMIT 1
        ];


        String unidadDeNegocio = 'Random value';
        for (Dan360_PlantillaDeProductos__c aplantillaDeProductos : plantillaDeProductos) {
            unidadDeNegocio = plantillaDeProductos[0].Dan360_UnidadNegocio__c;
        }
        //Get all Sales Area records where Sales Organization = Unidad de Negocio
        List<Dan360_SalesArea__c> salesAreaRecords = [
            SELECT Id
            FROM Dan360_SalesArea__c
            WHERE Dan360_SalesOrganization__c = :unidadDeNegocio
        ];
        for(Dan360_SalesArea__c salesArea : salesAreaRecords){
            salesAreaIds.add(salesArea.Id);
        }

        //Get Product Sales Area records related to the Sales Area records we queried and Bloqueo = false
        List<Dan360_ProductSalesArea__c> productSalesAreaRecords = [
            SELECT Id, Dan360_Producto__c
            FROM Dan360_ProductSalesArea__c
            WHERE Bloqueo__c = false
                AND Dan360_SalesArea__c IN :salesAreaIds
        ];

        for(Dan360_ProductSalesArea__c productSalesArea : productSalesAreaRecords){
            productSalesAreaRecordIds.add(productSalesArea.Dan360_Producto__c);
        }

        List<Product2> productsToAddToListOfLists = [
            SELECT Id, Name, ProductCode
            FROM Product2
            WHERE Id IN :productSalesAreaRecordIds
        ];
       
        // get products already exist in template
        List<Dan360_ProductoPorPlantilla__c> productsAlreadyExist = [
            SELECT ID, Dan360_Producto__c 
            FROM Dan360_ProductoPorPlantilla__c
            WHERE Dan360_PlantillaProductos__c = :recordId
        ];
       
        
        
        for (Dan360_ProductoPorPlantilla__c aProduct : productsAlreadyExist) {
            productsToFilter.add(aProduct.Dan360_Producto__c);
        }

        
        // filter products alraedy exist in template
        for (Product2 aProduct : productsToAddToListOfLists) {           
            if (!productsToFilter.contains(aProduct.Id)) {                
                
                WrapProduct product = new WrapProduct();
                product.name = aProduct.Name;
                product.productoId = aProduct.Id;
                product.productCode = aProduct.ProductCode;
                product.unidadMedida = '';
                product.vigenciaDesde = null;
                product.vigenciaHasta = null;
                
                
                listProducts.add(product);
            }
        }      
        
                
        return listProducts;        
    }
    @AuraEnabled
    public static List<Object> getPicklistValues() {
        // get unidad de medida picklist values
        Schema.DescribeFieldResult objFieldDescribe = Dan360_ProductoPorPlantilla__c.Dan360_UnidadDeMedida__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        List<Map<String,String>> optiosValuesList = new List<Map<String,String>>();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            Map<String,String> option = new Map<String,String>();
            option.put('label', objPickList.getLabel() );
            option.put('value', objPickList.getValue() );
                
            optiosValuesList.add(option);
            System.debug(option);
        }
       
        return optiosValuesList;
    }

    @AuraEnabled
    public static String saveProducts(string listProducts, String recordId){
        System.debug('listProducts: '+listProducts);
        System.debug('recordId: '+recordId);
        List<Dan360_ProductoPorPlantilla__c> listNewProductPerTemplate = new List<Dan360_ProductoPorPlantilla__c>();
        List<AddProductsToTemplateController.WrapProduct> productos =
            (List<AddProductsToTemplateController.WrapProduct>) JSON.deserialize(
                listProducts,
                List<AddProductsToTemplateController.WrapProduct>.class
        );


        for(AddProductsToTemplateController.WrapProduct product : productos){
           
            Dan360_ProductoPorPlantilla__c aNewProducPerTemplate = new Dan360_ProductoPorPlantilla__c(
                Dan360_PlantillaProductos__c = recordId,
                Dan360_Producto__c = product.productoId,
                Dan360_UnidadDeMedida__c = product.unidadMedida,
                Dan360_VigenciaDesde__c = product.vigenciaDesde,
                Dan360_Vigencia__c = product.vigenciaHasta
            );
            
            listNewProductPerTemplate.add(aNewProducPerTemplate);
        }
        String estado;
        Database.SaveResult[] saveResultList = Database.insert(listNewProductPerTemplate, true);
        for (Database.SaveResult sr : saveResultList) {
            if (sr.isSuccess()) {
                String exito = 'Los productos seleccionados se han agregado correctamente';
                estado = exito;
            }
            else {
                String errorList;
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                    errorList += err.getStatusCode() + ': ' + err.getMessage() + '/br';
                }
                estado = errorList;
            }
        }

        return estado;
    }

    public class WrapProduct{
        @AuraEnabled
        public String name { get;set;}      
        @AuraEnabled
        public String unidadMedida { get;set;}        
        @AuraEnabled
        public String productoId { get;set;}
        @AuraEnabled
        public String productCode { get;set;}
        @AuraEnabled
        public Date vigenciaDesde { get;set;}
        @AuraEnabled
        public Date vigenciaHasta { get;set;}
        // public WrapProduct(String name, String unidadMedida, String productoId, String productCode, Date vigenciaDesde,  Date vigenciaHasta){
        //     this.name = name;
        //     this.unidadMedida = '';
        //     this.productoId = productoId;
        //     this.productCode = productCode;
        //     this.vigenciaDesde = null;
        //     this.vigenciaHasta = null;
        // }
    }
    
}