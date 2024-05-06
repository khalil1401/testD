/**
 * Company:      CloudGaia
 * Description:  Helper class for RESTCapacity.
 * Test Class:   SFCCCapacityHelper_Test
 */
public with sharing class SFCCCapacityHelper {
    private static SFCCCapacityRequestWrapper requestWrapperData;
    private static String customerNationalId;
    private static String customerAddress;
    private static Time cutoverTime;
    private static Boolean closedNeighborhood;
    private static List<String> poligons;
    private static List<SFCCCapacityRequestWrapper.Products> products;
    private static String CDId;
    private static Set<String> noWeekdaysInCD;
    private static Map<Date, Date> possibleDaysByLoadDate = new Map<Date, Date>();
    private static Map<String, LVC_Polygon__c> polygonsDataByExtId = new Map<String, LVC_Polygon__c>();
    private static Map<String, List<Date>> availableDatesByPolygonExtId = new Map<String, List<Date>>();

    private class DeliveryCombination{
        private String polygonExternalId;
        private String deliveryRouteSFId;
        private String deliveryRouteExternalId;
        private String deliverySFId;
        private Map<String, String> deliverySchedule;
        private Map<String, Integer> deliveryCapacity;
    }

    private static Map<String, List<SFCCCapacityHelper.DeliveryCombination>> deliveryCombinationsMap = new Map<String, List<SFCCCapacityHelper.DeliveryCombination>>();
    private static Map<Date, List<SFCCCapacityHelper.DeliveryCombination>> deliveryCombinationsToRemoveMap = new Map<Date, List<SFCCCapacityHelper.DeliveryCombination>>();
    private static Boolean hasProductStock = false;

    private static Integer getOrgTimezoneOffset() {
        Organization org = [SELECT Id, TimeZoneSidKey FROM Organization];

        Timezone tz = Timezone.getTimeZone(org.TimeZoneSidKey);

        Integer offset = tz.getOffset(DateTime.now());
        return offset / 3600000;
    }

    public static void setUpData(SFCCCapacityRequestWrapper requestWrapper) {
        System.debug('## on SFCCCapacityHelper.setUpData() method.');

        SFCCCapacityHelper.requestWrapperData = requestWrapper;
        SFCCCapacityHelper.customerNationalId = requestWrapper.customerNationalId;
        SFCCCapacityHelper.customerAddress = requestWrapper.completeAddress;
        SFCCCapacityHelper.cutoverTime = requestWrapper.cutoverTime;
        SFCCCapacityHelper.closedNeighborhood = requestWrapper.isClosedNeighborhood;
        SFCCCapacityHelper.poligons = requestWrapper.poligons;
        SFCCCapacityHelper.products = requestWrapper.products;
    }

    //buscar por poligonos y si es T2 o T3
    public static void getPolygonsData(){
        List<LVC_Polygon__c> polygonsData = new List<LVC_Polygon__c>();
        List<String> polygons = SFCCCapacityHelper.poligons;
        String query = 'SELECT PolygonExternalId__c, Type__c, DistributionCenter__r.CDExternalId__c,'+ 
                              'TownId__c, ActivityId__c, ZipCode__c FROM LVC_Polygon__c ' + 
                       'WHERE PolygonExternalId__c =: polygons';
        if(SFCCCapacityHelper.closedNeighborhood == true){
            query +=  + ' AND Type__c = \'T3\'';
        }
        else{
            query += ' ORDER BY Type__c';
        }
        polygonsData = Database.query(query);

        if(polygonsData.size() > 0){
            SFCCCapacityHelper.CDId = polygonsData.get(0).DistributionCenter__r.CDExternalId__c;
            for(LVC_Polygon__c polygon : polygonsData){
                SFCCCapacityHelper.polygonsDataByExtId.put(polygon.PolygonExternalId__c, polygon);
            }
            SFCCCapacityHelper.deliveryCombinationsMap = getDeliveryCombinations(SFCCCapacityHelper.polygonsDataByExtId.keySet());
            SFCCCapacityHelper.noWeekdaysInCD = SFCCCapacityHelper.getDaysWithoutLoadInCD(SFCCCapacityHelper.CDId);

            System.debug('## SFCCCapacityHelper.CDId: ' + SFCCCapacityHelper.CDId);
            System.debug('SFCCCapacityHelper.cutoverTime : ' + SFCCCapacityHelper.cutoverTime);
        }
    }

    //Calcular primer fecha posible de carga y 7 dias hábiles a partir de este en possibleDays
    //Hora de corte prueba: 12:00:00.625z
    //{loadDate: AvDate1}, {AvDate1: AvDate2}
    public static void calculatePossibleDays() {
        List<Date> holidays = SFCCQueriesHelper.getHolidays(SFCCCapacityHelper.CDId);
        Integer orgTimezoneOffset = getOrgTimezoneOffset();

        // DateTime rightNow = DateTime.newInstance(2022, 11, 05, 23, 15, 20); //.addHours(orgTimezoneOffset);
        DateTime rightNow = DateTime.now();
        System.debug('## rightNow: ' + rightNow);

        DateTime cutoverTimeThreshold = DateTime.newInstance(rightNow.year(), rightNow.month(), rightNow.day(), SFCCCapacityHelper.cutoverTime.hour(), SFCCCapacityHelper.cutoverTime.minute(), SFCCCapacityHelper.cutoverTime.second());
        cutoverTimeThreshold = cutoverTimeThreshold.addHours(orgTimezoneOffset);
        System.debug('## cutoverTimeThreshold: ' + cutoverTimeThreshold);

        Boolean overpassed = rightNow > cutoverTimeThreshold;
		System.debug('## overpassed: ' + overpassed);

        Date firstLoadDate = calculatefirstLoadDate(rightNow, holidays, overpassed);

        calculateBusinessDaysWindow(firstLoadDate, SFCCCapacityHelper.possibleDaysByLoadDate, holidays);
		System.debug('## SFCCCapacityHelper.possibleDaysByLoadDate: ' + SFCCCapacityHelper.possibleDaysByLoadDate);

        System.debug(SFCCCapacityHelper.possibleDaysByLoadDate);
    }

    //Si todaysDate es dia habil y timeNow es menor a cutoverTime primer fecha de carga sera hoy
    //Sino primer fecha de carga sera el proximo día habil
    public static Date calculatefirstLoadDate(DateTime todaysDate, List<Date> holidays, Boolean overpassed) {
        Date firstLoadDate;
        String dayOfWeek = todaysDate.format('EEEE');

        System.debug('## dayOfWeek: ' + dayOfWeek);

        if(!holidays.contains(todaysDate.date()) && !SFCCCapacityHelper.noWeekdaysInCD.contains(dayOfWeek) && !overpassed){
            firstLoadDate = todaysDate.date();
            System.debug('## Hoy es primer fecha de carga: ' + firstLoadDate);
        }else{
            Integer count = 1;
            do {
                Date currentDate = todaysDate.addDays(count).date();
                System.debug('## prox. fecha de carga: ' + currentDate);
                String currentWeekDay = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day()).format('EEEE');
                System.debug('## dia prox. fecha de carga: ' + currentWeekDay);

                if(!holidays.contains(currentDate) && !SFCCCapacityHelper.noWeekdaysInCD.contains(currentWeekDay)){
                    firstLoadDate = currentDate;
                }else {
                    System.debug('## fecha ' + currentDate + ' es feriado o no es día de carga para el CD');
                    count += 1;
                }
            } while (firstLoadDate == null);
        }

        System.debug('## firstLoadDate: ' + firstLoadDate);
        return firstLoadDate;
    }

    private static Date resolveLoadDateForDeliveryDate(List<Date> holidays, Date deliveryDate) {
        System.debug(' @@ BEGIN - on resolveLoadDateForDeliveryDate() method ------------ ');
        Date result;
        Integer count = -1;

        do {
            System.debug('@@ deliveryDate: ' + deliveryDate);
            Date loadDate = deliveryDate.addDays(count);
            System.debug('@@ loadDate: ' + loadDate);
            String currentloadDateDay = DateTime.newInstance(loadDate.year(), loadDate.month(), loadDate.day()).format('EEEE');
			System.debug('@@ currentloadDateDay: ' + currentloadDateDay);

            if(!holidays.contains(loadDate) && !SFCCCapacityHelper.noWeekdaysInCD.contains(currentloadDateDay)) {
                System.debug('@@ SFCCCapacityHelper.noWeekdaysInCD: ' + SFCCCapacityHelper.noWeekdaysInCD + ' no contiene a ' + currentloadDateDay);
                result = loadDate;
            }

			count = count - 1;
        }while(result == null);

        System.debug(' @@ END - on resolveLoadDateForDeliveryDate() method ------------ ');
        return result;
    }

    //CALCULATE THE NEXT 7 BUSINESS DAY FROM LOAD DATE
    public static void calculateBusinessDaysWindow(Date firstLoadDate, Map<Date, Date> possibleDaysByLoadDate, List<Date> holidays){
        System.debug('------------ in SFCCCapacityHelper.calculateBusinessDaysWindow() ------------');
        System.debug('## holidays: ' + holidays);
        Date nextLoadDate = firstLoadDate;

        List<Date> deliveryDates = new List<Date>();
        Integer count = 1;

        do {
            Date deliveryDate = firstLoadDate.addDays(count);
            String deliveryDateDay = DateTime.newInstance(deliveryDate.year(), deliveryDate.month(), deliveryDate.day()).format('EEEE');

        	System.debug('-- deliveryDate: ' + deliveryDate);
        	System.debug('-- deliveryDateDay: ' + deliveryDateDay);

            if(!holidays.contains(deliveryDate) && deliveryDateDay != 'Sunday') {
                deliveryDates.add(deliveryDate);
            }

            count += 1;

        } while (deliveryDates.size() != 7);

        System.debug('## deliveryDates: ' + deliveryDates);

        for(Date d : deliveryDates) {
			Date loadDate = resolveLoadDateForDeliveryDate(holidays, d);
            possibleDaysByLoadDate.put(d, loadDate);
        }
    }

    private static Set<String> getDaysWithoutLoadInCD(String CDId){
        Set<String> noPossibleLoadDates = new Set<String>();

        List<LVC_DistributionCenter__c> distributionCenterList = new List<LVC_DistributionCenter__c>();
        String cd_query = 'SELECT Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c ' + 
                       'FROM LVC_DistributionCenter__c ' + 
                       'WHERE CDExternalId__c =: CDId';
        distributionCenterList = Database.query(cd_query);

        if(distributionCenterList.size() > 0){
            if(distributionCenterList[0].Monday__c == false){
                noPossibleLoadDates.add('Monday');
            }
            if(distributionCenterList[0].Tuesday__c == false){
                noPossibleLoadDates.add('Tuesday');
            }
            if(distributionCenterList[0].Wednesday__c == false){
                noPossibleLoadDates.add('Wednesday');
            }
            if(distributionCenterList[0].Thursday__c == false){
                noPossibleLoadDates.add('Thursday');
            }
            if(distributionCenterList[0].Friday__c == false){
                noPossibleLoadDates.add('Friday');
            }
            if(distributionCenterList[0].Saturday__c == false){
                noPossibleLoadDates.add('Saturday');
            }
            if(distributionCenterList[0].Sunday__c == false){
                noPossibleLoadDates.add('Sunday');
            }
            System.debug('## possible dates: ' + noPossibleLoadDates);
        }
        return noPossibleLoadDates;
    }

    //Filter #1: no more than 1 order per day (order w/same direction and dni of the request)
    public static void noDuplicateOrders(){
        System.debug('## SFCCCapacityHelper.noDuplicateOrders() method');

        List<Date> datesToRemove = new List<Date>();
        Set<Date> possibleDatesSet = SFCCCapacityHelper.possibleDaysByLoadDate.keySet();
        List<Date> possibleDates = new List<Date>(possibleDatesSet);

        System.debug('## possibleDates: ' + possibleDates);

        List<LVC_Order__c> orders = SFCCQueriesHelper.getOrdersData(possibleDates, SFCCCapacityHelper.customerNationalId, SFCCCapacityHelper.customerAddress, '1');

        for(LVC_Order__c order : orders){
            datesToRemove.add(order.Date__c);
        }

        /* DCB-532 - BEGIN */
        for(Date noAvailableDate : datesToRemove){
            SFCCCapacityHelper.possibleDaysByLoadDate.remove(noAvailableDate);
        }
        /* DCB-532 -  END  */

        System.debug('## b) SFCCCapacityHelper.possibleDaysByLoadDate: ' + SFCCCapacityHelper.possibleDaysByLoadDate);
    }

    //Filter #2: Polygons Frequency(polygons have a frequency based in weekdays: Monday to Saturday)
    //Se necesita vincular las fechas disponibles a los poligonos en availableDatesByPolygonExtId(Map) ya que al armar el response se debe indicar
    //el external id del poligono que correspondería a la entrega de ese dia
    public static void polygonsFrequency(){
        Set<Date> possibleDatesSet = SFCCCapacityHelper.possibleDaysByLoadDate.keySet();
        List<Date> possibleDates = new List<Date>(possibleDatesSet);

        List<LVC_Polygon__c> polygonsToSort = SFCCCapacityHelper.polygonsDataByExtId.values();

        for(LVC_Polygon__c pol : polygonsToSort){
            if(SFCCCapacityHelper.deliveryCombinationsMap.keySet().contains(pol.PolygonExternalId__c)){
                Set<String> possibleWeekdays = new Set<String>();
                for(SFCCCapacityHelper.DeliveryCombination dc : SFCCCapacityHelper.deliveryCombinationsMap.get(pol.PolygonExternalId__c)){
                    possibleWeekdays.addAll(dc.deliveryCapacity.keySet());
                }
                SFCCCapacityHelper.availableDatesByPolygonExtId.put(pol.PolygonExternalId__c, getPossibleDays(possibleDates, possibleWeekdays));
            }
        }
        System.debug(SFCCCapacityHelper.availableDatesByPolygonExtId);
    }

    private static List<Date> getPossibleDays(List<Date> possibleDateList, Set<String> daysInPolygon){
        List<Date> datesAvailableInPolygon = new List<Date>();
        for(Date possibleDateItem : possibleDateList){
            String dayOfWeek = DateTime.newInstance(possibleDateItem.year(), possibleDateItem.month(), possibleDateItem.day()).format('EEEE');
            if(daysInPolygon.contains(dayOfWeek)){
                datesAvailableInPolygon.add(possibleDateItem);
            }
        }
        return datesAvailableInPolygon;
    }

    //Filter #3: debo recibir una lista de fechas filtradas por pedidos realizados y frecuencia, y consultar si los productos
    //que viene dentro del request existen. Si existen, saber si hay stock disponible
    public static void productStock(){
        Map<String,Integer> requestProducts = new Map<String,Integer>();
        for(SFCCCapacityRequestWrapper.Products prd : products){
            requestProducts.put(prd.sku, prd.quantity);
        }

        Set<String> SKUs = new Set<String>();
        for(SFCCCapacityRequestWrapper.Products pd: products){
            SKUs.add(pd.sku);
        }

        Set<Date> availableDatesSet = new Set<Date>();
        for(String polygonExtId : SFCCCapacityHelper.availableDatesByPolygonExtId.keySet()){
            for(Date availableDate : SFCCCapacityHelper.availableDatesByPolygonExtId.get(polygonExtId)){
                availableDatesSet.add(availableDate);
            }
        }

        List<Date> availableDatesList = new List<Date>();
        availableDatesList.addAll(availableDatesSet);
        Set<Date> datesToRetain = new Set<Date>();

        List<LVC_ProductStockDate__c> pdStockDates = SFCCQueriesHelper.getStockProductsDates(availableDatesList, SFCCCapacityHelper.cdId, SKUs);
        Map<Date, Integer> productStockDateCountByDate = countProductStockByDate(pdStockDates, requestProducts);

        if(productStockDateCountByDate.size() > 0){
            for(Date dateWithStockAvailable : productStockDateCountByDate.keySet()){
                if(requestProducts.size() == productStockDateCountByDate.get(dateWithStockAvailable)){
                    datesToRetain.add(dateWithStockAvailable);
                }
            }
        }

        if(datesToRetain.size() > 0){
            Map<String, List<Date>> availableDatesWithStockByPolygonExtId = new Map<String, List<Date>>();
            for(String polygonExtId : SFCCCapacityHelper.availableDatesByPolygonExtId.keySet()){
                List<Date> resultantAvailableDates = new List<Date>();
                for(Date availableDate : SFCCCapacityHelper.availableDatesByPolygonExtId.get(polygonExtId)){
                    if(datesToRetain.contains(availableDate)){
                        resultantAvailableDates.add(availableDate);
                    }
                }
                availableDatesWithStockByPolygonExtId.put(polygonExtId, resultantAvailableDates);
            }
            SFCCCapacityHelper.availableDatesByPolygonExtId = availableDatesWithStockByPolygonExtId;

            SFCCCapacityHelper.hasProductStock = availableDatesWithStockByPolygonExtId.size() > 0 ? true : false;
        }

        System.debug(SFCCCapacityHelper.hasProductStock);
    }

    private static Map<Date, Integer> countProductStockByDate(List<LVC_ProductStockDate__c> productStockList, Map<String,Integer> requestProductsMap){
        Map<Date, Integer> stockAvailableByDate = new Map<Date, Integer>();
        Set<Date> datesInProductSet = new Set<Date>();
        for(LVC_ProductStockDate__c psd : productStockList){
            datesInProductSet.add(psd.StockDate__c);
        }

        for(Date dateStock : datesInProductSet){
            stockAvailableByDate.put(dateStock, sortProductStockDates(dateStock, productStockList, requestProductsMap).size());
        }
        return stockAvailableByDate;
    }

    private static List<LVC_ProductStockDate__c> sortProductStockDates(Date stockDate, List<LVC_ProductStockDate__c> productStockList, Map<String,Integer> requestProductsMap){
        List<LVC_ProductStockDate__c> sortedProductStocks = new List<LVC_ProductStockDate__c>();
        for(LVC_ProductStockDate__c productStock : productStockList){
            if(productStock.StockDate__c == stockDate){
                Integer totalStockRemaining = Integer.valueOf(productStock.Stock__c) - Integer.valueOf(productStock.ConsumedStock__c);
                if(totalStockRemaining >= requestProductsMap.get(productStock.Sku__c)){
                    sortedProductStocks.add(productStock);
                }
            }
        }
        return sortedProductStocks;
    }

    //Filter #4: Polygon capacity per day
    public static void polygonsCapacity() {
        Set<String> polygonExtIds = SFCCCapacityHelper.availableDatesByPolygonExtId.keySet();
        Set<String> deliveryIds = new Set<String>();
        for(String polygonExtId : polygonExtIds){
            for(SFCCCapacityHelper.DeliveryCombination drw : SFCCCapacityHelper.deliveryCombinationsMap.get(polygonExtId)){
                deliveryIds.add(drw.deliverySFId);
            }
        }
        System.debug(deliveryIds);

        Set<Date> possibleDates = new Set<Date>();

        for(Date dateAvailable : SFCCCapacityHelper.possibleDaysByLoadDate.keySet()){
            possibleDates.add(dateAvailable);
        }

        System.debug(possibleDates);

        List<LVC_OrderQuantityDate__c> orderQuantityDates = SFCCQueriesHelper.getQuantitiesDate(deliveryIds, possibleDates);
        System.debug(orderQuantityDates);

        if(orderQuantityDates.size() > 0){
            Set<Date> orderDates = new Set<Date>();
            for(LVC_OrderQuantityDate__c oqd : orderQuantityDates){
                orderDates.add(oqd.Date__c);
            }
            System.debug(orderDates);
            for(String polygonExtId : polygonExtIds){

                List<SFCCCapacityHelper.DeliveryCombination> combinationsToRemove = new List<SFCCCapacityHelper.DeliveryCombination>();
                for(LVC_OrderQuantityDate__c orderQuantity : orderQuantityDates) {
                    String weekday = Datetime.newInstance(orderQuantity.Date__c, Time.newInstance(0, 0, 0, 0)).format('EEEE');

                    for(SFCCCapacityHelper.DeliveryCombination drw : SFCCCapacityHelper.deliveryCombinationsMap.get(polygonExtId)){
                        if(drw.deliveryCapacity.keySet().contains(weekday) && drw.deliverySFId == orderQuantity.Delivery__c){
                            Integer totalCapacityAvailable = Integer.valueOf(drw.deliveryCapacity.get(weekday)) - Integer.valueOf(orderQuantity.ConsumedOrdersQuantity__c);
                            if(totalCapacityAvailable == 0){
                                combinationsToRemove.add(drw);
                            }
                        }
                    }

                    if(combinationsToRemove.size() > 0){
                        SFCCCapacityHelper.deliveryCombinationsToRemoveMap.put(orderQuantity.Date__c, combinationsToRemove);
                    }
                }
            }
            System.debug('toRemove: ' + SFCCCapacityHelper.deliveryCombinationsToRemoveMap);
        }
    }

    //Armado de response
    public static String createResponse() {
        SFCCCapacityResponseWrapper crw_response = new SFCCCapacityResponseWrapper();
        List<SFCCCapacityResponseWrapper.Dates> datesSuggested = new List<SFCCCapacityResponseWrapper.Dates>();

        if(SFCCCapacityHelper.hasProductStock == true){
            //Iterate over map<Date, date> to get the "load date" & it's "suggested date"
            for(Date suggestedDate : SFCCCapacityHelper.possibleDaysByLoadDate.keySet()){
                Date loadDate = SFCCCapacityHelper.possibleDaysByLoadDate.get(suggestedDate);
                //Iterate over map<String, List<Date>> to get the "polygonExtId" and its "available dates"
                for(String polygonExtId : SFCCCapacityHelper.availableDatesByPolygonExtId.keySet()){
                    //check if the suggested date from the map "possibleDaysByLoadDate" exist on the list related to the polygonExtId
                    if(SFCCCapacityHelper.availableDatesByPolygonExtId.get(polygonExtId).contains(suggestedDate)){
                        //If exists, then iterate over the list of availableDates for that specific polygonExtId
                        for(Date availableDate : SFCCCapacityHelper.availableDatesByPolygonExtId.get(polygonExtId)){
                            //if exist and are the same, then create the SFCCCapacityResponseWrapper.Dates entry, and added to the list "datesSuggested"
                            if(availableDate == suggestedDate){
                                for(SFCCCapacityHelper.DeliveryCombination drw : SFCCCapacityHelper.deliveryCombinationsMap.get(polygonExtId)){
                                    String suggestedWeekday = DateTime.newInstance(suggestedDate, Time.newInstance(0,0,0,0)).format('EEEE');
                                    if(drw.deliveryCapacity.keySet().contains(suggestedWeekday)){
                                        SFCCCapacityResponseWrapper.Dates dateSuggestion = createDateItemResponse(polygonExtId, loadDate, suggestedDate, drw);
                                        datesSuggested.add(dateSuggestion);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        //storeId: referred to the warehouse (Centro de distribucion)
        crw_response.storeId = SFCCCapacityHelper.CDId;
        //Filter possible deliveryCombinations by suggestedDate, store them on a map
        Map<Date, List<SFCCCapacityResponseWrapper.Dates>> dateItemsMap = new Map<Date, List<SFCCCapacityResponseWrapper.Dates>>();
        for(SFCCCapacityResponseWrapper.Dates dateItem : datesSuggested){
            System.debug(dateItem);
            dateItemsMap.put(dateItem.suggestedDate, getSimilarDateItemResponse(dateItem, datesSuggested));
        }

        if(SFCCCapacityHelper.deliveryCombinationsToRemoveMap.size() > 0){
            //remove deliveryCombinations that are present in remove map
            Map<Date, List<SFCCCapacityResponseWrapper.Dates>> datesToRetainMap = new Map<Date, List<SFCCCapacityResponseWrapper.Dates>>();
            for(Date dateAvailable : dateItemsMap.keySet()){
                System.debug('date: ' + dateAvailable);
                if(SFCCCapacityHelper.deliveryCombinationsToRemoveMap.get(dateAvailable) != null){
                    List<SFCCCapacityResponseWrapper.Dates> datesToRetain = new List<SFCCCapacityResponseWrapper.Dates>();
                    for(SFCCCapacityResponseWrapper.Dates dateItem : dateItemsMap.get(dateAvailable)){
                        System.debug('dateItem: ' + dateItem);
                        if(!isCombinationToRemove(dateAvailable, dateItem)){
                            datesToRetain.add(dateItem);
                        }
                    }
                    datesToRetainMap.put(dateAvailable, datesToRetain);
                }
                else{
                    datesToRetainMap.put(dateAvailable, dateItemsMap.get(dateAvailable));
                }
            }

            System.debug(datesToRetainMap);
            dateItemsMap = datesToRetainMap;
        }

        System.debug(dateItemsMap);

        //Then unify values in case that theres more than 1 frecuency for the same date
        List<SFCCCapacityResponseWrapper.Dates> dateItems = new List<SFCCCapacityResponseWrapper.Dates>();
        for(Date d : dateItemsMap.keySet()){
            if(dateItemsMap.get(d).size() > 1){
                dateItems.add(unifyDateItemResponseTimes(dateItemsMap.get(d)));
            }
            else if(dateItemsMap.get(d).size() == 1){
                dateItems.add(dateItemsMap.get(d)[0]);
            }
        }

        //dates: referred to the possible dates where the delivery it's going to be send , and in which frequecies
        crw_response.dates = dateItems;

        return JSON.serialize(crw_response);
    }

    private static SFCCCapacityResponseWrapper.Dates createDateItemResponse(String polygonExtId, Date loadDate, Date suggestedDate, SFCCCapacityHelper.DeliveryCombination drw){
        SFCCCapacityResponseWrapper.Dates dateSuggestion = new SFCCCapacityResponseWrapper.Dates();
        dateSuggestion.suggestedDate = suggestedDate;
        dateSuggestion.loadDate = loadDate;
        dateSuggestion.polygonId = polygonExtId;
        dateSuggestion.times = drw.deliverySchedule;
        return dateSuggestion;
    }

    private static List<SFCCCapacityResponseWrapper.Dates> getSimilarDateItemResponse(SFCCCapacityResponseWrapper.Dates dateItem, List<SFCCCapacityResponseWrapper.Dates> datesSuggestedList){
        List<SFCCCapacityResponseWrapper.Dates> similarDateItem = new List<SFCCCapacityResponseWrapper.Dates>();
        for(SFCCCapacityResponseWrapper.Dates dateSuggestedItem : datesSuggestedList){
            if(dateItem.loadDate == dateSuggestedItem.loadDate &&
                dateItem.polygonId == dateSuggestedItem.polygonId &&
                dateItem.suggestedDate == dateSuggestedItem.suggestedDate){
                    similarDateItem.add(dateSuggestedItem);
            }
        }
        return similarDateItem;
    }

    private static Boolean isCombinationToRemove(Date d, SFCCCapacityResponseWrapper.Dates dateItem){
        Boolean isFound = false;
        for(Date dateRemove : SFCCCapacityHelper.deliveryCombinationsToRemoveMap.keySet()){
            for(SFCCCapacityHelper.DeliveryCombination fromRemove : SFCCCapacityHelper.deliveryCombinationsToRemoveMap.get(dateRemove)){
                if(fromRemove.polygonExternalId == dateItem.polygonId && fromRemove.deliverySchedule.keySet() == dateItem.times.keySet()){
                    isFound = true;
                    break;
                }
            }
        }
        return isFound;
    }

    private static SFCCCapacityResponseWrapper.Dates unifyDateItemResponseTimes(List<SFCCCapacityResponseWrapper.Dates> dateItems){
        SFCCCapacityResponseWrapper.Dates unifiedDateItem = new SFCCCapacityResponseWrapper.Dates();
        unifiedDateItem.loadDate = dateItems[0].loadDate;
        unifiedDateItem.polygonId = dateItems[0].polygonId;
        unifiedDateItem.suggestedDate = dateItems[0].suggestedDate;
        Map<String, String> unifiedTimes = new Map<String, String>();
        for(SFCCCapacityResponseWrapper.Dates d2: dateItems){
            for(String status : d2.times.keySet()){
                unifiedTimes.put(status, d2.times.get(status));
            }
        }
        if(unifiedTimes.size() == 1){
            unifiedDateItem.times = unifiedTimes;
        }
        else{
            unifiedDateItem.times = orderUnifiedDateItemTimes(unifiedTimes);
        }
        return unifiedDateItem;
    }

    private static Map<String, String> orderUnifiedDateItemTimes(Map<String, String> dateItemTimes){
        List<String> frequencyKeys = new List<String>();
        frequencyKeys.addAll(dateItemTimes.keySet());
        frequencyKeys.sort();

        Map<String, String> orderedTimes = new Map<String, String>();
        orderedTimes.put(frequencyKeys[1], dateItemTimes.get(frequencyKeys[1]));
        orderedTimes.put(frequencyKeys[0], dateItemTimes.get(frequencyKeys[0]));

        return orderedTimes;
    }

    //Combinaciones de delivery routes + capacidad + frecuencia por poligono
    private static Map<String, List<SFCCCapacityHelper.DeliveryCombination>> getDeliveryCombinations(Set<String> polygonExtIds){
        //get all the polygonRoutes by polygonExternal Id
        List<LVC_PolygonRoute__c> polygonRoutesList = SFCCQueriesHelper.getPossibleRoutsWithPolygons(polygonExtIds);

        //get all deliveryRoutes from polygonRoute (junctionObject), extract deliveryRoute ids (record)
        Set<String> deliveryRoutesIds = new Set<String>();
        for(LVC_PolygonRoute__c pr : polygonRoutesList){
            deliveryRoutesIds.add(pr.DeliveryRoute__c);
        }

        //get all deliveryRoutes by Id
        List<LVC_DeliveryRoute__c> deliveryRoutesList = SFCCQueriesHelper.getDeliveryRoutesById(deliveryRoutesIds);

        //group up deliveryRoutes by polygonExtId in a map
        Map<String, Set<String>> deliveryRoutesWithPolygonId = new Map<String, Set<String>>(); 
        for(String polygonExtId : polygonExtIds){
            deliveryRoutesWithPolygonId.put(polygonExtId, getDeliveryRoutesIdsByPolygonId(polygonExtId, polygonRoutesList));
        }

        //then use previous map to sort deliveryRoutes by polygonExtId 
        Map<String, List<LVC_DeliveryRoute__c>> deliveryRoutesByPolygonId = new Map<String, List<LVC_DeliveryRoute__c>>();
        for(String polygonExtId : deliveryRoutesWithPolygonId.keySet()){
            deliveryRoutesByPolygonId.put(polygonExtId, sortDeliveryRoutes(deliveryRoutesWithPolygonId.get(polygonExtId), deliveryRoutesList));
        }

        //get all the deliveryCapacities Ids from deliveryRoutes, store them on a set
        Set<String> deliveryCapacitiesIds = new Set<String>();
        for(LVC_DeliveryRoute__c dr : deliveryRoutesList){
            deliveryCapacitiesIds.add(dr.Delivery__c);
        }

        //Store values from deliveryCpacities on a map
        Map<Id, LVC_Delivery__c> deliveryCapacitiesMap = new Map<Id, LVC_Delivery__c>(SFCCQueriesHelper.getDeliveryCapacities(deliveryCapacitiesIds));

        //Store wrapper values
        List<SFCCCapacityHelper.DeliveryCombination> deliveryCombinationList = new List<SFCCCapacityHelper.DeliveryCombination>();
        for(String polygonExtId : deliveryRoutesByPolygonId.keySet()){
            for(LVC_DeliveryRoute__c dr : deliveryRoutesByPolygonId.get(polygonExtId)){
                if(dr.Active__c == true){
                    if(deliveryCapacitiesMap.keySet().contains(dr.Delivery__c)){
                        SFCCCapacityHelper.DeliveryCombination drw = new SFCCCapacityHelper.DeliveryCombination();
                        drw.polygonExternalId = polygonExtId;
                        drw.deliveryRouteSFId = dr.Id;
                        drw.deliveryRouteExternalId = dr.DeliveryRouteExternalId__c;
                        drw.deliverySFId = dr.Delivery__c;
                        drw.deliverySchedule = setDeliverySchedule(dr);
                        drw.deliveryCapacity = setCapacityByDayOfWeek(dr, deliveryCapacitiesMap.get(dr.Delivery__c));
                        deliveryCombinationList.add(drw);
                    }
                }
            }
        }

        //Sort wrapperList and store it in a map, for easy access
        Map<String, List<SFCCCapacityHelper.DeliveryCombination>> combinationsResult = new Map<String, List<SFCCCapacityHelper.DeliveryCombination>>();
        for(SFCCCapacityHelper.DeliveryCombination drw : deliveryCombinationList){
            combinationsResult.put(drw.polygonExternalId, sortDeliveryCombinations(drw.polygonExternalId, deliveryCombinationList));
        }

        System.debug('## combinationsResult: ' + combinationsResult);

        return combinationsResult;
    }

    private static Set<String> getDeliveryRoutesIdsByPolygonId(String polygonExtId, List<LVC_PolygonRoute__c> polygonRouteList){
        Set<String> sortedPolygonRoutes = new Set<String>();
        for(LVC_PolygonRoute__c polygonRoute : polygonRouteList){
            if(polygonRoute.Polygon__r.PolygonExternalId__c == polygonExtId){
                sortedPolygonRoutes.add(polygonRoute.DeliveryRoute__c);
            }
        }
        return sortedPolygonRoutes;
    }

    private static List<LVC_DeliveryRoute__c> sortDeliveryRoutes(Set<String> deliveryIdSet, List<LVC_DeliveryRoute__c> deliveryRoutesList){
        List<LVC_DeliveryRoute__c> sortedDeliveryRoutes = new List<LVC_DeliveryRoute__c>();
        for(LVC_DeliveryRoute__c deliveryRoute : deliveryRoutesList){
            if(deliveryIdSet.contains(deliveryRoute.Id)){
                sortedDeliveryRoutes.add(deliveryRoute);
            }
        }
        return sortedDeliveryRoutes;
    }

    private static Map<String, String> setDeliverySchedule(LVC_DeliveryRoute__c deliveryRoute){
        Map<String, String> frequencyPicklistMap = new Map<String, String>();
        Schema.DescribeFieldResult frequecyField = LVC_DeliveryRoute__c.DeliverySchedule__c.getDescribe();
        for(Schema.PicklistEntry fieldValue : frequecyField.getPicklistValues()){
            frequencyPicklistMap.put(fieldValue.getValue(), fieldValue.getLabel());
        }
        Map<String, String> timeSuggestion = new Map<String, String>();
        timeSuggestion.put(deliveryRoute.DeliverySchedule__c, frequencyPicklistMap.get(deliveryRoute.DeliverySchedule__c));

        return timeSuggestion;
    }

    private static Map<String, Integer> setCapacityByDayOfWeek(LVC_DeliveryRoute__c deliveryRoute, LVC_Delivery__c deliveryCapacity){
        Map<String, Integer> capacityByDayOfWeek = new Map<String, Integer>();

        if(deliveryRoute.Sunday__c == true) {
            if(deliveryCapacity.Sunday__c > 0){
                capacityByDayOfWeek.put('Sunday', Integer.valueOf(deliveryCapacity.Sunday__c));
            }
        }

        if(deliveryRoute.Monday__c == true) {
            if(deliveryCapacity.Monday__c > 0){
                capacityByDayOfWeek.put('Monday', Integer.valueOf(deliveryCapacity.Monday__c));
            }
        }

        if(deliveryRoute.Tuesday__c == true) {
            if(deliveryCapacity.Tuesday__c > 0){
                capacityByDayOfWeek.put('Tuesday', Integer.valueOf(deliveryCapacity.Tuesday__c));
            }
        }

        if(deliveryRoute.Wednesday__c == true) {
            if(deliveryCapacity.Wednesday__c > 0){
                capacityByDayOfWeek.put('Wednesday', Integer.valueOf(deliveryCapacity.Wednesday__c));
            }
        }

        if(deliveryRoute.Thursday__c == true) {
            if(deliveryCapacity.Thursday__c > 0){
                capacityByDayOfWeek.put('Thursday', Integer.valueOf(deliveryCapacity.Thursday__c));
            }
        }

        if(deliveryRoute.Friday__c == true) {
            if(deliveryCapacity.Friday__c > 0){
                capacityByDayOfWeek.put('Friday', Integer.valueOf(deliveryCapacity.Friday__c));
            }
        }

        if(deliveryRoute.Saturday__c == true) {
            if(deliveryCapacity.Saturday__c > 0){
                capacityByDayOfWeek.put('Saturday', Integer.valueOf(deliveryCapacity.Saturday__c));
            }
        }

        return capacityByDayOfWeek;
    }

    private static List<SFCCCapacityHelper.DeliveryCombination> sortDeliveryCombinations(String polygonExtId, List<SFCCCapacityHelper.DeliveryCombination> drwList){
        List<SFCCCapacityHelper.DeliveryCombination> sortedWrapper = new List<SFCCCapacityHelper.DeliveryCombination>();
        for(SFCCCapacityHelper.DeliveryCombination drw : drwList){
            if(drw.polygonExternalId == polygonExtId){
                sortedWrapper.add(drw);
            }
        }
        return sortedWrapper;
    }
}