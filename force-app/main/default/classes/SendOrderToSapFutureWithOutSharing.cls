public without sharing class SendOrderToSapFutureWithOutSharing {
    @InvocableMethod(label='Send Order no fee To SAP' description='Send order no fee to sap')
    public static void sendOrderSinCargoToSap(List<string> recordId){
        System.debug('SendOrder to Sap');
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
        sendOrderToSapFuture(body, typeObj, recordName, orden.Id);
       
    }
    @testVisible
    public static void sendEmail (WebServiceSap.SendAlta respuesta){
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
        orden.Status_SAP__c = sapStatus;
        update orden;
    }

    @future(callout=true)
    public static void sendOrderToSapFuture(String body, String typeObj, String recordName, Id pedido)
    {   
        WebServiceSap.SendAlta respuesta = WebServiceSap.sendAltaToSap(body, typeObj, recordName);
        System.debug('respuesta --->'+respuesta);
        System.debug(!(respuesta.response.getStatusCode() == 200));
        System.debug(respuesta.response.getStatusCode());
        updateOrderSAP(pedido,respuesta.response.getBody());
        if(!(respuesta.response.getStatusCode() == 200)){
            sendEmail(respuesta);
        }
    }
}