@isTest
public class LVC_OrderTriggerTest {
    @TestSetup
    static void generateData(){
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
            Delivery__c = delivery.Id,
            DeliverySchedule__c = 'M',
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
            Date__c = Date.newInstance(2022, 04, 27), 
            Delivery__c = delivery.Id
        );
        insert orderQuantityDate_T2;
        
        LVC_Order__c order_T2 = new LVC_Order__c(
            OrderExternalId__c = 'DAN-0001', 
            OrderQuantityDate__c = orderQuantityDate_T2.Id, 
            DNI__c = '123', 
            Address__c = 'test', 
            Date__c = Date.newInstance(2022, 05, 04)
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
    @isTest
    static void updateStock(){
        //given
        LVC_Order__c orderToCancel = [SELECT Id, Name, Status__c FROM LVC_Order__c LIMIT 1];
        //when
        Test.startTest();
        orderToCancel.Status__c = '2';
        update orderToCancel;
        Test.stopTest();
        //then
        System.assertEquals('2', orderToCancel.Status__c);
    }
}