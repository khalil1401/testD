@isTest
public with sharing class customerSalesAreaPricesTest {
    static XHttpCalloutMock getPriceResponse;
    static string datee;
    
    static {
        Id pricebookId = Test.getStandardPricebookId();
        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/');
        Account account = Build.anAccount()
            .withPricebook(pricebookId)
            .withName('Account Test')
            .withIdSap('1234')
            .build();
		insert account;
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
        datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getPriceResponse = new XHttpCalloutMock();
        getPriceResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(SapPricesMock.getSucess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
            
    }
   @IsTest
   static void whenInsertCustomerSalesAreaMustBeCreatedThePricesOfPriceBookEntries(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        
        List<PriceBookEntry> priceBookEntryList = [
            SELECT Id 
            FROM PricebookEntry            
        ];

        List<String> customerSalesAreaIds = new List<String>();
        Account account = [
            SELECT ID, Name
            FROM Account
            WHERE Name = 'Account Test'
            LIMIT 1
        ];
        Dan360_SalesArea__c salesArea = [
            SELECT ID, Name
            FROM Dan360_SalesArea__c
            WHERE Name = 'AMN-01-01'
            LIMIT 1
        ];

        Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesArea)
            .withIdExterno('5678-5800-01-01')
            .build();
        //insert customerSalesArea;

        //customerSalesAreaIds.add(customerSalesArea.id);
    
        Test.startTest();
            //customerSalesAreaPrices.updateMaterialsFlow(customerSalesAreaIds);
            insert customerSalesArea;
        Test.stopTest();

        List<PriceBookEntry> priceBookEntryListToCompare = [
            SELECT Id 
            FROM PricebookEntry            
        ];
       
        System.assertEquals(priceBookEntryList.size() + 1, priceBookEntryListToCompare.size(), 'Error al crear la lista de precios');
   }
}