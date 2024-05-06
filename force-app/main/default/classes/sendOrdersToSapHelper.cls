public with sharing class sendOrdersToSapHelper {
    public List<OrderSAP> getMapWithProducts(Map<String,SObject> objs, String tipoSObj) {
        List<OrderSAP> pedidoSAP = new List<OrderSAP>();
        List<Order> listOrder = new List<Order>();
        Order order;
        Map<Id, Order> mapCasoOrden = new Map<Id,Order>();
        Case caso;
        List<Case> listCase = new List<Case>();
        Set<String> listOrdersFromCaseIds = new Set<String>();
        Map<String, Id> mapOrdenCase = new Map<String,Id>();
        Map<Id, List<OrderItem>> ordenItemListMap = new Map<Id, List<OrderItem>>();
        Map<Id,List<Dan360_ProductosDeReclamo__c>> caseItemListMap = new Map<Id,List<Dan360_ProductosDeReclamo__c>>();
        List<OrderSAP> mapOrderWithProducts = new List<OrderSAP>();

        Map<Id, String> mapCustomerSalesAreaIdsOrder = new Map<Id, String>();
        Set<String> customerSalesAreaIds = new Set<String>();
        Set<String> accountsIds = new Set<String>();
        for(String idSObject : objs.keySet()){
            SObject obj = objs.get(idSObject);
            if( tipoSObj == 'Order'){
                order = (Order) obj;
                listOrder.add(order);
                customerSalesAreaIds.add(order.Dan360_CustomerSalesArea__c);
                accountsIds.add(order.AccountId);
                if(!mapCustomerSalesAreaIdsOrder.containsKey(order.Id)){
                    mapCustomerSalesAreaIdsOrder.put(order.Id, order.Dan360_CustomerSalesArea__c);
                }
            }
            if( tipoSObj == 'Case'){
                caso = (Case) obj;
                listCase.add(caso);
                listOrdersFromCaseIds.add(caso.Dan360_Pedido__c);
                if(!mapOrdenCase.containsKey(caso.Dan360_Pedido__c)){
                    mapOrdenCase.put(caso.Dan360_Pedido__c, caso.Id);
                }
            }
        }

        if(tipoSObj == 'Order'){
            for(OrderItem orIt : [
                SELECT id, Quantity, Product2.ProductCode, 
                PricebookEntry.Dan360_UnidadMedida__c, OrderId, Dan360_UnidadMedida__c
                FROM OrderItem 
                WHERE OrderId = :objs.keySet()
            ]){
                if(!ordenItemListMap.containsKey(orIt.OrderId)){
                    ordenItemListMap.put(orIt.OrderId, new List<OrderItem>());
                }
                ordenItemListMap.get(orIt.OrderId).add(orIt);
            }
        }
        if(tipoSObj == 'Case'){
            for( Dan360_ProductosDeReclamo__c productoCase : [
                SELECT id, Dan360_CantidadDevolver__c, Dan360_Producto__r.ProductCode, Dan360_IDLineaReferenciaSAP__c,
                Dan360_UnidadMedidaProducto__c, Dan360_DiferenciaPrecio__c, Dan360_Reclamo__c, Dan360_CantidadProductoFaltante__c,Precio_Cotizado__c, Diferencia_Precio_Unitario__c
                FROM Dan360_ProductosDeReclamo__c 
                WHERE Dan360_Reclamo__c =:objs.keySet()
            ]){
                if(!caseItemListMap.containsKey(productoCase.Dan360_Reclamo__c)){
                    caseItemListMap.put(productoCase.Dan360_Reclamo__c, new List<Dan360_ProductosDeReclamo__c>());
                }
                caseItemListMap.get(productoCase.Dan360_Reclamo__c).add(productoCase);
            }

            for(Order pedidoVinculado : [
                SELECT id, Orden_de_compra__c,OrderNumber, Dan360_UnidadNegocio__c, RecordType.Name , EndDate,
                EffectiveDate, Dan360_FechaInicioCarrito__c, Dan360_FechaCierreCarrito__c, AccountId, Description,
                Status, Dan360_CustomerSalesArea__c, Dan360_OrderReason__c,ActivatedDate
                FROM Order 
                WHERE Id = : listOrdersFromCaseIds
            ]){
                accountsIds.add(pedidoVinculado.AccountId);
                customerSalesAreaIds.add(pedidoVinculado.Dan360_CustomerSalesArea__c);
                if(!mapCustomerSalesAreaIdsOrder.containsKey(pedidoVinculado.Id)){
                    mapCustomerSalesAreaIdsOrder.put(pedidoVinculado.Id, pedidoVinculado.Dan360_CustomerSalesArea__c);
                }
                Id casoId = mapOrdenCase.get(pedidoVinculado.Id);
                if(!mapCasoOrden.containsKey(casoId)){
                    mapCasoOrden.put(casoId, pedidoVinculado);
                }
            }
        }

        Map<Id, String> mapSalesAreaIdsOrder = new Map<Id,String>();
        Set<String> salesAreasIds = new Set<String>();
        for(Dan360_CustomerSalesArea__c customerSalesArea : [
            SELECT Id, Dan360_SalesArea__c
            FROM Dan360_CustomerSalesArea__c
            WHERE Id = : customerSalesAreaIds
        ]){
            if(!mapSalesAreaIdsOrder.containsKey(customerSalesArea.Id)){
                mapSalesAreaIdsOrder.put(customerSalesArea.Id,customerSalesArea.Dan360_SalesArea__c);
            }
            salesAreasIds.add(customerSalesArea.Dan360_SalesArea__c);
        }
         
        Map<String, Dan360_SalesArea__c> salesAreasCustomerMap = new Map<String, Dan360_SalesArea__c>();
        for(Dan360_SalesArea__c salesArea : [
            SELECT Dan360_SalesOrganization__c, Dan360_DistributionChannel__c
            FROM Dan360_SalesArea__c 
            WHERE Id = : salesAreasIds
        ]){
            for(String customerSalesAreaId : mapSalesAreaIdsOrder.keySet()){
                String salesAreaId = mapSalesAreaIdsOrder.get(customerSalesAreaId);
                if(salesArea.Id == salesAreaId){
                    if(!salesAreasCustomerMap.containsKey(customerSalesAreaId)){
                        salesAreasCustomerMap.put(customerSalesAreaId, salesArea);
                    }
                }
            }
        }

        Map<Id,Dan360_SalesArea__c> salesAreaWithOrderMap = new Map<Id,Dan360_SalesArea__c>();
        for(String orderIds: mapCustomerSalesAreaIdsOrder.keySet()){
            String customerId = mapCustomerSalesAreaIdsOrder.get(orderIds);
            if(salesAreasCustomerMap.containsKey(customerId)){
                Dan360_SalesArea__c salesAreaAdd = salesAreasCustomerMap.get(customerId);
                if(!salesAreaWithOrderMap.containsKey(orderIds)){
                    salesAreaWithOrderMap.put(orderIds, salesAreaAdd);
                }
            }
        }
        System.debug(accountsIds);
        Map<String, Map<String, Map<String,String>>> mapOrderPartners = new Map<String, Map<String, Map<String,String>>>();
        for(Dan360_Partner__c partners : [
            SELECT Id,Dan360_CustomerSalesArea__r.Dan360_Customer__c, Dan360_CustomerSalesArea__r.Dan360_SalesArea__r.Dan360_SalesOrganization__c , Dan360_Id_Externo__c, Dan360_Rol__c, Dan360_Customer__r.Id_SAP__c, Organization__c
            FROM Dan360_Partner__c 
            WHERE Dan360_Rol__c IN ('WE', 'AG') 
                AND Dan360_CustomerSalesArea__r.Dan360_Customer__c IN :accountsIds
        ]){
            System.debug(partners);
            if(!mapOrderPartners.containsKey(partners.Dan360_CustomerSalesArea__r.Dan360_Customer__c)){
                mapOrderPartners.put(partners.Dan360_CustomerSalesArea__r.Dan360_Customer__c, new Map<String, Map<String,String>>());
            }
            if(!mapOrderPartners.get(partners.Dan360_CustomerSalesArea__r.Dan360_Customer__c).containsKey(partners.Dan360_Rol__c)){
                mapOrderPartners.get(partners.Dan360_CustomerSalesArea__r.Dan360_Customer__c).put(partners.Dan360_Rol__c, new Map<String,String>());
            }
            if(!mapOrderPartners.get(partners.Dan360_CustomerSalesArea__r.Dan360_Customer__c).get(partners.Dan360_Rol__c).containsKey(partners.Dan360_CustomerSalesArea__r.Dan360_SalesArea__r.Dan360_SalesOrganization__c)){
                mapOrderPartners.get(partners.Dan360_CustomerSalesArea__r.Dan360_Customer__c).get(partners.Dan360_Rol__c).put(partners.Dan360_CustomerSalesArea__r.Dan360_SalesArea__r.Dan360_SalesOrganization__c, partners.Dan360_Customer__r.Id_SAP__c);
            }
        }

        System.debug(mapOrderPartners);

        if(tipoSObj == 'Order'){
            try {
                mapOrderWithProducts = createOrderBody(listOrder, salesAreaWithOrderMap, mapOrderPartners, ordenItemListMap, tipoSObj);
            } catch (Exception e) {
                throw new applicationException('Error al crear la Orden para SAP');
            }
        }

        if(tipoSObj == 'Case'){
            try {
                mapOrderWithProducts = createCaseBody(mapCasoOrden, listCase, salesAreaWithOrderMap,mapOrderPartners, caseItemListMap, tipoSObj);
            } catch (Exception e) {
                throw new applicationException('Error al crear el Caso para SAP');
            }
            
        }
        System.debug(mapOrderWithProducts);
        return mapOrderWithProducts;
        
    }

    private static List<OrderSAP> createOrderBody(List<Order> orders, Map<Id,Dan360_SalesArea__c> salesAreaWithOrderMap, Map<String, Map<String, Map<String,String>>> mapOrderPartners, Map<Id, List<OrderItem>> ordenItemListMap, String tipoSObj ){
        Map<String, Object> mapBodyList = new Map<String, Object>();
        List<OrderSAP> listOrderSAP = new List<OrderSAP>();
        for(Order order : orders){
            String orderReason = '';
            Dan360_SalesArea__c salesArea = salesAreaWithOrderMap.get(order.Id);
            System.debug('order.Dan360_OrderReason__c');
            System.debug(order.Dan360_OrderReason__c);
            Map<String, Map<String,String>> mapPartner = mapOrderPartners.get(order.AccountId);
          
            Map<String,String> mapRolSP = mapPartner.get('AG');
            Map<String,String> mapRolWE = mapPartner.get('WE');
            
            String soldTo = mapRolSP.get(salesArea.Dan360_SalesOrganization__c);
            String shipTo = mapRolWE.get(salesArea.Dan360_SalesOrganization__c);
           
            List<OrderItem> ordenItemList = ordenItemListMap.get(order.Id);

            List<Map<String, Object>> listOrderItem = new List<Map<String, Object>>();
            Integer itemNumber = 1;
            Boolean isFreeOfCharge;
            switch on order.RecordType.Name {
                when 'Pedido de Venta Directa' { isFreeOfCharge = false;}
                when 'Pedido sin Cargo' {isFreeOfCharge = true; orderReason = order.Dan360_OrderReason__c;}
            }

            System.debug(orderReason);
                for(OrderItem OrderIt : ordenItemList){
                    Map<String, Object> mapOrderIt = new Map<String, Object>{
                        'itemNumber' => itemNumber,
                        'matNumber' => String.isBlank(orderIt.Product2.ProductCode) ? '' : orderIt.Product2.ProductCode,
                        'orderedQuantity' => orderIt.Quantity,
                        'um' => 'un'
                    };
                    itemNumber += 1;
                    listOrderItem.add(mapOrderIt);
                }  
           
                Map<String, Object> mapOrderToConvert = new Map<String, Object>{
                    'source' => 'SAFO',
                    'orderNumber' => order.OrderNumber,
                    'soldTo' => String.isBlank(soldTo) ? '' : soldTo,
                    'shipTo' => String.isBlank(shipTo) ? '' : shipTo,
                    'businessModel' => 'B2B',
                    'companyCode' => String.isBlank(salesArea.Dan360_SalesOrganization__c) ? '' : salesArea.Dan360_SalesOrganization__c,
                    'organizationId' => String.isBlank(salesArea.Dan360_SalesOrganization__c) ? '' : salesArea.Dan360_SalesOrganization__c,
                    'channelId' => String.isBlank(salesArea.Dan360_DistributionChannel__c) ? '' : salesArea.Dan360_DistributionChannel__c,
                    'isFreeOfCharge' => isFreeOfCharge,
                    'orderReason' => orderReason,
                    'reqDelDate' => order.EndDate != null ? (Datetime)order.EndDate : (Datetime)Date.parse('01/01/2000'),
                    'orderDate' => order.EffectiveDate != null ? (Datetime)order.EffectiveDate : (Datetime)Date.parse('01/01/2000'), 
                    'orderGetStart' => order.Dan360_FechaInicioCarrito__c != null ? order.Dan360_FechaInicioCarrito__c : Datetime.newInstance(1960, 2, 17),
                    'orderGetFinal' => order.Dan360_FechaCierreCarrito__c != null ? order.Dan360_FechaCierreCarrito__c : Datetime.newInstance(1960, 2, 17),
                    'poType' => '',
                    'poNumber' =>order.Orden_de_compra__c,
                    'note' => order.Description,
                    'items' => listOrderItem

                };
                OrderSAP pedidoSapToAdd = new OrderSAP();
                System.debug(mapOrderToConvert);
                pedidoSapToAdd.MapOrderBody = mapOrderToConvert;
                pedidoSapToAdd.pedido = order;
                pedidoSapToAdd.typeObj = tipoSObj;
                pedidoSapToAdd.recordName = order.RecordType.Name;
                System.debug(pedidoSapToAdd);
                listOrderSAP.add(pedidoSapToAdd);
            
            
        }
        
        return listOrderSAP;
    }
    
    private static List<OrderSAP> createCaseBody(Map<Id, Order> mapCasoOrden, List<Case> listCase,  Map<Id,Dan360_SalesArea__c> salesAreaWithOrderMap, Map<String, Map<String, Map<String,String>>> mapOrderPartners, Map<Id,List<Dan360_ProductosDeReclamo__c>> caseItemListMap, String tipoSObj){
        List<OrderSAP> listCaseSAP = new List<OrderSAP>();
        for(Case caso : listCase){
            Order order = mapCasoOrden.get(caso.Id);
            System.debug('order');
            System.debug(order);
            Dan360_SalesArea__c salesArea = salesAreaWithOrderMap.get(order.Id);
            System.debug('salesArea');
            System.debug(salesArea);
            System.debug('mapOrderPartners');
            System.debug(mapOrderPartners);
            Map<String, Map<String,String>> mapPartner = mapOrderPartners.get(order.AccountId);
            Map<String,String> mapRolSP = mapPartner.get('AG');
            Map<String,String> mapRolWE = mapPartner.get('WE');
            
            String soldTo = mapRolSP.get(salesArea.Dan360_SalesOrganization__c);
            String shipTo = mapRolWE.get(salesArea.Dan360_SalesOrganization__c);
            System.debug('soldTo');
            System.debug(soldTo);
            System.debug('shipTo');
            System.debug(shipTo);
            List<Dan360_ProductosDeReclamo__c> caseItemList = caseItemListMap.get(caso.Id);
            System.debug('caseItemList');
            System.debug(caseItemList);
            if(caso.RecordType.Name == 'Devoluciones' || caso.RecordType.Name == 'Devoluciones de pedidos sin cargo'){
                listCaseSAP.add(createReturnBody(order, caso, salesArea, soldTo,shipTo, caseItemList, tipoSObj));
            }
            if(caso.RecordType.Name == 'Diferencia de precios y descuentos' || caso.RecordType.Name == 'Reclamo por faltantes'){
                listCaseSAP.add(createClaimBody(order, caso, salesArea,soldTo,shipTo, caseItemList, tipoSObj));
            }
        }
        return listCaseSAP;
    }

    
    private static OrderSAP createReturnBody(Order order, Case caso, Dan360_SalesArea__c salesArea, String soldTo, String shipTo, /* Map<String, String> mapPartner, */ List<Dan360_ProductosDeReclamo__c> caseItemList, String tipoSObj){
        List<Map<String, Object>> listCaseItem = new List<Map<String, Object>>();
        String referenceDocNumber;
        String orderReason;
        String orderType;
        Datetime confirmDate = caso.CreatedDate;
        Datetime reqDateDevoluciones;
        Datetime reqDate = caso.CreatedDate.addDays(15);
        
        switch on caso.RecordType.Name {
            when  'Devoluciones' {
                referenceDocNumber = String.isBlank(caso.Dan360_Factura__r.Dan360_Id_Externo__c) ? '' : caso.Dan360_Factura__r.Dan360_Id_Externo__c;
                orderReason = 'AR6';
                orderType = 'RD';
                confirmDate = order.ActivatedDate;
                reqDate = order.ActivatedDate;
            }
            when 'Reclamo por faltantes' {
                referenceDocNumber = String.isBlank(caso.Dan360_Factura__r.Dan360_Id_Externo__c) ? '' : caso.Dan360_Factura__r.Dan360_Id_Externo__c;
                orderReason = 'AFA';
                orderType = 'CR';
            }
            when 'Devoluciones de pedidos sin cargo' {
                referenceDocNumber = String.isBlank(caso.Dan360_Remito__r.Dan360_Delivery__c) ? '' : caso.Dan360_Remito__r.Dan360_Delivery__c;
                orderReason = order.Dan360_OrderReason__c ;
                orderType = 'RS';    
            }
        }
        System.debug('orderType');
        System.debug(orderType);
        for(Dan360_ProductosDeReclamo__c CaseIt : caseItemList){
            String orderedQuantity;
            switch on caso.RecordType.Name {
                when  'Devoluciones'{
                    orderedQuantity = String.isBlank(CaseIt.Dan360_CantidadDevolver__c) ? '' : CaseIt.Dan360_CantidadDevolver__c;  
                }
                when  'Devoluciones de pedidos sin cargo' {
                    orderedQuantity = String.isBlank(CaseIt.Dan360_CantidadDevolver__c) ? '' : CaseIt.Dan360_CantidadDevolver__c;
                }
                when 'Reclamo por faltantes' {
                    orderedQuantity = String.isBlank(CaseIt.Dan360_CantidadProductoFaltante__c) ? '' : CaseIt.Dan360_CantidadProductoFaltante__c;
                }
            }
            Map<String, Object> mapCaseIt = new Map<String, Object>{
                'refItemNumber' => String.isBlank(CaseIt.Dan360_IDLineaReferenciaSAP__c) ? '' : CaseIt.Dan360_IDLineaReferenciaSAP__c,
                'matNumber' => String.isBlank(CaseIt.Dan360_Producto__r.ProductCode) ? '' : CaseIt.Dan360_Producto__r.ProductCode,
                'orderedQuantity' => orderedQuantity,
                'um' => String.isBlank(CaseIt.Dan360_UnidadMedidaProducto__c) ? '' : CaseIt.Dan360_UnidadMedidaProducto__c
            };
            listCaseItem.add(mapCaseIt);
        }
        Map<String, Object> mapCaseToConvert = new Map<String, Object>{
            'source' => 'SAFO',
            'orderNumber' => caso.CaseNumber,
            'referenceDocNumber' => referenceDocNumber,
            'soldTo' => String.isBlank(soldTo) ? '' : soldTo,
            'shipTo' => String.isBlank(shipTo) ? '' : shipTo,
            'businessModel' => 'B2B',
            'companyCode' => String.isBlank(salesArea.Dan360_SalesOrganization__c) ? '' : salesArea.Dan360_SalesOrganization__c,
            'organizationId' => String.isBlank(salesArea.Dan360_SalesOrganization__c) ? '' : salesArea.Dan360_SalesOrganization__c,
            'channelId' => String.isBlank(salesArea.Dan360_DistributionChannel__c) ? '' : salesArea.Dan360_DistributionChannel__c,
            'orderType' => orderType,
            'orderReason' => String.isBlank(orderReason) ? '' : orderReason,
            'returnReason' => String.isBlank(caso.Dan360_MotivoDeReclamo__c) ? '' : caso.Dan360_MotivoDeReclamo__c,
            'reqDelDate' => reqDate,
            'orderDate' => confirmDate,
            'orderGetStart' => caso.Dan360_OrderGetStart__c != null ? (Datetime)caso.Dan360_OrderGetStart__c : (Datetime)Date.parse('01/01/2000'),// VER
            'orderGetFinal' => caso.Dan360_OrderGetEnd__c != null ? (Datetime)caso.Dan360_OrderGetEnd__c : (Datetime)Date.parse('01/01/2000'),// VER 
            'poType' => '',
            'note' => caso.Description,
            'items' => listCaseItem
        };
       
        System.debug('mapCaseToConvert');
        System.debug(mapCaseToConvert);
        OrderSAP caseSapToAdd = new OrderSAP();
        caseSapToAdd.MapOrderBody = mapCaseToConvert;
        caseSapToAdd.pedido = order;
        caseSapToAdd.caso = caso;
        caseSapToAdd.typeObj = tipoSObj;
        caseSapToAdd.recordName = caso.RecordType.Name;

        System.debug('caseSapToAdd --------->'+caseSapToAdd);
        return caseSapToAdd;
    }
    
    private static OrderSAP createClaimBody(Order order, Case caso, Dan360_SalesArea__c salesArea, String soldTo, String shipTo, /* Map<String, String> mapPartner, */ List<Dan360_ProductosDeReclamo__c> caseItemList, String tipoSObj ){
        List<Map<String, Object>> listCaseItem = new List<Map<String, Object>>();
        Date reqDate = date.newinstance(caso.CreatedDate.year(), caso.CreatedDate.month(), caso.CreatedDate.day()).addDays(15);
        String orderReason = 'AG8';
        if(caso.RecordType.Name == 'Reclamo por faltantes'){
            orderReason = 'AFA';
        }

        for(Dan360_ProductosDeReclamo__c CaseIt : caseItemList){
            System.debug('CaseIt');
            System.debug(CaseIt);
            Decimal difPrecio;
            String cantDevolver;
            
            if(caso.RecordType.Name == 'Reclamo por faltantes'){
                difPrecio = CaseIt.Diferencia_Precio_Unitario__c;
                cantDevolver = CaseIt.Dan360_CantidadProductoFaltante__c;
                
            } else {
                difPrecio = CaseIt.Diferencia_Precio_Unitario__c.setscale(2,System.RoundingMode.HALF_DOWN);
                cantDevolver = CaseIt.Dan360_CantidadDevolver__c;
            }
            
            Map<String, Object> mapCaseIt = new Map<String, Object>{
                'refItemNumber' => String.isBlank(CaseIt.Dan360_IDLineaReferenciaSAP__c) ? '' : CaseIt.Dan360_IDLineaReferenciaSAP__c,
                'matNumber' => String.isBlank(CaseIt.Dan360_Producto__r.ProductCode) ? '' : CaseIt.Dan360_Producto__r.ProductCode,
                'orderedQuantity' => cantDevolver,
                'um' => String.isBlank(CaseIt.Dan360_UnidadMedidaProducto__c) ? '' : CaseIt.Dan360_UnidadMedidaProducto__c,
                'difference' => difPrecio == null ? 0.00 : difPrecio
            };
            listCaseItem.add(mapCaseIt);
        }
        System.debug(listCaseItem);
        System.debug('listCaseItem');
        Map<String, Object> mapCaseToConvert = new Map<String, Object>{
            'source' => 'SAFO',
            'orderNumber' => caso.CaseNumber,
            'referenceDocNumber' => String.isBlank(caso.Dan360_Factura__r.Dan360_Id_Externo__c) ? '' : caso.Dan360_Factura__r.Dan360_Id_Externo__c,
            'soldTo' => String.isBlank(soldTo) ? '' : soldTo,
            'shipTo' => String.isBlank(shipTo) ? '' : shipTo,
            'businessModel' => 'B2B',
            'companyCode' => String.isBlank(salesArea.Dan360_SalesOrganization__c) ? '' : salesArea.Dan360_SalesOrganization__c,
            'organizationId' => String.isBlank(salesArea.Dan360_SalesOrganization__c) ? '' : salesArea.Dan360_SalesOrganization__c,
            'channelId' => String.isBlank(salesArea.Dan360_DistributionChannel__c) ? '' : salesArea.Dan360_DistributionChannel__c,
            'orderType' => 'CR',
            'orderReason' => orderReason, 
            'reqDelDate' => (Datetime)reqDate,
            'orderDate' => caso.CreatedDate,
            'orderGetStart' => caso.Dan360_OrderGetStart__c != null ? (Datetime)caso.Dan360_OrderGetStart__c : (Datetime)Date.parse('01/01/2000'),
            'orderGetFinal' => caso.Dan360_OrderGetEnd__c != null ? (Datetime)caso.Dan360_OrderGetEnd__c : (Datetime)Date.parse('01/01/2000'),
            'poType' => '',
            'note' => caso.Description,
            'items' => listCaseItem
        };

        OrderSAP caseSapToAdd = new OrderSAP();
        caseSapToAdd.MapOrderBody = mapCaseToConvert;
        caseSapToAdd.pedido = order;
        caseSapToAdd.caso = caso;
        caseSapToAdd.typeObj = tipoSObj;
        caseSapToAdd.recordName = caso.RecordType.Name;

        return caseSapToAdd;
    }
    
    public class OrderSAP {
        public Map<String, Object> MapOrderBody {get; set;}
        public order pedido {get; set;}
        public case caso {get; set;}
        public String typeObj {get; set;}
        public String recordName {get; set;}
    }


    public class applicationException extends Exception {}
}