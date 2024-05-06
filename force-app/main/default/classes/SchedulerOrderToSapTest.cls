@isTest
public with sharing class SchedulerOrderToSapTest {
    static XHttpCalloutMock getResponse;
	static {

        RecordType pedidoVentaDirecta = [
            SELECT id 
            FROM RecordType
            WHERE sObjectType='Order' and Name = 'Pedido de Venta Directa'
        ];

        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 producto = Build.aProduct()
            .withName('Producto Test')
            .withUnidadesBulto(15)
            .withProductCode('00012')
            .build();
        insert producto;


        Dan360_SalesArea__c salesArea = Build.aSalesArea()
            .withName('AMN-01-01')
            .withIdExterno('5800-01-01')
            .withDistributionChannel('01')
            .withDivision('01')
            .withSalesOrganization('5800')
            .build();
        insert salesArea;

        Account account = Build.anAccount()
            .withPricebook(pricebookId)
            .withName('Account Test')
            .withIdSap('1234')
            .withSalesDistric('E-Commerce')
			.withDistributionChannel('00')
			.build();
		insert account;
        
        
        Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
        .withName('AMN 00')
        .withClient(account)
        .withUnidadNegocio(salesArea)
        .withIdExterno('5678-5800-01-01')
        .build();
        insert customerSalesArea;

        Dan360_Partner__c partnetShiptTo = Build.aPartner()
            .withName('Partner Shipt To')
            .withIdExterno('0')
            .withRol('WE')
            .withClient(account)
            .withCustomerSalesArea(customerSalesArea)
            .build();
        insert partnetShiptTo;

        Dan360_Partner__c partnetSoldTo = Build.aPartner()
            .withName('Partner Sold To')
            .withIdExterno('3814320001')
            .withRol('AG')
            .withClient(account)
            .withCustomerSalesArea(customerSalesArea)
            .build();
        insert partnetSoldTo;

        Order orderTestAMN = Build.anOrder()
            .withAccount(account)
            .withEffectiveDate(Date.today().addDays(2))
            .withEndDate(Date.today().addDays(2))
            .withFechaCierreCarrito(DateTime.now().addDays(5))
            .withFechaInicioCarrito(DateTime.now().addDays(1))
            .withStatus('Borrador')
            .withPurchaseOrder('00000742')
            .withBusinessUnit('5800')
            .withRecordType(pedidoVentaDirecta.Id)
            .withPricebook(pricebookId)
            .withDescription('test')
            .withCustomerSalesArea(customerSalesArea)
            .build();
        orderTestAMN.Dan360_OrderReason__c = 'APN';
        insert orderTestAMN;

        List<PricebookEntry> pricebooksEntries = [
										SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
										FROM PricebookEntry
										WHERE Pricebook2Id = :pricebookId];

        OrderItem item = Build.anOrderItem()
            .withOrder(orderTestAMN)
            .withProduct2Id(producto)
            .withListPrice(100)
            .withUnitPrice(100)
            .withPricebookEntryId(pricebooksEntries[0])
            .withQuantity(1)
            .withDiscount(0.5)
            .build();
        insert item;

        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', urlMatPrices__c = '/testing/masterdata/price/',UrlCreateOrderExtension__c = '/testing/sales/orders/v1' );

		String datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
		getResponse = new XHttpCalloutMock();
        getResponse.buildResponse()
			.withStatus('OK')
			.withStatusCode(200)
			.withBody(SapPricesMock.getSucess())
			.addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
    }
    @isTest
    static void sePuedeProgramarElProcesoEnviarASapOrdenesConfirmadas() {
        Test.setMock(HttpCalloutMock.class, getResponse);
        Order orderTest = [Select Id, Status FROM Order LIMIT 1];
        orderTest.status = 'Confirmado';
        orderTest.Dan360_PedidoConfirmado__c = true;
        update orderTest;

        final String CRON_EXP = '0 0 22 * * ? *';

        Date dia = (Datetime.now().hour() >= 22) ? System.today().addDays(1) : System.today();
        Time tiempo = Time.newInstance(22, 0, 0, 0);

        Datetime proxEjecucion = Datetime.newInstance(
            dia, 
            tiempo
        );        
                
        Test.startTest();
        String jobId = System.schedule('ScheduledApextest',
                                       CRON_EXP, 
                                       new SchedulerOrderToSap());

        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger 
            WHERE id = :jobId
        ];


        System.assertEquals(CRON_EXP,  ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verificar proxima ejecucion
        System.assertEquals(
            proxEjecucion.format('yyyy-MM-dd HH:mm:ss'), 
            String.valueOf(ct.NextFireTime)
        );
        Test.stopTest();
    }
    @isTest
    static void noSeProgramaOrdenesNoConfirmadas() {
        Test.setMock(HttpCalloutMock.class, getResponse);
        Order orderTest = [Select Id, Status FROM Order LIMIT 1];

        final String CRON_EXP = '0 0 22 * * ? *';

        Date dia = (Datetime.now().hour() >= 22) ? System.today().addDays(1) : System.today();
        Time tiempo = Time.newInstance(22, 0, 0, 0);

        Datetime proxEjecucion = Datetime.newInstance(
            dia, 
            tiempo
        );

        try{
            Test.startTest();
            String jobId = System.schedule('ScheduledApextest',
                                           CRON_EXP, 
                                           new SchedulerOrderToSap());

            CronTrigger ct = [
                SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger 
                WHERE id = :jobId
            ];
            
            System.assertEquals(CRON_EXP, 
                                ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
            
            // Verificar proxima ejecucion
            System.assertEquals(
                proxEjecucion.format('yyyy-MM-dd HH:mm:ss'), 
                String.valueOf(ct.NextFireTime)
            );
            Test.stopTest();
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
    }
}