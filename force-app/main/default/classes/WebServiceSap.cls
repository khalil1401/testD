public with sharing class WebServiceSap {
    @TestVisible
    private static final ApiDanone__c SERVICE_CONFIG = ApiDanone__c.getInstance();
    
    public static SendAlta sendAltaToSap (String body, String typeObj, String recordName){
        String url;
        
        switch on (typeObj){
            when 'Case' {
                if(recordName == 'Devoluciones' || recordName == 'Devoluciones de pedidos sin cargo'){
                    url = SERVICE_CONFIG.URL__c + SERVICE_CONFIG.UrlreturnExtension__c;
                }
                if(recordName == 'Diferencia de precios y descuentos' || recordName == 'Reclamo por faltantes'){
                    url = SERVICE_CONFIG.URL__c + SERVICE_CONFIG.UrlClaimExtension__c;
                }
            }
            when 'Order' {url = SERVICE_CONFIG.URL__c + SERVICE_CONFIG.UrlCreateOrderExtension__c;}
        }
        System.debug('url');
        System.debug(url);
        RestWS ws = new RestWS(
            url,
            'POST',
            null,
            body
        );
        ws.request.setHeader('Content-Type', 'application/json');
        ws.request.setHeader('user_key', SERVICE_CONFIG.User_Key__c);
        ws.request.setTimeout(10000);
        SendAlta resp = (SendAlta) ws.invoke(new SendAlta());
        return resp;
    }

    @TestVisible
    public static matPricesResponse askMaterialPricesSAP(String fechaPedido, String salesOrganization, String distributionChannel, String division, String customerId){
        String url = SERVICE_CONFIG.URL__c + SERVICE_CONFIG.urlMatPrices__c;
        WSParameter[] params = new WSParameter[] { 
            new WSParameter( 'date', fechaPedido , true ), 
            new WSParameter( 'organizationId',salesOrganization, true ),
            new WSParameter( 'channelId', distributionChannel , true ), 
            new WSParameter( 'divisionId',division, true ),
            new WSParameter( 'customer',customerId, true )
        };
        System.debug('params');
        System.debug(params);
        RestWS ws = new RestWS(
            url + 'sn?date={0}&organizationId={1}&channelId={2}&divisionId={3}&customer={4}',
            'GET',
            params
        );
        System.debug('ws');
        System.debug(ws);
        ws.request.setHeader('user_key', SERVICE_CONFIG.User_Key_Price__c);
        matPricesResponse resp = (matPricesResponse) ws.invoke(new matPricesResponse());
        return resp;
    }


    public class SendAlta extends WSResult{
        public ResponseSapOrder respuestaSAP ;
        public override void processResponse(HttpResponse response) {
            System.debug(response.getBody());
        }
 
		public override void processErrorResponse(HttpResponse response) {
            System.debug('processErrorResponse');
            System.debug(response.getBody());    
		}
    }


    public class matPricesResponse extends WSResult{
        public MatPriceUtilityJson matPricesResponseObj ;
        public override void processResponse(HttpResponse response) {
            matPricesResponseObj = MatPriceUtilityJson.parse(response.getBody());
            System.debug(response.getBody());
        }
 
		public override void processErrorResponse(HttpResponse response) {
            System.debug('processErrorResponse');
            System.debug(response.getBody());    
		}
    }


    public class ResponseSapOrder {
        @AuraEnabled
        public Integer code {get; set;}
        @AuraEnabled
        public String description {get; set;}
    }
}