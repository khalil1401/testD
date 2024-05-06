/**
 * @description       : 
 * @author            : sebastian.fondovila@globant.com
 * @group             : 
 * @last modified on  : 06-08-2022
 * @last modified by  : sebastian.fondovila@globant.com
**/
public with sharing class listOfProducts {
    @InvocableMethod (label = 'SendRecordIdGet Products' description = 'returns filtered products.')
    public static List<List<Product2>> getProducts(List<String> recordId) {

        List<String> salesAreaIds = new List<String>();
        List<String> productSalesAreaRecordIds = new List<String>();
        Set<String> productsToFilter = new Set<String>();
        List<Product2> productsToAddInReturn = new List<Product2>();
                
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
            SELECT Id, Name
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
                
        for (Product2 aProduct : productsToAddToListOfLists) {           
            if (!productsToFilter.contains(aProduct.Id)) {                
                productsToAddInReturn.add(aProduct);
            }
        }
        
        List<List<Product2>> productsToReturn = new List<List<Product2>>();
        productsToReturn.add(productsToAddInReturn);       
        return productsToReturn;
    }
}