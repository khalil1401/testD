@isTest
public class BatchProductPerTemplateTest {
    static XHttpCalloutMock getResponse;
    static string datee;

    static{
		insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/', User_Key_Price__c='c3366a9f16190d9efda328ecec6f6833');
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
			.build();
		insert product;

		Product2 productTwo = Build.aProduct()
			.withName('Product Test2')
			.withUnidadesBulto(15)
			.withIsActive(true)
			.build();
		insert productTwo;

		Dan360_SalesArea__c salesArea = Build.aSalesArea()
            .withName('AMN-01-01')
            .withIdExterno('5771-01-01')
            .withDistributionChannel('01')
            .withDivision('01')
            .withSalesOrganization('5771')
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
			.withBusinessUnit('5771')
			.build();
		insert productsTemplate;

		Dan360_ProductoPorPlantilla__c productPerTemplate = Build.aProductoPorPlantilla()
			.withProduct(product)
			.withProductTemplate(productsTemplate)
			.withUnitMeasure('Unidad')
            .withVigenciaDesde(Date.Today().AddDays(-1))
			.withVigencia(Date.Today().AddDays(1))
            .withIsActive(false)
			.build();
		insert productPerTemplate;

		Dan360_ProductoPorPlantilla__c productPerTemplateTwo = Build.aProductoPorPlantilla()
			.withProduct(productTwo)
			.withProductTemplate(productsTemplate)
			.withUnitMeasure('Unidad')
            .withVigenciaDesde(Date.Today().AddDays(3))
			.withVigencia(Date.Today().AddDays(5))
            .withIsActive(true)
			.build();
		insert productPerTemplateTwo;

		Order orderTest = Build.anOrder()
			.withAccount(account)
			.withEffectiveDate(Date.today())
			.withStatus('Borrador')
			.withPurchaseOrder('Testing')
			.withBusinessUnit('5771')
			.withProductsTemplate(productsTemplate)
			.withCustomerSalesArea(customerSalesArea)
            .withPricebook(pricebookCustomer.id)
			.build();
		insert orderTest;

		OrderItem item = Build.anOrderItem()
			.withOrder(orderTest)
			.withProduct2Id(product)
			.withListPrice(pricebookPriceDefault.UnitPrice)
			.withUnitPrice(pricebookPriceDefault.UnitPrice)
			.withPricebookEntryId(pricebookPriceDefault)
			.withQuantity(1)
			.withDiscount(0.5)
			.build();
		insert item;

		OrderItem otherItem = Build.anOrderItem()
			.withOrder(orderTest)
			.withProduct2Id(productTwo)
			.withListPrice(pricebookPriceDefault2.UnitPrice)
			.withUnitPrice(pricebookPriceDefault2.UnitPrice)
			.withPricebookEntryId(pricebookPriceDefault2)
			.withQuantity(2)
			.withDiscount(0.5)
			.build();
		insert otherItem;

		datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getResponse = new XHttpCalloutMock();
        getResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(SapPricesMock.getSucess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
		
    }

    @isTest 
    public static void cuandoUnProductoPorPlantillaEstaDesactivadoPeroLasFechasEstanVigentesDebeActivarse() {
		Test.setMock(HttpCalloutMock.class, getResponse);
        Test.startTest();
            BatchProductPerTemplate batch = new BatchProductPerTemplate();
            Database.executeBatch(batch);
        Test.stopTest();
        
        List<Dan360_ProductoPorPlantilla__c> productsPerTemplate = [SELECT Id, Dan360_Activo__c 
			FROM  Dan360_ProductoPorPlantilla__c
			WHERE Dan360_Activo__c = true];
		System.assertEquals(1, productsPerTemplate.size(), 'El producto no fue eliminado de la orden.');
    }
}