/**
 * Company:      CloudGaia
 * Description:  Helper class for making queries.
 * Test Class:   SFCCCapacityHelper_Test
 */
public with sharing class SFCCQueriesHelper {
    public static List<Date> getHolidays(String CDId){
        List<Date> holidays = new List<Date>();
        List<LVC_Holidays__c> hlist = [SELECT Date__c
                                   FROM LVC_Holidays__c
                                   WHERE DistributionCenter__r.CDExternalId__c =: CDId
                                   AND Date__c >=: Date.today()
                                   AND Date__c <=: Date.today().addDays(20)];
        for(LVC_Holidays__c holiday:hlist){
            holidays.add(holiday.Date__c);
        }
        return holidays;     
    }
    
    public static List<LVC_Order__c> getOrdersData(List<Date> possibleDates, String customerNationalId, String customerAddress, String status){
        return [SELECT DNI__c, Address__c, Date__c 
                FROM LVC_Order__c 
                WHERE Date__c IN: possibleDates 
                AND DNI__c =: customerNationalId 
                AND Address__c =: customerAddress
                AND Status__c =: status];
    }
    
    public static List<LVC_OrderQuantityDate__c> getQuantitiesDate(Set<String> deliveryIds, Set<Date> possibleDates){
        return [SELECT ConsumedOrdersQuantity__c, Date__c, Id, Delivery__c 
                FROM LVC_OrderQuantityDate__c 
                WHERE Delivery__c =: deliveryIds
                AND Date__c =: possibleDates];
    }

    public static List<LVC_ProductStockDate__c> getStockProductsDates(List<Date> dateInput, String cdId, Set<String> stSkus){
        return [SELECT Id, DistributionCenter__r.CDExternalId__c, StockDate__c, Sku__c, Stock__c, ConsumedStock__c 
                FROM LVC_ProductStockDate__c 
                WHERE DistributionCenter__r.CDExternalId__c =: cdId 
                AND StockDate__c IN: dateInput 
                AND Sku__c IN: stSkus];
    }

    public static List<LVC_PolygonRoute__c> getPossibleRoutsWithPolygons(Set<String> polygonIds){
        return [SELECT DeliveryRoute__c, Polygon__c, Polygon__r.PolygonExternalId__c 
                FROM LVC_PolygonRoute__c 
                WHERE Polygon__r.PolygonExternalId__c =: polygonIds];
    }

    public static List<LVC_DeliveryRoute__c> getDeliveryRoutesById(Set<String> deliveryRouteIds){
        return [SELECT DeliverySchedule__c, Active__c, Monday__c, Tuesday__c, Wednesday__c, 
                       Thursday__c, Friday__c, Saturday__c, Sunday__c, DeliveryRouteExternalId__c,
                       RouteId__c, Delivery__c 
                FROM LVC_DeliveryRoute__c 
                WHERE Id =: deliveryRouteIds 
                AND Active__c = true];
    }

    public static List<LVC_Delivery__c> getDeliveryCapacities(Set<String> deliveryIds){
        return [SELECT Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c, Active__c 
                FROM LVC_Delivery__c 
                WHERE Id =: deliveryIds
                AND Active__c = true];
    }

    public static List<LVC_Order__c> getExistingOrders(Set<Date> possibleDates, String status){
        return [SELECT DNI__c, Address__c, Date__c, Status__c, OrderExternalId__c, OrderQuantityDate__c
                FROM LVC_Order__c 
                WHERE Date__c =: possibleDates
                AND Status__c =: status];
    }
}