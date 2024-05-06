@isTest
public class ProductListComponentControllerTest {
    static XHttpCalloutMock getResponse;
    static string datee;
    
    static{
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		Profile profile1 = [Select Id from Profile where Name = 'System Administrator' or name = 'Administrador del sistema' ];

		User userTest = Build.aUser()
                .withUsername(
                    'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
                )               
                .withEmail('contacto1@xappia.com')
                .withAlias('contact1')
				.withLastName('Contacto1')
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('prueba2.xappia')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(profile1.Id)
				.withUserRoleId(portalRole)				
                .withLanguageLocaleKey('es')
                .build();           
                insert userTest;
                
        System.runAs(userTest){
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
                .withVigenciaDesde(Date.Today())
                .withVigencia(Date.Today().AddDays(5))
                .withIsActive(true)
                .build();
            insert productPerTemplateTwo;
    
            dAN360_PlantillaporcCuenta__c plantillaPorCuentaAMN = Build.aPlantillaPorCuenta()
                .withAccount(account)
                .withPlantillaDeProductos(productsTemplate)
                .withBusinessUnit('5800')
                .build();
            insert plantillaPorCuentaAMN;
    
            id pedidoVentaDirecta = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Dan360_PedidoVentaDirecta').getRecordTypeId();
    
            Order orderTest = Build.anOrder()
                .withAccount(account)
                .withEffectiveDate(Date.today())
                .withStatus('Borrador')
                .withPurchaseOrder('Testing')
                .withBusinessUnit('5800')
                .withRecordType(pedidoVentaDirecta)
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
    
           
            datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
            getResponse = new XHttpCalloutMock();
            getResponse.buildResponse()
                .withStatus('OK')
                .withStatusCode(200)
                .withBody(SapPricesMock.getSucess())
                .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
            
        }
    }

    @isTest
    private static void showsOnlyProductsForBusinessUnit(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        User aUser = [
            SELECT id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR 
            Profile.name = 'Administrador del sistema')
            AND Username LIKE '%@testorg.com'           
        ];
        System.runAs(aUser){
       
            Order orderTestAMN = [
                SELECT id, name ,AccountId, Dan360_UnidadNegocio__c 
                FROM Order 
                WHERE Dan360_UnidadNegocio__c = '5800'
            ];

            Test.startTest();           
                List<ProductListComponentController.WrapProduct> listProductTestAMN = ProductListComponentController.getProductList(orderTestAMN.Id);
            Test.stopTest();
           
            System.assertEquals(1, listProductTestAMN.size(), 'No todos los productos son de AMN');
            
        }

    }

    @isTest
    private static void showsOnlyProductsMatchInPlantillasAndPricebookAccount(){
        Test.setMock(HttpCalloutMock.class, getResponse);

        User aUser = [
            SELECT id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR 
            Profile.name = 'Administrador del sistema')
            AND Username LIKE '%@testorg.com'
        ];
        //Se agrega el producto generico a la plantilla AMN del cliente, pero no a su lista de precios de la cuenta.
        Product2 productToAdd = [
            SELECT id, Name 
            FROM Product2 
            WHERE Name = 'Product Test2'
        ];

        Dan360_PlantillaDeProductos__c plantillaDeProductos = [
            SELECT Id, Name FROM Dan360_PlantillaDeProductos__c 
            WHERE Name = 'Equis'
            ];      
            
        System.runAs(aUser){
                
                Dan360_ProductoPorPlantilla__c plantillaToAdd = Build.aProductoPorPlantilla()
                .withProduct(productToAdd)
                .withProductTemplate(plantillaDeProductos)
                .withVigencia(Date.today().addDays(2))
                .withVigenciaDesde(Date.today())
                .build();
                insert plantillaToAdd;         
                
                
            Order orderTestAMN = [
                SELECT id, name ,AccountId, Dan360_UnidadNegocio__c 
                FROM Order 
                WHERE Dan360_UnidadNegocio__c = '5800'
            ];  
            Test.startTest();            
                List<ProductListComponentController.WrapProduct> listProductTestAMN = ProductListComponentController.getProductList(orderTestAMN.Id);
            Test.stopTest();
            
            System.assertEquals(1, listProductTestAMN.size(), 'No todos los productos son de AMN');
        }
    
    }

    @isTest
    private static void saveButtonProcessJSONandSaveAndOrderItem(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        User aUser = [
            SELECT id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR 
            Profile.name = 'Administrador del sistema')
            AND Username LIKE '%@testorg.com'
        ];
        System.runAs(aUser){
            List<Order> orderTest = [
                SELECT id, Name 
                FROM Order 
                WHERE Dan360_UnidadNegocio__c = '5800'
            ];
        
            List<PricebookEntry> pricebookEntryAcc = [
                SELECT Id, Name, Product2Id, Pricebook2.Name,Pricebook2Id
                FROM PricebookEntry 
                WHERE Pricebook2.Name = 'CustomerPriceBook'             
            ];
            
            String stringProductos = '[{"bulto":10,"cantidad":"10","descuento":30,"name":"PKU ANAMIX INFANT 6X400G MLL 1","pedidoId":"'+String.valueOf(orderTest[0].Id)+'","price":400,"priceBookId":'+'"'+String.valueOf(pricebookEntryAcc[0].Id)+'"'+',"productoId":'+'"'+String.valueOf(pricebookEntryAcc[0].Product2Id)+'"'+',"totalPrice":4000,"unidadMedida":"Trade Unit"},{"bulto":10,"cantidad":"10","descuento":30,"name":"PKU ANAMIX INFANT 6X400G MLL 1","pedidoId":"'+String.valueOf(orderTest[0].Id)+'","price":400,"priceBookId":'+'"'+String.valueOf(pricebookEntryAcc[0].Id)+'"'+',"productoId":'+'"'+String.valueOf(pricebookEntryAcc[0].Product2Id)+'"'+',"totalPrice":4000,"unidadMedida":"Trade Unit"}]';
                
            Test.startTest();
                String result = ProductListComponentController.saveProducts(stringProductos);
            Test.StopTest();
            System.assertEquals('Los productos seleccionados se han agregado correctamente', result, 'Los items de orden no se agregaron correctamente');
        }
    }
}