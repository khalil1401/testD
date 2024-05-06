public with sharing class sendOrderToSapController {
    @AuraEnabled
    public static void sendOrderToSap(string recordId){
        Order orden = [
            SELECT id, Orden_de_compra__c,OrderNumber, Dan360_UnidadNegocio__c, RecordType.Name ,
                EndDate, EffectiveDate, Dan360_FechaInicioCarrito__c, Dan360_FechaCierreCarrito__c,
                AccountId, Description, Status, Dan360_CustomerSalesArea__c,Status_SAP__c, Dan360_OrderReason__c
            FROM Order 
            WHERE Id = :recordId
        ];

        System.debug('orden.Status ---->'+orden.Status);

        if(orden.Status == 'Confirmado'){
            Map<String,Order> orderMap = new Map<String,Order>();
            orderMap.put(orden.Id, orden);
            String typeObj = 'Order';
            BatchSendOrdersToSap orderBatch = new BatchSendOrdersToSap(orderMap, typeObj);
            ID batchId = Database.executeBatch(orderBatch);
        } else {
            throw new applicationException('Error: La Orden no esta Confirmada');
        }
        
    }

    @InvocableMethod(label='Send Order To SAP' description='Send order to sap')
    public static void sendOrderToSapFlow(List<string> recordId){

        // List<String> errorMensaje = new List<String>{'Hola'};
        // String orderId = recordId[0];
        
        // Order orden = [
        //     SELECT id, Orden_de_compra__c,OrderNumber, Dan360_UnidadNegocio__c, RecordType.Name ,
        //         EndDate, EffectiveDate, Dan360_FechaInicioCarrito__c, Dan360_FechaCierreCarrito__c,
        //         AccountId, Description, Status, Dan360_CustomerSalesArea__c,Status_SAP__c, Dan360_OrderReason__c
        //     FROM Order 
        //     WHERE Id = :orderId
        // ];
        
        // Map<String,Order> orderMap = new Map<String,Order>();
        // orderMap.put(orden.Id, orden);
        // List<sendOrdersToSapHelper.OrderSAP> orderToSAP = new sendOrdersToSapHelper().getMapWithProducts(orderMap, 'Order');
        // System.debug(orderToSAP[0].MapOrderBody);
        // String body = JSON.serialize(orderToSAP[0].MapOrderBody);
        // System.debug(body);
        // String typeObj = 'Order';
        // String recordName = orderToSAP[0].recordName;
        // sendOrderToSapFuture(body, typeObj, recordName, orden.Id);
        sendOrderToSapFuture(recordId);
       
    }

    @AuraEnabled
    public static void sendCaseToSap(string recordId){
        System.debug('recordId ---------->'+recordId);
        
        Case reclamo = [
            SELECT Id, CaseNumber, Dan360_MotivoDeReclamo__c, RecordType.Name, Dan360_Pedido__c,Dan360_EnviadoSAP__c, Description, 
            Dan360_RequiredDeliveryDate__c, Dan360_OrderedDate__c, Dan360_OrderGetStart__c,Dan360_OrderGetEnd__c,
            Dan360_Remito__r.Dan360_Delivery__c, Dan360_Factura__r.Dan360_Id_Externo__c,CreatedDate
            FROM Case 
            WHERE iD = :recordId
        ];

        System.debug('reclamo ---------->'+reclamo);

            Map<String,Case> caseMap = new Map<String,Case>();
            caseMap.put(reclamo.Id, reclamo);
            String typeObj = 'Case';

            BatchSendOrdersToSap caseBatch = new BatchSendOrdersToSap(caseMap, typeObj);
            ID batchId = Database.executeBatch(caseBatch);  
    }
	
    @testVisible
    private static void sendEmail (WebServiceSap.SendAlta respuesta){
        System.debug('sendEmail');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'leonardo.jimenez@globant.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('La orden no pudo ser enviada a SAP');
        mail.setPlainTextBody('La orden no se envio a sap, Codigo: ' + respuesta.response.getStatusCode() +', ' + respuesta.response.getStatus());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public static void updateOrderSAP (Id orderId, String sapStatus){
        Order orden = [
            SELECT id, Status_SAP__c
            FROM Order 
            WHERE Id = :orderId
        ];
        if(sapStatus.length() < 40 ){
            orden.Status_SAP__c = sapStatus;
        }else{
            orden.Status_SAP__c =  sapStatus.substring(0, 39);
        }
        update orden;
    }

    // @future(callout=true)
    // public static void sendOrderToSapFuture(String body, String typeObj, String recordName, Id pedido)
    // {   
    //     WebServiceSap.SendAlta respuesta = WebServiceSap.sendAltaToSap(body, typeObj, recordName);
    //     System.debug('respuesta --->'+respuesta);
    //     System.debug(!(respuesta.response.getStatusCode() == 200));
    //     System.debug(respuesta.response.getStatusCode());
    //     updateOrderSAP(pedido,respuesta.response.getBody());
    //     if(!(respuesta.response.getStatusCode() == 200)){
    //         sendEmail(respuesta);
    //     }
    // }
    @future(callout=true)
    public static void sendOrderToSapFuture(List<string> recordId)
    {   

        List<String> errorMensaje = new List<String>{'Hola'};
        String orderId = recordId[0];
        
        Order orden = [
            SELECT id, Orden_de_compra__c,OrderNumber, Dan360_UnidadNegocio__c, RecordType.Name ,
                EndDate, EffectiveDate, Dan360_FechaInicioCarrito__c, Dan360_FechaCierreCarrito__c,
                AccountId, Description, Status, Dan360_CustomerSalesArea__c,Status_SAP__c, Dan360_OrderReason__c
            FROM Order 
            WHERE Id = :orderId
        ];
        
        Map<String,Order> orderMap = new Map<String,Order>();
        orderMap.put(orden.Id, orden);
        List<sendOrdersToSapHelper.OrderSAP> orderToSAP = new sendOrdersToSapHelper().getMapWithProducts(orderMap, 'Order');
        System.debug(orderToSAP[0].MapOrderBody);
        String body = JSON.serialize(orderToSAP[0].MapOrderBody);
        System.debug(body);
        String typeObj = 'Order';
        String recordName = orderToSAP[0].recordName;

        WebServiceSap.SendAlta respuesta = WebServiceSap.sendAltaToSap(body, typeObj, recordName);
        System.debug('respuesta --->'+respuesta);
        System.debug(!(respuesta.response.getStatusCode() == 200));
        System.debug(respuesta.response.getStatusCode());
        updateOrderSAP(orden.Id,respuesta.response.getBody());
        if(!(respuesta.response.getStatusCode() == 200)){
            sendEmail(respuesta);
        }
    }

    public class applicationException extends Exception {}

    
    

}