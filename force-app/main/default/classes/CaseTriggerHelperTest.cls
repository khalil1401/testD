@isTest
public with sharing class CaseTriggerHelperTest {
    static XHttpCalloutMock getResponse;    
    static string datee;

	static {
        List<OrderItem> orderItems = new List<OrderItem>();

        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/');
		               
        RecordType pedidoVentaDirecta = [SELECT id FROM RecordType where sObjectType='Order' and Name = 'Pedido de Venta Directa'];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Date todayDate = Date.Today();

        Account account = Build.anAccount()
            .withPricebook(pricebookId)
            .withCanalComercial('E-Commerce')
            .withName('Cuenta Prueba')
            .withIdSap('12345')
            .withSalesDistric('Modern Trade')
            .build();
        
        insert account;

        Product2 producto = Build.aProduct()
            .withName('Producto Test')
            .withUnidadesBulto(15)
            .withProductCode('00012')
            .withIdSap('106959')
            .withIsActive(true)
            .build();

        insert producto;

        Product2 productoTwo = Build.aProduct()
            .withName('Producto Test2')
            .withUnidadesBulto(15)
            .withProductCode('00015')
            .withIdSap('166578')
            .withIsActive(true)
            .build();

        insert productoTwo;

        Dan360_Cuota__c cuotaOne = Build.aCuota()
            .withProducto(producto)
            .withCanalComercial('Acceso')
            .withVigenciaDesde(todayDate)
            .withVigenciaHasta(todayDate.addDays(6))
            .build();
        insert cuotaOne;

        Dan360_Cuota__c cuotaTwo = Build.aCuota()
            .withProducto(productoTwo)
            .withCanalComercial('Acceso')
            .withVigenciaDesde(todayDate)
            .withVigenciaHasta(todayDate.addDays(6))
            .build();
        insert cuotaTwo;

        List<PricebookEntry> pricebooksEntries = [
                                    SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
                                    FROM PricebookEntry
                                    WHERE Pricebook2Id = :pricebookId];
           
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

        

        Dan360_Partner__c shipt = Build.aPartner()
            .withIdExterno('0')
            .withRol('WE')
            .withClient(account)
            .withCustomerSalesArea(customerSalesArea)
            .withName('Ship to')
            .build();

        insert shipt;

        Dan360_Partner__c sold = Build.aPartner()
            .withIdExterno('3814320001')
            .withRol('AG')
            .withClient(account)
            .withCustomerSalesArea(customerSalesArea)
            .withName('Sold to')
            .build();

        insert sold;

        Dan360_Factura__c factura = Build.aFactura()
            .withPedido(orderTestAMN)
            .withSucursal(account)
            .withClient(account)
            .build();

        insert factura;

        Id rtReturnCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Devoluciones').getRecordTypeId();
                
        Case returnCase = Build.aReclamo()
            .withAccount(account)
            .withFactura(factura)
            .withPedido(orderTestAMN.Id)
            .withMotivoDeReclamo('PRODA')
            .withRecordType(rtReturnCase)
            .build();

        insert returnCase;
       
        Dan360_ProductosDeReclamo__c productReturnCase = Build.aProductoDeReclamo()
            .withUnidadMedida('PCE')
            .withIdLinea('00010')
            .withCantidadDevolver('10')
            .withProducto(producto)
            .withReclamo(returnCase.Id)
            .build();

        insert productReturnCase;

        Id rtDifferenceCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Diferencia de precios y descuentos').getRecordTypeId();
                
        Case DifferenceCase = Build.aReclamo()
            .withAccount(account)
            .withFactura(factura)
            .withPedido(orderTestAMN.Id)
            .withMotivoDeReclamo('PRODA')
            .withRecordType(rtDifferenceCase)
            .build();

        insert DifferenceCase;
       
        Dan360_ProductosDeReclamo__c productDifferenceCase = Build.aProductoDeReclamo()
            .withUnidadMedida('PCE')
            .withIdLinea('00010')
            .withCantidadDevolver('10')
            .withProducto(producto)
            .withReclamo(DifferenceCase.Id)
            .build();

        insert productDifferenceCase;
              
        datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getResponse = new XHttpCalloutMock();
        getResponse.buildResponse()
			.withStatus('OK')
			.withStatusCode(200)
			.withBody(SapPricesMock.getSucess())
			.addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
			//.addForAddress('https://www.danapi.com.ar/testing/masterdata/price/sn?date='+datee+'&organizationId=5800&channelId=01&divisionId=01&customer=550071632');
		
		getResponse.buildResponse()
			.withStatus('OK')
			.withStatusCode(200)
			.withBody(WebServiceSapMock.getAltaSuccess())
			.addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.UrlCreateOrderExtension__c);
	}
    @isTest
    private static void whendUpdateReturnCaseMustUpdateStatusToAuthorized() {
        // Test data setup
        Test.setMock(HttpCalloutMock.class, getResponse);

        Id rtReturnCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Devoluciones').getRecordTypeId();
        Case returnCase = [
            SELECT Id, Status, Dan360_ReclamoAprobado__c
            FROM Case
            WHERE RecordTypeId = :rtReturnCase
        ];
        returnCase.Dan360_ReclamoAprobado__c = true;
        // firts approve

        List<Approval.ProcessWorkitemRequest> approvalRequests = new List<Approval.ProcessWorkitemRequest>();

        // Query the ProcessInstanceWorkitem object to get the approval process work items
        List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObjectId =:returnCase.Id];

        for (ProcessInstanceWorkitem workItem : workItems) {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Auto-approved through Apex');
            req.setAction('Approve');
            req.setWorkitemId(workItem.Id);
            approvalRequests.add(req);
        }

        if (!approvalRequests.isEmpty()) {
            List<Approval.ProcessResult> results = Approval.process(approvalRequests);        
        }        
        
        // Actual test
        Test.startTest();
            //update returnCase;
        Test.stopTest();        
        List<Approval.ProcessWorkitemRequest> approvalRequestsTwo = new List<Approval.ProcessWorkitemRequest>();

        // Query the ProcessInstanceWorkitem object to get the approval process work items
        List<ProcessInstanceWorkitem> workItemsTwo = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObjectId =:returnCase.Id];

        for (ProcessInstanceWorkitem workItem : workItemsTwo) {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Auto-approved through Apex');
            req.setAction('Approve');
            req.setWorkitemId(workItem.Id);
            approvalRequestsTwo.add(req);
        }

        if (!approvalRequestsTwo.isEmpty()) {
            List<Approval.ProcessResult> results = Approval.process(approvalRequestsTwo);        
        }
        
        Case returnCaseToCompare = [
            SELECT Id, Status, Dan360_ReclamoAprobado__c
            FROM Case
            WHERE RecordTypeId = :rtReturnCase
        ];
        // Asserts
        System.assertEquals('Autorizado', returnCaseToCompare.Status, 'Error to update status');
    }
    
}