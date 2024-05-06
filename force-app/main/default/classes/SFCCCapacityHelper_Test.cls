/**
 * Company:      CloudGaia
 * Description:  Test class for REST Resource for Capacity.
 * Test Class:   SFCCCapacityHelper_Test
 */
@isTest
public class SFCCCapacityHelper_Test {
    @isTest static void parseRequest(){
        Test.startTest();
        SFCCCapacityRequestWrapper.parse(requestContentBody_T2());
        Test.stopTest();
    }

    @isTest static void parseResponse(){
        Test.startTest();
        SFCCCapacityResponseWrapper.parse(responseContentBody());
        Test.stopTest();
    }

    @TestSetup static void generateData(){
        LVC_DistributionCenter__c distributionCenter = new LVC_DistributionCenter__c(
            Name = 'CD General Rodriguez',    
            CDExternalId__c = '1',
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            Thursday__c = true,
            Friday__c = true,
            Saturday__c = false,
            Sunday__c = false
        );
        insert distributionCenter;
        LVC_Polygon__c polygon = new LVC_Polygon__c(
            Name = '12341234',
            PolygonExternalId__c = '12341234', 
            Type__c = 'T2', 
            DistributionCenter__c = distributionCenter.Id, 
            TownId__c = '14'
        );
        insert polygon;
        LVC_Polygon__c polygonClosedNeighborhood = new LVC_Polygon__c(
            Name = '12344321',
            PolygonExternalId__c = '12344321', 
            Type__c = 'T3', 
            DistributionCenter__c = distributionCenter.Id, 
            TownId__c = '10'
        );
        insert polygonClosedNeighborhood;

        LVC_Delivery__c deliveryT2 = new LVC_Delivery__c(
            Monday__c = 30,
            Tuesday__c = 30,
            Wednesday__c = 30,
            Thursday__c = 30,
            Friday__c = 30,
            Saturday__c = 10,
            Sunday__c = 10,
            Active__c = true
        );
        insert deliveryT2;

        LVC_DeliveryRoute__c deliveryRoute_T2 = new LVC_DeliveryRoute__c(
            Delivery__c = deliveryT2.Id,
            DeliverySchedule__c = 'D',
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            Thursday__c = true,
            Friday__c = true,
            Saturday__c = false,
            Sunday__c = false,
            Active__c = true,
            DeliveryRouteExternalId__c = '00010001',
            RouteId__c = '1'
        );
        insert deliveryRoute_T2;

        LVC_PolygonRoute__c polygonRoute_T2 = new LVC_PolygonRoute__c(
            Polygon__c = polygon.Id,
            DeliveryRoute__c = deliveryRoute_T2.Id
        );
        insert polygonRoute_T2;

        LVC_Delivery__c deliveryT3 = new LVC_Delivery__c(
            Monday__c = 10,
            Tuesday__c = 10,
            Wednesday__c = 10,
            Thursday__c = 10,
            Friday__c = 10,
            Saturday__c = 5,
            Sunday__c = 0,
            Active__c = true
        );
        insert deliveryT3;

        LVC_DeliveryRoute__c deliveryRoute_T3 = new LVC_DeliveryRoute__c(
            Delivery__c = deliveryT3.Id,
            DeliverySchedule__c = 'M',
            Monday__c = false,
            Tuesday__c = false,
            Wednesday__c = false,
            Thursday__c = false,
            Friday__c = true,
            Saturday__c = true,
            Sunday__c = true,
            Active__c = true,
            DeliveryRouteExternalId__c = '00020001',
            RouteId__c = '1'
        );
        insert deliveryRoute_T3;

        LVC_PolygonRoute__c polygonRoute_T3 = new LVC_PolygonRoute__c(
            Polygon__c = polygon.Id,
            DeliveryRoute__c = deliveryRoute_T3.Id
        );
        insert polygonRoute_T3;

        List<LVC_ProductStockDate__c> productStockDate = new List<LVC_ProductStockDate__c>();
        for(integer i = 0; i<8; i++){
            LVC_ProductStockDate__c product = new LVC_ProductStockDate__c(
                DistributionCenter__c = distributionCenter.Id,
                StockDate__c = Date.today().addDays(i),
                Sku__c = '4771',
                Stock__c = 1000
            );
            productStockDate.add(product);
        }
        insert productStockDate;

        LVC_OrderQuantityDate__c orderQuantityDate_T2 = new LVC_OrderQuantityDate__c(
            Date__c = Date.today().addDays(2), 
            Delivery__c = deliveryT2.Id
        );
        insert orderQuantityDate_T2;
        LVC_Order__c order_T2 = new LVC_Order__c(
            OrderExternalId__c = 'DAN-0001', 
            OrderQuantityDate__c = orderQuantityDate_T2.Id, 
            DNI__c = '123', 
            Address__c = 'test', 
            Date__c = Date.today().addDays(2)
        );
        insert order_T2;

        LVC_OrderQuantityDate__c orderQuantityDate_T3 = new LVC_OrderQuantityDate__c(
            Date__c = Date.today().addDays(2),
            Delivery__c = deliveryT3.Id
        );
        insert orderQuantityDate_T3;
        LVC_Order__c order_T3 = new LVC_Order__c(
            OrderExternalId__c = 'DAN-0005', 
            OrderQuantityDate__c = orderQuantityDate_T3.Id, 
            DNI__c = '48678429', 
            Address__c = 'Main ST 11202', 
            Date__c = Date.today().addDays(2)
        );
        insert order_T3;
        LVC_OrderProduct__c orderProduct_T2 = new LVC_OrderProduct__c(
            Quantity__c = 5,
            Order__c = order_T2.Id, 
            ProductStockDate__c = productStockDate[0].Id,
            Sku__c = productStockDate[0].Sku__c
        );
        insert orderProduct_T2;
        LVC_OrderProduct__c orderProduct_T3 = new LVC_OrderProduct__c(
            Quantity__c = 10,
            Order__c = order_T3.Id, 
            ProductStockDate__c = productStockDate[0].Id,
            Sku__c = productStockDate[0].Sku__c
        );
        insert orderProduct_T3;
    }

    @isTest static void doPostT2(){
        //given
        RestRequest request = new RestRequest(); 
        RestResponse restResponse = new RestResponse(); 
        String contentData = requestContentBody_T2();
		
        //when
        Test.startTest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(contentData);
        RestContext.request = request;
        RestContext.response = restResponse;

        RESTCapacity.doPost();
        Blob responseBody = RestContext.response.responseBody;
        Test.stopTest();
    }

    @isTest static void doPostT3(){
        //given
        RestRequest request = new RestRequest(); 
        RestResponse restResponse = new RestResponse(); 
        String contentData = requestContentBody_T3();
		
        //when
        Test.startTest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(contentData);
        RestContext.request = request;
        RestContext.response = restResponse;

        RESTCapacity.doPost();
        Blob responseBody = RestContext.response.responseBody;
        Test.stopTest();
    }

    private static String requestContentBody_T2(){
        return '{\"completeAddress\": \"Martina Cespedes 2008, Villa Adelina,Buenos Aires\",\"customerNationalId\": 33123123,   \"cutoverTime\": \"03:14:15.926Z\",\"isClosedNeighborhood\":false,\"poligons\": [\"12341234\", \r\n    \"12344321\"],\"products\": [{\"sku\":\"4771\",\"quantity\":5}]}';
    }

    private static String requestContentBody_T3(){
        return '{\"completeAddress\": \"Martina Cespedes 2008, Villa Adelina,Buenos Aires\",\"customerNationalId\": 33123123,   \"cutoverTime\": \"03:14:15.926Z\",\"isClosedNeighborhood\":true,\"poligons\": [\"12341234\", \r\n    \"12344321\"],\"products\": [{\"sku\":\"4771\",\"quantity\":5}]}';
    }

    private static String responseContentBody(){
        return '{\"storeId\":\"1\",\"dates\":[{\"times\":{\"T\":\"Tarde 14:00 a 18:00\",\"M\":\"Mañana 09:00 a 13:00\"},\"suggestedDate\":\"2022-06-09\",\"polygonId\":\"12341234\",\"loadDate\":\"2022-06-08\"}]}';
    }
}