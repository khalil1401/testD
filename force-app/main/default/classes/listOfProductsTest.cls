/**
 * @description       : 
 * @author            : sebastian.fondovila@globant.com
 * @group             : 
 * @last modified on  : 06-08-2022
 * @last modified by  : sebastian.fondovila@globant.com
**/
@isTest
public with sharing class listOfProductsTest {
    static XHttpCalloutMock getResponse;
    static string datee;
    
    static{
        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/');
        Id pricebookId = Test.getStandardPricebookId();
        
        Account account = Build.anAccount()
        .withPricebook(pricebookId)
        .withName('Account Test')
        .withIdSap('1234')
        .build();
    insert account;

    Product2 product = Build.aProduct()
        .withName('Product Test')
        .withUnidadesBulto(15)
        .withIsActive(true)
        .withIdSap('166578')
        .build();
    insert product;

    Product2 productTwo = Build.aProduct()
        .withName('Product Test2')
        .withUnidadesBulto(15)
        .withIsActive(true)
        .withIdSap('106959')
        .build();
    insert productTwo;

    Dan360_SalesArea__c salesArea = Build.aSalesArea()
        .withName('AMN-01-01')
        .withIdExterno('5800-01-01')
        .withDistributionChannel('01')
        .withDivision('01')
        .withSalesOrganization('5800')
        .build();
    insert salesArea;

    Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
        .withName('AMN 00')
        .withClient(account)
        .withUnidadNegocio(salesArea)
        .withIdExterno('5678-5800-01-01')
        .build();
    insert customerSalesArea;
    
    Pricebook2 pricebookCustomer = Build.aPricebook().withName('CustomerPriceBook').withCustomerSalesArea(customerSalesArea).isActive(true).build();
    insert pricebookCustomer;

    PricebookEntry pricebookPriceDefault = Build.aPricebookEntry()
        .withPricebook2Id(pricebookCustomer.id)
        .withProduct2Id(product)
        .withUnitPrice(100)
        .withIsActive(true)
        .withDiscount(0.5)
        .build();
    insert pricebookPriceDefault;

    PricebookEntry pricebookPriceDefault2 = Build.aPricebookEntry()
        .withPricebook2Id(pricebookCustomer.id)
        .withProduct2Id(productTwo)
        .withUnitPrice(50)
        .withIsActive(true)
        .withDiscount(0.5)
        .build();
    insert pricebookPriceDefault2;

    Dan360_PlantillaDeProductos__c productsTemplate = Build.aPlantillaDeProductos()
        .withName('Equis')
        .withBusinessUnit('5800')
        .build();
    insert productsTemplate;
    
    Dan360_ProductSalesArea__c productSalesArea = Build.aProductSalesArea()
            .withSalesArea(salesArea)
            .withProduct(product)
            .withBloqueo(false)
            .build();
    insert productSalesArea;
    Dan360_ProductSalesArea__c productSalesAreaTwo = Build.aProductSalesArea()
            .withSalesArea(salesArea)
            .withProduct(productTwo)
            .withBloqueo(false)
            .build();
    insert productSalesAreaTwo;
    datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
            getResponse = new XHttpCalloutMock();
            getResponse.buildResponse()
                .withStatus('OK')
                .withStatusCode(200)
                .withBody(SapPricesMock.getSucess())
                .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
            
    }
    @isTest
    static void getTwoProductsTest(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        Account queriedAccount = [
            SELECT Id
            FROM Account
            WHERE Name = 'Account Test'
        ];

        Dan360_PlantillaDeProductos__c queriedPlantillaDeProducto = [
            SELECT Id
            FROM Dan360_PlantillaDeProductos__c
            WHERE Name = 'Equis'
        ];       
        
        List<String> recordId = new List<String>();
        recordId.add(queriedPlantillaDeProducto.Id);
        Test.startTest();
        List<List<Product2>> returnedListOfProducts = listOfProducts.getProducts(recordId);
        Test.stopTest();

        System.assertEquals(2, returnedListOfProducts[0].size(), 'The returned list did not bring the expected amount of records');
    } 

    @istest
    static void getOneProductTest(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        Account queriedAccount = [
            SELECT Id
            FROM Account
            WHERE Name = 'Account Test'
        ];

        Dan360_PlantillaDeProductos__c queriedPlantillaDeProducto = [
            SELECT Id
            FROM Dan360_PlantillaDeProductos__c
            WHERE Name = 'Equis'
        ];
        
        Dan360_SalesArea__c queriedSalesArea = [
            SELECT Id
            FROM Dan360_SalesArea__c
            WHERE Dan360_SalesOrganization__c = '5800'
            AND Name = 'AMN-01-01'
        ];

        List<Product2> queriedPrducts = [
            SELECT Id, Name
            FROM Product2
            WHERE Name LIKE 'Product%'
            LIMIT 1            
        ];
        List<Dan360_ProductoPorPlantilla__c> productPerTemplateList = new List<Dan360_ProductoPorPlantilla__c>();
        for (Product2 aProduct : queriedPrducts) {
            Dan360_ProductoPorPlantilla__c productPerTemplate = Build.aProductoPorPlantilla()
                .withProduct(aProduct)
                .withProductTemplate(queriedPlantillaDeProducto)
                .withUnitMeasure('Unidad')
                .withVigenciaDesde(Date.Today().AddDays(-1))
                .withVigencia(Date.Today().AddDays(1))
                .withIsActive(True)
                .build();

            productPerTemplateList.add(productPerTemplate);
            
        }
        insert productPerTemplateList;    
       
        List<String> recordId = new List<String>();
        recordId.add(queriedPlantillaDeProducto.Id);
        Test.startTest();
        List<List<Product2>> returnedListOfProducts = listOfProducts.getProducts(recordId);
        Test.stopTest();

        System.assertEquals(1, returnedListOfProducts[0].size(), 'The returned list did not bring the expected amount of records');
    } 

    @isTest
    static void getZeroProductTest(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        Account queriedAccount = [
            SELECT Id
            FROM Account
            WHERE Name = 'Account Test'
        ];

        Dan360_PlantillaDeProductos__c queriedPlantillaDeProducto = [
            SELECT Id
            FROM Dan360_PlantillaDeProductos__c
            WHERE Name = 'Equis'
        ];
        
        Dan360_SalesArea__c queriedSalesArea = [
            SELECT Id
            FROM Dan360_SalesArea__c
            WHERE Dan360_SalesOrganization__c = '5800'
            AND Name = 'AMN-01-01'
        ];

        List<Product2> queriedPrducts = [
            SELECT Id, Name
            FROM Product2
            WHERE Name LIKE 'Product%'
            
        ];
        List<Dan360_ProductoPorPlantilla__c> productPerTemplateList = new List<Dan360_ProductoPorPlantilla__c>();
        for (Product2 aProduct : queriedPrducts) {
            Dan360_ProductoPorPlantilla__c productPerTemplate = Build.aProductoPorPlantilla()
                .withProduct(aProduct)
                .withProductTemplate(queriedPlantillaDeProducto)
                .withUnitMeasure('Unidad')
                .withVigenciaDesde(Date.Today().AddDays(-1))
                .withVigencia(Date.Today().AddDays(1))
                .withIsActive(True)
                .build();

            productPerTemplateList.add(productPerTemplate);
            
        }
        insert productPerTemplateList;    
       
        List<String> recordId = new List<String>();
        recordId.add(queriedPlantillaDeProducto.Id);
        Test.startTest();
        List<List<Product2>> returnedListOfProducts = listOfProducts.getProducts(recordId);
        Test.stopTest();

        System.assertEquals(0, returnedListOfProducts[0].size(), 'The returned list did not bring the expected amount of records');
    } 
}