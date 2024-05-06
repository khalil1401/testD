/**
 * Company:      CloudGaia
 * Description:  Helper class for RESTConfirm.
 * Test Class:   SFCCConfirmHelper_Test
 */
public with sharing class SFCCConfirmHelper {

    private SFCCConfirmRequestWrapper requestWrapperData;
    private String customerNationalId;
    private String customerAddress;
    private String orderId;
    private String polygon;
    private DateTime selectedDate;
    private String selectedTime;
    private String selectedDateField;
    private String deliveryRoute;
    private List<SFCCConfirmRequestWrapper.Products> products;
    private LVC_Polygon__c polygonData;
    private LVC_Order__c existingOrderData;
    private LVC_PolygonRoute__c designatedRoute;
    private LVC_OrderQuantityDate__c deliveryOrdersForDate;
    private Map<String, LVC_ProductStockDate__c> productsStocksMap = new Map<String, LVC_ProductStockDate__c>();
    private Boolean missingFieldsError = false;
    private Boolean capacityError = false;
    private Boolean stockError = false;

    private String resolveSelectedDateField(DateTime d) {
        String result;
        String dayOfWeek = d.format('E');
        switch on dayOfWeek {
            when 'Mon' {
                result = 'Monday__c';
            }when 'Tue' {
                result = 'Tuesday__c';
            }when 'Wed' {
                result = 'Wednesday__c';
            }when 'Thu' {
                result = 'Thursday__c';
            }when 'Fri' {
                result = 'Friday__c';
            }when 'Sat' {
                result = 'Saturday__c';
            }when 'Sun' {
                result = 'Sunday__c';
            }
        }

        return result;
    }

    private DateTime formatRecheckDate(String selectedDate){
        List<String> dateValues = selectedDate.split('-');
        return DateTime.newInstance(Integer.valueOf(dateValues.get(0)), Integer.valueOf(dateValues.get(1)), Integer.valueOf(dateValues.get(2)));
    }

    public void setUpData(SFCCConfirmRequestWrapper requestWrapper) {
        System.debug('## inSFCCConfirmtHelper.setUpData() method');

        this.requestWrapperData = requestWrapper;
        this.customerNationalId = requestWrapper.customerNationalId;
        this.customerAddress = requestWrapper.completeAddress;
        this.orderId = requestWrapper.orderId;
        this.polygon = requestWrapper.polygon;
        this.selectedDate = formatRecheckDate(requestWrapper.selectedDate);
        this.selectedDateField = resolveSelectedDateField(this.selectedDate);
        this.selectedTime = requestWrapper.selectedTime;
        this.products = requestWrapper.products;

        Set<String> polygonIds = new Set<String>{requestWrapper.polygon};
        List<LVC_Polygon__c> polygonsRecords = [SELECT PolygonExternalId__c, Type__c, DistributionCenter__r.CDExternalId__c,
                                                        TownId__c, ActivityId__c, ZipCode__c
                                                    FROM LVC_Polygon__c
                                                    WHERE PolygonExternalId__c IN :polygonIds];

        if(polygonsRecords.size() == 0) {
            throw new SFCCConfirmCapacityException('No polygon information was found');
        }

        this.polygonData = polygonsRecords[0];
        System.debug('## this.polygonData: ' + this.polygonData);
    }

    public void validateRequiredFields() {
        System.debug('## on SFCCConfirmHelper.validateRequiredFields() method');
        if(String.isBlank(this.customerNationalId) || String.isBlank(this.customerAddress) ||
            String.isBlank(this.orderId) || String.isBlank(this.polygon) || String.isBlank(this.selectedTime) ||
            this.selectedDate == null || this.products.size() < 1) {

            System.debug('## there are missing required fields');
            this.missingFieldsError = true;
            throw new SFCCConfirmCapacityException('Some required fields are missing');
        }
    }

    //Filter #1: rechecking capacity of the polygon to be sure that there's space to deliver the orders
    public void reCheckPolygonsCapacity() {
        Map<String, LVC_OrderQuantityDate__c> ordersQuantityMap = new Map<String, LVC_OrderQuantityDate__c>();

        String query = 'SELECT Polygon__c, Polygon__r.Name, DeliveryRoute__c, DeliveryRoute__r.DeliveryRouteExternalId__c,' +
                        ' DeliveryRoute__r.Delivery__c, DeliveryRoute__r.Delivery__r.Name, DeliveryRoute__r.Delivery__r.' + this.selectedDateField +
        ' FROM LVC_PolygonRoute__c' +
        ' WHERE Polygon__c = \'' +  this.polygonData.Id + '\'' +
        ' AND DeliveryRoute__r.DeliverySchedule__c = \'' + this.selectedTime + '\'' +
        ' AND DeliveryRoute__r.'+this.selectedDateField+' = true' +
        ' AND DeliveryRoute__r.Active__c = true ';

        System.debug('## query: ' + query);

        List<LVC_PolygonRoute__c> polygonRouteData = Database.query(query);

        if(polygonRouteData.size() < 1) {
            this.capacityError = true;
            throw new SFCCConfirmCapacityException('No capacity data could be retrieved for the given criteria');
        }

        System.debug('## polygonRouteData: ' + polygonRouteData);

        Set<String> deliveryIds = new Set<String>();
        for(LVC_PolygonRoute__c polygonRoute : polygonRouteData) {
            deliveryIds.add(polygonRoute.DeliveryRoute__r.Delivery__c);
        }

        System.debug('## deliveryIds: ' + deliveryIds);

        for(LVC_OrderQuantityDate__c oqd : [SELECT Id, Delivery__c, Delivery__r.Name, ConsumedOrdersQuantity__c, Date__c
                                                FROM LVC_OrderQuantityDate__c
                                                WHERE Delivery__c = :deliveryIds
                                                    AND Date__c = :this.selectedDate.date()]) {
            ordersQuantityMap.put(oqd.Delivery__r.Id, oqd);
        }

        System.debug('## ordersQuantityMap: ' + ordersQuantityMap);

        for(LVC_PolygonRoute__c polygonRoute : polygonRouteData) {
            Decimal capacity = (Decimal)polygonRoute.DeliveryRoute__r.Delivery__r.get(this.selectedDateField);
            System.debug('## ' + polygonRoute.DeliveryRoute__r.DeliveryRouteExternalId__c + ': ' + capacity);

            if(capacity > 0) {
                System.debug('## ordersQuantityMap.get(polygonRoute.DeliveryRoute__r.Delivery__c: ' + ordersQuantityMap.get(polygonRoute.DeliveryRoute__r.Delivery__c));

                LVC_OrderQuantityDate__c oqd = ordersQuantityMap.get(polygonRoute.DeliveryRoute__r.Delivery__c);
                if(oqd == null || oqd.ConsumedOrdersQuantity__c < capacity ) {
                    System.debug(oqd != null ? '## consumedOrders: ' + String.valueOf(oqd.ConsumedOrdersQuantity__c) : '## consumedOrders: empty');
                    deliveryOrdersForDate = oqd;
                    this.designatedRoute = polygonRoute;
                    break;
                }
            }
        }

        if(designatedRoute == null) {
            this.capacityError = true;
            throw new SFCCConfirmCapacityException('## Not route could be choosen due to capacity availability');
        }

        System.debug('## designatedRoute: ' + this.designatedRoute);
        System.debug('## capacityError: ' + this.capacityError);
    }

    //Filter #2 : rechecking stock of products to be sure that can be delivered
    public void reCheckProductStock() {
        System.debug('## on reCheckProductStock.method().');

        Set<String> SKUs = new Set<String>();
        for(SFCCConfirmRequestWrapper.Products product : this.products){
            SKUs.add(product.sku);
        }

        System.debug('## CDExternalId__c: ' + this.polygonData.DistributionCenter__r.CDExternalId__c);
        System.debug('## selectedDate: ' + this.selectedDate);
        System.debug('## SKUs: ' + SKUs);

        productsStocksMap = new Map<String, LVC_ProductStockDate__c>();
        for(LVC_ProductStockDate__c psd : [SELECT Id, DistributionCenter__r.CDExternalId__c, StockDate__c, Sku__c, Stock__c, ConsumedStock__c
                                                            FROM LVC_ProductStockDate__c
                                                            WHERE DistributionCenter__r.CDExternalId__c = :this.polygonData.DistributionCenter__r.CDExternalId__c
                                                            AND StockDate__c = :this.selectedDate.date()
                                                            AND Sku__c IN :SKUs]) {
            productsStocksMap.put(psd.Sku__c, psd);
        }

        System.debug('## productsStocksMap: ' + productsStocksMap);

        if(productsStocksMap.keySet().size() < SKUs.size()) {
            this.stockError = true;
            throw new SFCCConfirmCapacityException('Not all products have rows on LVC_ProductStockDate__c');
        }

        Boolean allProductsHasStock = true;
        Integer stockOkCount = 0;

        for(SFCCConfirmRequestWrapper.Products product : this.products) {
            System.debug('## product.sku: ' + product.sku);
            LVC_ProductStockDate__c psd = productsStocksMap.get(product.sku);

            if(psd != null) {
                System.debug('## psd.Stock__c: ' + psd.Stock__c);
                System.debug('## psd.ConsumedStock__c: ' + psd.ConsumedStock__c);

                Integer totalRemaining = Integer.valueOf(psd.Stock__c - psd.ConsumedStock__c);

                System.debug('## totalRemaining: ' + totalRemaining);
                System.debug('## product.quantity: ' + product.quantity);

                if(totalRemaining < product.quantity) {
                    allProductsHasStock = false;
                    break;
                }
            }else {
                System.debug('## product ' + product.sku + ' has no row on stock list for ' + this.selectedDate);
                allProductsHasStock = false;
                break;
            }
        }

        if(!allProductsHasStock){
            this.stockError = true;
            System.debug('stockError: ' + this.stockError);
            throw new SFCCConfirmCapacityException('Not all products have rows on LVC_ProductStockDate__c');
        }
    }

    //Armado de response
    public String responseAndInsertData() {
        System.debug('## on SFCCConfirmHelper.responseAndInsertData() method.');
        System.debug('## capacityError: ' + this.capacityError);
        System.debug('## stockError: ' + this.stockError);
        System.debug('## missingFieldsError: ' + this.missingFieldsError);

        SFCCConfirmResponseWrapper cw_response = new SFCCConfirmResponseWrapper();

        if(this.capacityError){
            System.debug('Fails in Capacity');
            cw_response = createResponse(false, 'ERR001', this.polygonData, null);

        }else if(this.stockError){
            System.debug('Fails in Stock');
            cw_response = createResponse(false, 'ERR002', this.polygonData, null);

        }else if(this.missingFieldsError) {
            System.debug('Missing required fields');
            cw_response = createResponse(false, 'ERR003', this.polygonData, null);
        }else {
            System.debug('Succesful');

            LVC_Order__c newOrder = new LVC_Order__c(
                OrderExternalId__c = this.orderId,
                Address__c = this.customerAddress,
                DNI__c = this.customerNationalId,
                Status__c = '1',
                Date__c = this.selectedDate.date(),
                DeliveryRouteExternalId__c = this.designatedRoute.DeliveryRoute__r.DeliveryRouteExternalId__c
            );

            if(this.deliveryOrdersForDate == null){
                System.debug('sin consumo');
                LVC_OrderQuantityDate__c orderQuantityDate = new LVC_OrderQuantityDate__c(Date__c = this.selectedDate.date(), Delivery__c = this.designatedRoute.DeliveryRoute__r.Delivery__c);
                insert orderQuantityDate;

                System.debug('## orderQuantityDate: ' + orderQuantityDate);

                newOrder.OrderQuantityDate__c = orderQuantityDate.Id;
            }else {
                System.debug('tiene consumos');
                newOrder.OrderQuantityDate__c = this.deliveryOrdersForDate.Id;
            }

            System.debug('## newOrder: ' + newOrder);

            insert newOrder;

            List<LVC_OrderProduct__c> newOrderProductList = new List<LVC_OrderProduct__c>();

            for(SFCCConfirmRequestWrapper.Products product : this.products){
                LVC_OrderProduct__c newOrderProduct = new LVC_OrderProduct__c(
                    Quantity__c = product.quantity,
                    Order__c = newOrder.Id,
                    ProductStockDate__c = this.productsStocksMap.get(product.sku).Id,
                    Sku__c = product.sku
                );
                newOrderProductList.add(newOrderProduct);
            }

            insert newOrderProductList;

            cw_response = createResponse(true, null, this.polygonData, newOrder.Id);
        }

        return JSON.serialize(cw_response);
    }

    private SFCCConfirmResponseWrapper createResponse(Boolean isSuccess, String errorCode, LVC_Polygon__c polygonData, String orderSFId){
        SFCCConfirmResponseWrapper confirmWrapper = new SFCCConfirmResponseWrapper();
        confirmWrapper.activityId = polygonData.Type__c == 'T2' ? '70' : polygonData.Type__c == 'T3' ? '98' : null;
        confirmWrapper.errorCode = errorCode;
        confirmWrapper.success = isSuccess;
        confirmWrapper.townId = polygonData.TownId__c;
        confirmWrapper.sfId = orderSFId;
        confirmWrapper.zipCode = polygonData.ZipCode__c;
        confirmWrapper.deliveryRoute = this.designatedRoute != null ? this.designatedRoute.DeliveryRoute__r.DeliveryRouteExternalId__c : null;

        return confirmWrapper;
    }

    public class SFCCConfirmCapacityException extends Exception {

    }
}