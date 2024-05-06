public with sharing class BatchSendOrdersToSap implements Database.Batchable<sendOrdersToSapHelper.OrderSAP>, Database.AllowsCallouts, Database.Stateful{
    List<Case> casesToUpdate = new List<Case>();
    List<sendOrdersToSapHelper.OrderSAP> casosEnviadosASAP = new List<sendOrdersToSapHelper.OrderSAP>();
    Map<String,SObject> objetos;
    String tipoObj;
    Integer contador = 0;

    public BatchSendOrdersToSap(Map<String,SObject> objetosP, String tipoObjP){
        objetos = objetosP;
        tipoObj = tipoObjP;
    }

    public List<sendOrdersToSapHelper.OrderSAP> start(Database.BatchableContext BC){
        return new sendOrdersToSapHelper().getMapWithProducts(objetos, tipoObj);
    }

    public void execute(Database.BatchableContext BC, List<sendOrdersToSapHelper.OrderSAP> scope){
        System.debug('El scope >>> ' + JSON.serialize(scope));
        casosEnviadosASAP = scope;

        for(sendOrdersToSapHelper.OrderSAP objToSend : scope){
            contador = contador + 1;

            System.debug('El contador >>>>  '+  contador );

            String body = JSON.serialize(objToSend.MapOrderBody);
            String typeObj = objToSend.typeObj;
            String recordName = objToSend.recordName;
            Order pedido = objToSend.pedido;
            WebServiceSap.SendAlta respuesta = WebServiceSap.sendAltaToSap(body, typeObj, recordName);
            
            // Capturar mensaje de respuesta de SAP
            DateTime dt = DateTime.now();
            String dateTimeStr = dt.format('yyyy/MM/dd hh:mm:ss');

            if(respuesta.response.getStatusCode() == 200 || respuesta.response.getStatusCode() == 201){                   
                if(typeObj == 'Case'){                        
                    Case caso = objToSend.caso;
                    caso.Dan360_EnviadoSAP__c = true;
                    caso.Respuesta_Integracion_SAP__c = 'Codigo de Respuesta : '+ respuesta.response.getStatusCode() + ' - Mensaje : ' + respuesta.response.getBody() +
                    ' - Fecha : ' + dateTimeStr;
                    casesToUpdate.add(caso);
                }
            }else{
                if(typeObj == 'Case'){                        
                    Case caso = objToSend.caso;
                    caso.Respuesta_Integracion_SAP__c = 'Codigo de Respuesta : '+ respuesta.response.getStatusCode() + ' - Mensaje : ' + respuesta.response.getBody() +
                    ' - Fecha : ' + dateTimeStr;
                    casesToUpdate.add(caso);
                }
            }
        }
    } 
    
    public void finish(Database.BatchableContext BC) {

        // for(Case caseToShow : casesToUpdate){
        //     System.debug(caseToShow.CaseNumber);
        //     System.debug(caseToShow.Dan360_EnviadoSAP__c);
        // }
        if(casesToUpdate.size() > 0){
            try {
                update casesToUpdate;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }

            
        }

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //Incluir los correos a los que les va a llegar el reporte.
        //message.toAddresses = new String[] { 'gina.vilchez-diaz@danone.com', 'lhurtado@labsxd.com' };
        message.toAddresses = new String[] {  'lhurtado@labsxd.com','gina.vilchez-diaz@danone.com' };
        message.optOutPolicy = 'FILTER';
        message.subject = 'Se registro un envio doble de caso a SAP: ';
        message.plainTextBody = JSON.serialize(casesToUpdate);
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            if(!Test.isRunningTest()){
                if(contador > 1){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }


        system.debug('Casos enviados a SAP >>> ' + JSON.serialize(casosEnviadosASAP));
    }
}