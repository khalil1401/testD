@isTest
public with sharing class WebServiceSapTest {
   static string orderBody;
   static string caseReturnBody;
   static XHttpCalloutMock getAltaResponse;
   static XHttpCalloutMock getAltaErrorResponse;
   static XHttpCalloutMock getPriceResponse;
   static XHttpCalloutMock getCaseReturnResponse;
   static XHttpCalloutMock getCaseClaimResponse;
   static string datee;

   static {
        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/	');

        getAltaResponse = new XHttpCalloutMock();
        getAltaResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(WebServiceSapMock.getAltaSuccess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.UrlCreateOrderExtension__c);
        
        getCaseReturnResponse = new XHttpCalloutMock();
        getCaseReturnResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(WebServiceSapMock.getAltaSuccess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.UrlreturnExtension__c);

        getCaseClaimResponse = new XHttpCalloutMock();
        getCaseClaimResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(WebServiceSapMock.getAltaSuccess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.UrlClaimExtension__c);

        
        getAltaErrorResponse = new XHttpCalloutMock();
        getAltaErrorResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(500)
            .withBody(WebServiceSapMock.getAltaError())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.UrlCreateOrderExtension__c);

        datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getPriceResponse = new XHttpCalloutMock();
        getPriceResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(SapPricesMock.getSucess())
            .addForAddress('https://www.danapi.com.ar/testing/masterdata/price/sn?date='+datee+'&organizationId=5800&channelId=01&divisionId=01&customer=550071632');


        orderBody = '{' +
        '"orderNumber": 231241,' +
        '"soldTo": 3814320001,' +
        '"shipTo": 0,' +
        '"companyCode": 5800,' +
        '"source": "00",' +
        '"orderType": "ZSO",' +
        '"reqDelDate": "2021-11-04T00:00:00",' +
        '"orderDate": "2021-11-01T00:00:00",' +
        '"orderGetStart": "2021-11-01T10:00:00",' +
        '"orderGetFinal": "2021-11-01T11:00:00",' +
        '"poType": "UUU",' +
        '"note": "",' +
        '"items": [{' +
            '"itemNumber": 1,' +
            '"matNumber": 600322' +
            '"orderedQuantity": 40.00' +
            '"um": "UN"' +
         '}]' +
        '}';

        caseReturnBody = '{'+
	        '"source": "JUAN",'+
	        '"orderNumber": "9000229",'+
	        '"referenceDocNumber": "7777777",'+
	        '"soldTo": "3814327777",'+
	        '"shipTo": "3814328888",'+
	        '"organizationId": "8789",'+
	        '"channelId": "04",'+
	        '"orderReason": "AR6",'+
	        '"returnReason": "PROVEN",'+
	        '"reqDelDate": "2021-11-04T00:00:00",'+
	        '"orderDate": "2021-11-01T00:00:00",'+
	        '"orderGetStart": "2021-11-01T10:00:00",'+
	        '"orderGetFinal": "2021-11-01T11:00:00",'+
	        '"poType": "PO",'+
	        '"note": "Esta es una prueba de order return",'+
	        '"items": [{'+
	        	'"refItemNumber": "00050",'+
	        	'"matNumber": "600324",'+
	        	'"orderedQuantity": 43.00,'+
	        	'"um": "PCE"'+
	        	'},'+
                '{'+
	        	'"refItemNumber": "00020",'+
	        	'"matNumber": "600366",'+
	        	'"orderedQuantity": 65.00,'+
	        	'"um": "PCE"'+
	        	'}'+
	        ']'+
        '}' ;
    }
    @isTest
    public static void SendOrderIfSucessCodeMustBe200(){
        String typeObj = 'Order';
        String recordName = 'Pedido Venta Directa';
        Test.setMock(HttpCalloutMock.class, getAltaResponse);
        Test.startTest();
        WebServiceSap.SendAlta respuesta = WebServiceSap.sendAltaToSap(orderBody, typeObj,recordName);
        Test.stopTest();
        System.debug(respuesta);
        System.assertEquals(200, respuesta.response.getStatusCode(), 'El codigo no es 200, fallo');
    }
    @isTest
    public static void SendOrderCodeMustBe500IfFail(){
        String typeObj = 'Order';
        String recordName = 'Pedido Venta Directa';
        Test.setMock(HttpCalloutMock.class, getAltaErrorResponse);
        Test.startTest();
        WebServiceSap.SendAlta respuesta = WebServiceSap.sendAltaToSap(orderBody, typeObj,recordName);
        Test.stopTest();
        System.debug(respuesta);
        System.assertEquals(500, respuesta.response.getStatusCode(), 'El codigo no es 500, fallo');
    }

    @isTest
    public static void SendReturnCaseSucessCode200(){
        String typeObj = 'Case';
        String recordName = 'Devoluciones';
        Test.setMock(HttpCalloutMock.class, getCaseReturnResponse);
        Test.startTest();
        WebServiceSap.SendAlta respuesta = WebServiceSap.sendAltaToSap(caseReturnBody, typeObj,recordName);
        Test.stopTest();
        System.debug(respuesta);
        System.assertEquals(200, respuesta.response.getStatusCode(), 'El codigo no es 200, fallo');
    }

    @isTest
    public static void SendClaimCaseSucessCode200(){
        String typeObj = 'Case';
        String recordName = 'Diferencia de precios y descuentos';
        Test.setMock(HttpCalloutMock.class, getCaseClaimResponse);
        Test.startTest();
        WebServiceSap.SendAlta respuesta = WebServiceSap.sendAltaToSap(caseReturnBody, typeObj,recordName);
        Test.stopTest();
        System.debug(respuesta);
        System.assertEquals(200, respuesta.response.getStatusCode(), 'El codigo no es 200, fallo');
    }

    @isTest
    public static void askPriceFromSap() {
        String fechaPedido = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        Test.StartTest();
        WebServiceSap.matPricesResponse respuesta = WebServiceSap.askMaterialPricesSAP(fechaPedido, '5800', '01', '01', '550071632'); 
        Test.stopTest();
        System.assertEquals(200, respuesta.response.getStatusCode(), 'El codigo no es 200, fallo');
    }
}