/**
 * Company:      CloudGaia
 * Description:  Test class for REST Resource for Confirm.
 * Test Class:   SFCCConfirmHelper_Test
 */
@isTest
public class SFCCConfirmHelper_Test {
    @TestSetup
    public static void generateData() {
        LVC_DistributionCenter__c distributionCenter = new LVC_DistributionCenter__c(
            Name = 'Danone Sur',    
            CDExternalId__c = '1'
        );
        insert distributionCenter;
        LVC_Polygon__c polygon = new LVC_Polygon__c(
            PolygonExternalId__c = '12341234', 
            Type__c = 'T2', 
            DistributionCenter__c = distributionCenter.Id, 
            TownId__c = '14'
        );
        insert polygon;

        LVC_Delivery__c delivery = new LVC_Delivery__c(
            Monday__c = 30,
            Tuesday__c = 30,
            Wednesday__c = 30,
            Thursday__c = 30,
            Friday__c = 30,
            Saturday__c = 10,
            Sunday__c = 10,
            Active__c = true
        );
        insert delivery;

        LVC_DeliveryRoute__c deliveryRoute_T2 = new LVC_DeliveryRoute__c(
            DeliverySchedule__c = 'M',
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            Thursday__c = true,
            Friday__c = true,
            Saturday__c = true,
            Sunday__c = false,
            Active__c = true,
            DeliveryRouteExternalId__c = '00010001',
            Delivery__c = delivery.Id,
            RouteId__c = '1'
        );
        insert deliveryRoute_T2;

        LVC_PolygonRoute__c polygonRoute = new LVC_PolygonRoute__c(
            Polygon__c = polygon.Id,
            DeliveryRoute__c = deliveryRoute_T2.Id
        );
        insert polygonRoute;

        LVC_ProductStockDate__c productStockDate = new LVC_ProductStockDate__c(
            DistributionCenter__c = distributionCenter.Id,
            StockDate__c = Date.newInstance(2022, 04, 30),
            Sku__c = '4771',
            Stock__c = 300
        );
        insert productStockDate;       
        
        LVC_OrderQuantityDate__c orderQuantityDate_T2 = new LVC_OrderQuantityDate__c(
            Date__c = Date.newInstance(2022, 04, 30), 
            Delivery__c = delivery.Id
        );
        insert orderQuantityDate_T2;
        LVC_Order__c order_T2 = new LVC_Order__c(
            OrderExternalId__c = 'DAN-0001', 
            OrderQuantityDate__c = orderQuantityDate_T2.Id, 
            DNI__c = '123', 
            Address__c = 'test', 
            Date__c = Date.newInstance(2022, 04, 30)
        );
        insert order_T2;

        LVC_OrderProduct__c orderProduct_T2 = new LVC_OrderProduct__c(
            Quantity__c = 5,
            Order__c = order_T2.Id, 
            ProductStockDate__c = productStockDate.Id,
            Sku__c = productStockDate.Sku__c
        );
        insert orderProduct_T2;
    }

    @isTest static void parseRequest(){
        Test.startTest();
        SFCCConfirmRequestWrapper req = SFCCConfirmRequestWrapper.parse(requestContentBody());
        System.debug(req);
        Test.stopTest();
    }
    
    @isTest static void confirmationTest(){
        //given
        RestRequest request = new RestRequest(); 
        RestResponse restResponse = new RestResponse(); 
        String contentData = requestContentBody();
		
        //when
        Test.startTest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(contentData);
        RestContext.request = request;
        RestContext.response = restResponse;

        RESTConfirm.doPost();
        Blob responseBody = RestContext.response.responseBody;
        Test.stopTest();
    }

    @isTest static void confirmationWithoutStockTest(){
        //given
        RestRequest request = new RestRequest(); 
        RestResponse restResponse = new RestResponse(); 
        String contentData = requestContentBodyWithoutStock();
		
        //when
        Test.startTest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(contentData);
        RestContext.request = request;
        RestContext.response = restResponse;

        RESTConfirm.doPost();
        Blob responseBody = RestContext.response.responseBody;
        Test.stopTest();
    }

    @isTest static void confirmationWithoutOrdersTest(){
        LVC_OrderQuantityDate__c orderQuantityDate = [SELECT Id, Date__c FROM LVC_OrderQuantityDate__c WHERE Date__c = 2022-04-30 LIMIT 1];
        orderQuantityDate.Date__c = Date.today();
        update orderQuantityDate;

        //given
        RestRequest request = new RestRequest(); 
        RestResponse restResponse = new RestResponse(); 
        String contentData = requestContentBody();
		
        //when
        Test.startTest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(contentData);
        RestContext.request = request;
        RestContext.response = restResponse;

        RESTConfirm.doPost();
        Blob responseBody = RestContext.response.responseBody;
        Test.stopTest();
    }

    private static String requestContentBody(){
        return '{"completeAddress":"Martina Cespedes 2008, Villa Adelina, Buenos Aires","customerNationalId":"33123123","orderId":"DAN-123415","polygon":"12341234","products":[{"sku":"4771","quantity":5}],"selectedDate":"2022-04-30","selectedTime":"M"}';
    }
    
    private static String requestContentBodyWithoutStock(){
        return '{"completeAddress":"Martina Cespedes 2008, Villa Adelina, Buenos Aires","customerNationalId":"33123123","orderId":"DAN-123415","polygon":"12341234","products":[{"sku":"4771","quantity":5}, {"sku":"1234","quantity":5}],"selectedDate":"2022-04-30","selectedTime":"M"}';
    }

    private static String responseContentBody(){
        return '{"success": true,"errorCode": "ERR001","zipCode": "1650","activityId": "70","townId": 2,"sfId": "a0348a7sdfasdfaksdjhfa98sdf"}';
    }
}