@isTest
public with sharing class AssingSalesdistrictInAccountHandlerTest {
    static XHttpCalloutMock getPriceResponse;
    static string datee;

    static{
        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833',User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/	');
        Id pricebookId = Test.getStandardPricebookId();

        Account anAccount = Build.anAccount()
            .withName('Test')
            .withPriceBook(pricebookId)
            .withIdSap('567832')
            .build();
        insert anAccount; 
        Account anAccountTwo = Build.anAccount()
            .withName('Test Two')
            .withPriceBook(pricebookId)
            .withIdSap('567777')
            .build();
        insert anAccountTwo; 
        Dan360_PlantillaDeProductos__c templateProducts = Build.aPlantillaDeProductos()
            .withName('AMN Canal 00')
            .withBusinessUnit('5800')
            .build();
        insert templateProducts;

        Dan360_PlantillaDeProductos__c templateProductsNuBa = Build.aPlantillaDeProductos()
            .withName('NuBa Canal 00')
            .withBusinessUnit('5771')
            .build();
        insert templateProductsNuBa;        
        Dan360_PlantillaDeProductos__c templateProductsAMNSinCargo = Build.aPlantillaDeProductos()
            .withName('AMN Canal 05')
            .withBusinessUnit('5800')
            .build();
        insert templateProductsAMNSinCargo;        
        Dan360_PlantillaDeProductos__c templateProductsNuBaSinCargo = Build.aPlantillaDeProductos()
            .withName('NuBa Canal 05')
            .withBusinessUnit('5771')
            .build();
        insert templateProductsNuBaSinCargo;        

        insert new Plantillas__c(AMN_00__c = 'AMN Canal 00', NuBa_00__c = 'NuBa Canal 00', AMN_05__c = 'AMN Canal 05', NuBa_05__c = 'NuBa Canal 05');
        
        dAN360_PlantillaporcCuenta__c templatePerAccount = Build.aPlantillaPorCuenta()
            .withAccount(anAccount)
            .withPlantillaDeProductos(templateProducts)
            .build();
            templatePerAccount.Dan360_UnidadNegocio__c = '5800';
            templatePerAccount.Dan360_DistributionChannel__c = '00';
        insert templatePerAccount;
        Dan360_SalesArea__c salesAreaVentaEstandar = Build.aSalesArea()
            .withName('AMN-01-01')
            .withIdExterno('5800-01-01')
            .withDistributionChannel('00')
            .withDivision('01')
            .withSalesOrganization('5800')
            .build();
        insert salesAreaVentaEstandar;
        Dan360_SalesArea__c salesAreaSinCargo = Build.aSalesArea()
            .withName('NUBA-01-01')
            .withIdExterno('5771-01-01')
            .withDistributionChannel('05')
            .withDivision('01')
            .withSalesOrganization('5771')
            .build();
        insert salesAreaSinCargo;

        datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getPriceResponse = new XHttpCalloutMock();
        getPriceResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(SapPricesMock.getSucess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesAreaVentaEstandar.Dan360_SalesOrganization__c+'&channelId='+salesAreaVentaEstandar.Dan360_DistributionChannel__c+'&divisionId='+salesAreaVentaEstandar.Dan360_Division__c+'&customer='+account.Id_SAP__c);
    
    }
    @isTest
    private static void whenInsertCustomerSalesAreMustAssingSalesDistrictAndDistributionChannelInAccount() {
        // Test data setup
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        Dan360_SalesArea__c salesAreaVentaEstandar = [
            SELECT Id, Dan360_DistributionChannel__c
            FROM Dan360_SalesArea__c
            WHERE Dan360_DistributionChannel__c = '00'
        ];
        Account account = [
            SELECT Id, Dan360_DistributionChannel__c,Dan360_SalesDistric1__c,Dan360_SalesDistrictColaborationRule__c
            FROM Account
            WHERE Name = 'Test'
        ];

        Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesAreaVentaEstandar)
            .withIdExterno('5678-5800-01-01')
            .build();
        customerSalesArea.Dan360_District__c = 'AR3INS';
              
        // Actual test
        Test.startTest();
            insert customerSalesArea;
        Test.stopTest();

        Account accountToCompare = [
            SELECT Id, Dan360_DistributionChannel__c,Dan360_SalesDistric1__c,Dan360_SalesDistrictColaborationRule__c
            FROM Account
            WHERE Name = 'Test'
        ];
    
        // Asserts
        System.assertEquals('Venta Estándar', accountToCompare.Dan360_DistributionChannel__c, 'Error al asignar distribution channel');
        System.assertEquals('Instituciones', accountToCompare.Dan360_SalesDistric1__c, 'Error al asignar sales district');
        System.assertEquals(accountToCompare.Dan360_SalesDistric1__c, accountToCompare.Dan360_SalesDistrictColaborationRule__c, 'Error al asignar sales district colaboration rule');
        System.assertNotEquals(null, accountToCompare.Dan360_DistributionChannel__c, 'Error al asignar distribution channel');
        System.assertNotEquals(null, accountToCompare.Dan360_SalesDistric1__c, 'Error al asignar sales district');
        System.assertNotEquals(null, accountToCompare.Dan360_SalesDistrictColaborationRule__c, 'Error al asignar sales district colaboration rule');
    }
    @isTest
    private static void whenInsertTwoCustomerSalesAreaForTheSameAccountMustConcatenateTheDifferentValues() {
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        // Test data setup
        Dan360_SalesArea__c salesAreaVentaEstandar = [
            SELECT Id, Dan360_DistributionChannel__c
            FROM Dan360_SalesArea__c
            WHERE Dan360_DistributionChannel__c = '00'
        ];
        Dan360_SalesArea__c salesAreaSinCargo = [
            SELECT Id, Dan360_DistributionChannel__c
            FROM Dan360_SalesArea__c
            WHERE Dan360_DistributionChannel__c = '05'
        ];
        Account account = [
            SELECT Id, Dan360_DistributionChannel__c,Dan360_SalesDistric1__c,Dan360_SalesDistrictColaborationRule__c
            FROM Account
            WHERE Name = 'Test'
        ];

        account.Dan360_DistributionChannel__c = 'Sin Cargo';
        account.Dan360_SalesDistric1__c = 'E-commerce';

        update account;
        List<Dan360_CustomerSalesArea__c> csaList = new List<Dan360_CustomerSalesArea__c>();
        Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesAreaVentaEstandar)
            .withIdExterno('5678-5800-01-01')
            .build();
        customerSalesArea.Dan360_District__c = 'AR3INS';
        csaList.add(customerSalesArea);
        Dan360_CustomerSalesArea__c customerSalesAreaTwo = Build.aCustomerSalesArea()
            .withName('Nuba 00')
            .withClient(account)
            .withUnidadNegocio(salesAreaSinCargo)
            .withIdExterno('5667-5771-01-01')
            .build();
        customerSalesAreaTwo.Dan360_District__c = 'AR3INS';
        csaList.add(customerSalesAreaTwo);
        // Actual test
        Test.startTest();
            insert csaList;
        Test.stopTest();

        Account accountToCompare = [
            SELECT Id, Dan360_DistributionChannel__c,Dan360_SalesDistric1__c,Dan360_SalesDistrictColaborationRule__c
            FROM Account
            WHERE Name = 'Test'
        ];
    
        // Asserts
        System.assertEquals('Sin Cargo; Venta Estándar', accountToCompare.Dan360_DistributionChannel__c, 'Error al asignar distribution channel');
        System.assertNotEquals(null, accountToCompare.Dan360_SalesDistric1__c, 'Error al asignar sales district');
        System.assertNotEquals(null, accountToCompare.Dan360_SalesDistrictColaborationRule__c, 'Error al asignar sales district colaboration rule');
    }
    @isTest
    private static void whenInsertCustomerSalesAreaForDifferentAccountMustConcatenateTheDifferentValuesToTheRelatedAccount() {
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        // Test data setup
        Dan360_SalesArea__c salesAreaVentaEstandar = [
            SELECT Id, Dan360_DistributionChannel__c
            FROM Dan360_SalesArea__c
            WHERE Dan360_DistributionChannel__c = '00'
        ];
        Dan360_SalesArea__c salesAreaSinCargo = [
            SELECT Id, Dan360_DistributionChannel__c
            FROM Dan360_SalesArea__c
            WHERE Dan360_DistributionChannel__c = '05'
        ];
        Account account = [
            SELECT Id, Dan360_DistributionChannel__c,Dan360_SalesDistric1__c,Dan360_SalesDistrictColaborationRule__c
            FROM Account
            WHERE Name = 'Test'
        ];
        account.Dan360_DistributionChannel__c = 'Sin Cargo';
        account.Dan360_SalesDistric1__c = 'E-commerce';

        update account;
        Account accountTwo = [
            SELECT Id, Dan360_DistributionChannel__c,Dan360_SalesDistric1__c,Dan360_SalesDistrictColaborationRule__c
            FROM Account
            WHERE Name = 'Test Two'
        ];

        accountTwo.Dan360_SalesDistric1__c = 'E-commerce;Instituciones';
        update accountTwo;

        List<Dan360_CustomerSalesArea__c> csaList = new List<Dan360_CustomerSalesArea__c>();
        Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesAreaVentaEstandar)
            .withIdExterno('5678-5800-01-01')
            .build();
        customerSalesArea.Dan360_District__c = 'AR3INS';
        csaList.add(customerSalesArea);
        Dan360_CustomerSalesArea__c customerSalesAreaTwo = Build.aCustomerSalesArea()
            .withName('Nuba 00')
            .withClient(account)
            .withUnidadNegocio(salesAreaSinCargo)
            .withIdExterno('5678-5771-01-01')
            .build();
        customerSalesAreaTwo.Dan360_District__c = 'AR3INS';
        csaList.add(customerSalesAreaTwo);
        Dan360_CustomerSalesArea__c customerSalesAreaThree = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(accountTwo)
            .withUnidadNegocio(salesAreaVentaEstandar)
            .withIdExterno('5688-5771-01-01')
            .build();
        customerSalesAreaThree.Dan360_District__c = 'AR3TEN';
        csaList.add(customerSalesAreaThree);
        // Actual test
        Test.startTest();
            insert csaList;
        Test.stopTest();

        Account accountToCompare = [
            SELECT Id, Dan360_DistributionChannel__c,Dan360_SalesDistric1__c,Dan360_SalesDistrictColaborationRule__c
            FROM Account
            WHERE Name = 'Test'
        ];
        Account accountToCompareTwo = [
            SELECT Id, Dan360_DistributionChannel__c,Dan360_SalesDistric1__c,Dan360_SalesDistrictColaborationRule__c
            FROM Account
            WHERE Name = 'Test Two'
        ];
        
        // Asserts
        System.assertEquals('Sin Cargo; Venta Estándar', accountToCompare.Dan360_DistributionChannel__c, 'Error al asignar distribution channel');
        System.assertNotEquals(null, accountToCompare.Dan360_SalesDistric1__c, 'Error al asignar sales district');
        System.assertNotEquals(null, accountToCompare.Dan360_SalesDistrictColaborationRule__c, 'Error al asignar sales district colaboration rule');

        System.assertEquals('Venta Estándar', accountToCompareTwo.Dan360_DistributionChannel__c, 'Error al asignar distribution channel');
        System.assertNotEquals(null, accountToCompareTwo.Dan360_SalesDistric1__c, 'Error al asignar sales district');
        System.assertNotEquals(null, accountToCompareTwo.Dan360_SalesDistrictColaborationRule__c, 'Error al asignar sales district colaboration rule');
    }
}