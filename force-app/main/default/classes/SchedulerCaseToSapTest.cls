@isTest
public with sharing class SchedulerCaseToSapTest {
    static XHttpCalloutMock getPriceResponse;
    static string datee;
	static {
        
        List<OrderItem> orderItems = new List<OrderItem>();

        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/');
		               
        RecordType pedidoVentaDirecta = [SELECT id FROM RecordType where sObjectType='Order' and Name = 'Pedido de Venta Directa'];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Date todayDate = Date.Today();

        Account account = Build.anAccount()
            .withPricebook(pricebookId)
            .withCanalComercial('E-Commerce')
            .withName('Cuenta Prueba')
            .withIdSap('12345')
            .build();
        
        insert account;

        Product2 producto = Build.aProduct()
            .withName('Producto Test')
            .withUnidadesBulto(15)
            .withProductCode('00012')
            .withIdSap('106959')
            .build();

        insert producto;

        
        Dan360_Cuota__c cuotaOne = Build.aCuota()
            .withProducto(producto)
            .withCanalComercial('Acceso')
            .withVigenciaDesde(todayDate)
            .withVigenciaHasta(todayDate.addDays(6))
            .build();
        insert cuotaOne;

        
        List<PricebookEntry> pricebooksEntries = [
                                    SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
                                    FROM PricebookEntry
                                    WHERE Pricebook2Id = :pricebookId
                                    Limit 1];
           
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
        
       
        Order orderTestAMN = Build.anOrder()
            .withAccount(account)
            .withEffectiveDate(Date.today())
            .withEndDate(Date.today())
            .withFechaCierreCarrito(DateTime.now().addDays(5))
            .withFechaInicioCarrito(DateTime.now().addDays(1))
            .withStatus('Borrador')
            .withPurchaseOrder('00000742')
            .withBusinessUnit('5800')
            .withRecordType(pedidoVentaDirecta.Id)
            .withDescription('test')
            .withCustomerSalesArea(customerSalesArea)
            .withPricebook(pricebookId)
            .build();

        insert orderTestAMN;

        for(PricebookEntry pricebookEntry : pricebooksEntries) {
            orderItems.add(
            		Build.anOrderItem()
            			.withOrder(orderTestAMN)
            			.withProduct2Id(pricebookEntry.Product2Id)
            			.withListPrice(PricebookEntry.UnitPrice)
            			.withUnitPrice(PricebookEntry.UnitPrice)
            			.withQuantity(1)
            			.withPricebookEntryId(pricebookEntry)
            			.withDiscount(0.5)
            			.build()
            	);
            }
        
        insert orderItems;

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
        
        
        Dan360_Remito__c deliveryNote = Build.aRemito()
			.withPedido(orderTestAMN)
			.withSucursal(account)
			.build();
		insert deliveryNote;

        Dan360_Factura__c invoice = Build.aFactura()
			.withPedido(orderTestAMN)
			.withRemito(deliveryNote)
            .withSucursal(account)
            .withClient(account)
			.build();
		insert invoice;
                
        Id rtReturnCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Devoluciones').getRecordTypeId();

        Case complaint = Build.aReclamo()
			.withAccount(account)
			.withCantidadADevolver('20 unidades de PKU ANAMIX INFANT 6X400G MLL 3')
			.withFactura(invoice)
			.withMotivoDeReclamo('Producto Dañado')
			.withPedido(invoice.Dan360_Pedido__c)
			.withRemito(invoice.Dan360_Remito__c)
			.withSucursal(account)
			.withRecordType(rtReturnCase)
			.build();
            complaint.Status = 'Autorizado';
            complaint.Dan360_EnviadoSAP__c = false;
        insert complaint;

        Dan360_ProductosDeReclamo__c productReturnCase = Build.aProductoDeReclamo()
            .withUnidadMedida('PCE')
            .withIdLinea('00010')
            .withCantidadDevolver('0')
            .withProducto(producto)
            .withReclamo(complaint.Id)
            .build();
        insert productReturnCase;

        datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getPriceResponse = new XHttpCalloutMock();
        getPriceResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(SapPricesMock.getSucess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
           

	}
   
    @isTest
    static void sePuedeProgramarElProcesoEnviarASapCasos() {
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        Case casoTest = [SELECT Id, Status, CaseNumber, Dan360_MotivoDeReclamo__c, RecordType.Name, Dan360_Pedido__c,Dan360_EnviadoSAP__c, Description, 
        Dan360_RequiredDeliveryDate__c, Dan360_OrderedDate__c, Dan360_OrderGetStart__c,Dan360_OrderGetEnd__c,
        Dan360_Remito__r.Dan360_Delivery__c, Dan360_Factura__r.Dan360_Id_Externo__c, CreatedDate FROM Case WHERE CreatedDate != null LIMIT 1];
        // casoTest.Status = 'Autorizado';
        // update casoTest;
    //     ProcessInstance approvalProcess = [ 
    //         SELECT ID 
    //         FROM ProcessInstance 
    //         WHERE TargetObjectId = : casoTest.Id
    //     ];
    //     System.debug('ap '+ approvalProcess);
    //     ProcessInstanceWorkitem workItem = [ 
    //         SELECT ID
    //         FROM ProcessInstanceWorkitem 
    //         WHERE ProcessInstanceId  = : approvalProcess.Id
    //     ];
    //     System.debug('workitem '+ workItem);
    //    // List<Id> newWorkItemIds = workItem.Id;
    
    //     system.debug('status ' + casoTest.Status);
    //     Approval.ProcessWorkitemRequest proccesWorkitem = new Approval.ProcessWorkitemRequest();
    //     proccesWorkitem.setAction('Approve');
    //     proccesWorkitem.setWorkitemId(workItem.Id);

    //     ProcessInstanceStep workItemStep = [ 
    //         SELECT ID, StepStatus
    //         FROM ProcessInstanceStep 
    //         WHERE ProcessInstanceId  = : approvalProcess.Id
    //     ];
    //     System.debug('Status process '+ workItemStep.StepStatus);
        // Approval.ProcessResult result2 =  Approval.process(proccesWorkitem);

        // System.debug(result2.isSuccess());
        
        system.debug('status 2 ' + casoTest.Status);
        final String CRON_EXP = '0 0 22 * * ? *';

        Date dia = (Datetime.now().hour() >= 22) ? System.today().addDays(1) : System.today();
        Time tiempo = Time.newInstance(22, 0, 0, 0);

        Datetime proxEjecucion = Datetime.newInstance(
            dia, 
            tiempo
        );
                
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                                       CRON_EXP, 
                                       new SchedulerCaseToSap());

        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger 
            WHERE id = :jobId
        ];
        
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verificar proxima ejecucion
        System.assertEquals(
            proxEjecucion.format('yyyy-MM-dd HH:mm:ss'), 
            String.valueOf(ct.NextFireTime)
        );
        Test.stopTest();
    }
}