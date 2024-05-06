/**
 * @author            : Diego Valle
 * @created date      : 20-09-2021
 * @group             :
 * @last modified on  : 22-09-2021
 * @last modified by  : Diego Valle
 * @description       :
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   20-09-2021   Diego Valle   Initial Version
**/
@IsTest
public with sharing class ProductTriggerHandlerTest {
    @TestSetup
    static void setup(){
		Id pricebookId = Test.getStandardPricebookId();

		Account account = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account Test')
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

		PricebookEntry pricebookPriceDefault = [SELECT UnitPrice 
										FROM PricebookEntry
										WHERE  Product2Id = :product.Id];

		PricebookEntry pricebookPriceDefault2 = [SELECT UnitPrice 
										FROM PricebookEntry
										WHERE  Product2Id = :productTwo.Id];

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
			.build();
		insert productPerTemplate;

		Dan360_ProductoPorPlantilla__c productPerTemplateTwo = Build.aProductoPorPlantilla()
			.withProduct(productTwo)
			.withProductTemplate(productsTemplate)
			.withUnitMeasure('Unidad')
			.withVigenciaDesde(Date.Today().AddDays(-1))
			.withVigencia(Date.Today().AddDays(1))
			.build();
		insert productPerTemplateTwo;

		Order orderTest = Build.anOrder()
			.withAccount(account)
			.withEffectiveDate(Date.today())
			.withStatus('Borrador')
			.withPurchaseOrder('Testing')
			.withBusinessUnit('5771')
			.withPricebook(pricebookId)
			.withProductsTemplate(productsTemplate)
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
    }

    @IsTest
    private static void cuandoProductoEsDesactivadoDeberiaRemoverseDePedidos() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        product.isActive = false;

        Test.startTest();
            update product;
        Test.stopTest();

        List<OrderItem> items = [SELECT Id FROM OrderItem WHERE OrderId = :order.Id];
        System.assertEquals(1, items.size(), 'El producto no se elimino de la orden.');
    }
    @IsTest
    private static void cuandoProductoEsCreadoDeberiaCrearUnNuevoPriceBookEntry() {
        List<PricebookEntry> priceBookEntries = [SELECT Id FROM PricebookEntry ];
        Product2 product = Build.aProduct()
			.withName('Product Test 3')
			.withUnidadesBulto(15)
			.withIsActive(true)
			.build();
			
		Test.startTest();
			insert product;            
        Test.stopTest();

        List<PricebookEntry> priceBookEntriesToCompare = [SELECT Id FROM PricebookEntry ];
        System.assertEquals(priceBookEntries.size() + 1, priceBookEntriesToCompare.size(), 'El pricebookEntry no se Creo.');
    }
}