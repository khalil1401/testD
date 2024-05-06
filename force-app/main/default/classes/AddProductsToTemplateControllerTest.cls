@isTest public with sharing class AddProductsToTemplateControllerTest {
    @TestSetup
    static void makeData(){

        insert new Plantillas__c( AMN_00__C = 'AMN Canal 00');

        Dan360_PlantillaDeProductos__c aTemplateProduct = Build.aPlantillaDeProductos()
            .withBusinessUnit('5800')
            .withName('AMN Canal 00')
            .build();
        insert aTemplateProduct;

        Dan360_SalesArea__c salesArea = Build.aSalesArea()
            .withName('AMN-01-01')
            .withIdExterno('5800-01-01')
            .withDistributionChannel('00')
            .withDivision('01')
            .withSalesOrganization('5800')
            .build();
        insert salesArea;

        Product2 product = Build.aProduct()
            .withName('Producto Test')
            .withUnidadesBulto(15)            
            .withIsActive(true)
            .withIdSap('106959')
            .build();
        insert product;

        Dan360_ProductSalesArea__c aProductSalesArea = Build.aProductSalesArea()
            .withBloqueo(false)
            .withSalesArea(salesArea)
            .withProduct(product)
            .build();
        insert aProductSalesArea;
       
    }

    @IsTest
    static void whenCallGetProductsMethodReturnAProductsList(){
        Dan360_PlantillaDeProductos__c aTemplateProduct = [
            SELECT Id 
            FROM Dan360_PlantillaDeProductos__c
            WHERE Name = 'AMN Canal 00'
        ];

        Id recordId = aTemplateProduct.Id;
        
        Test.startTest();
            List<AddProductsToTemplateController.WrapProduct> products = AddProductsToTemplateController.getProducts(recordId);
        Test.stopTest();

        System.assertEquals( 1, products.size(), 'Error al obtener productos');
        System.assert(products.size() > 0, 'Error al obtener productos');
        
    }
    @IsTest
    static void whenCallGetPicklistValuesMethodReturnOptionValuesList(){
        
        Schema.DescribeFieldResult objFieldDescribe = Dan360_ProductoPorPlantilla__c.Dan360_UnidadDeMedida__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        List<Map<String,String>> optiosValuesListExpected = new List<Map<String,String>>();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            Map<String,String> option = new Map<String,String>();
            option.put('label', objPickList.getLabel() );
            option.put('value', objPickList.getValue() );
                
            optiosValuesListExpected.add(option);
        }
        
        Test.startTest();
            List<Object> optionValues = AddProductsToTemplateController.getPicklistValues();
        Test.stopTest();

        System.assertEquals( optiosValuesListExpected.size(), optionValues.size(), 'Error al obtener Picklist Values');
        System.assert(optionValues.size() > 0, 'Error al obtener Picklist Values');
        
    }
    @IsTest
    static void whenCallSaveProductsMethodReturnReturnStateCorrect(){
        Product2 aProduct =  [
            SELECT Id, Name, ProductCode
            FROM Product2
            WHERE Name = 'Producto Test'
            AND ProductCode = '106959'
            LIMIT 1
        ]; 
       
        List<AddProductsToTemplateController.WrapProduct> productList = new List<AddProductsToTemplateController.WrapProduct>();
       
        AddProductsToTemplateController.WrapProduct product = new AddProductsToTemplateController.WrapProduct();
            product.name = aProduct.Name;
            product.productoId = aProduct.Id;
            product.productCode = aProduct.ProductCode;
            product.unidadMedida = 'Unidad';
            product.vigenciaDesde = Date.Today();
            product.vigenciaHasta = Date.Today() + 3;

        productList.add(product);
        
        
       Dan360_PlantillaDeProductos__c aTemplateProduct = [
            SELECT Id 
            FROM Dan360_PlantillaDeProductos__c
            WHERE Name = 'AMN Canal 00'
        ];

        Id recordId = aTemplateProduct.Id;
        
        Test.startTest();
            String state = AddProductsToTemplateController.saveProducts(JSON.serialize(productList), recordId);
        Test.stopTest();

        Dan360_ProductoPorPlantilla__c productPerTemplate = [
            SELECT Id, Dan360_Producto__c
            FROM Dan360_ProductoPorPlantilla__c
            WHERE Dan360_PlantillaProductos__c = : recordId
        ];
       
        System.assertEquals( 'Los productos seleccionados se han agregado correctamente', state, 'Error al guardar productos');        
        System.assertEquals( productPerTemplate.Dan360_Producto__c, aProduct.Id, 'Error al guardar productos');
    }
    @IsTest
    static void whenCallSaveProductsMethodWithInvalidDataInsertFail(){
        Product2 aProduct =  [
            SELECT Id, Name, ProductCode
            FROM Product2
            WHERE Name = 'Producto Test'
            AND ProductCode = '106959'
            LIMIT 1
        ]; 
       
        List<AddProductsToTemplateController.WrapProduct> productList = new List<AddProductsToTemplateController.WrapProduct>();
       
        AddProductsToTemplateController.WrapProduct product = new AddProductsToTemplateController.WrapProduct();
            product.name = aProduct.Name;
            product.productoId = aProduct.Id;
            product.productCode = aProduct.ProductCode;
            product.unidadMedida = 'Unidad Medida No Valida';
            product.vigenciaDesde = Date.Today();
            product.vigenciaHasta = Date.Today() + 3;

        productList.add(product);
        
        
       Dan360_PlantillaDeProductos__c aTemplateProduct = [
            SELECT Id 
            FROM Dan360_PlantillaDeProductos__c
            WHERE Name = 'AMN Canal 00'
        ];

        Id recordId = aTemplateProduct.Id;
        String errorMensaje;
        try {			
            Test.startTest();
            	AddProductsToTemplateController.saveProducts(JSON.serialize(productList), recordId);
            Test.stopTest(); 
        } catch (Exception err) {
			errorMensaje = err.getMessage();
        }        
        
        List<Dan360_ProductoPorPlantilla__c> productPerTemplateList = [
            SELECT Id, Dan360_Producto__c
            FROM Dan360_ProductoPorPlantilla__c
            WHERE Dan360_PlantillaProductos__c = : recordId
        ];
       
        System.assertNotEquals( 'Los productos seleccionados se han agregado correctamente', errorMensaje, 'Los productos se guardaron');        
        System.assertEquals( 0, productPerTemplateList.size(), 'Los productos se guardaron');        
        
    }
}