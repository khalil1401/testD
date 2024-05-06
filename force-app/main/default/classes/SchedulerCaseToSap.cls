global class SchedulerCaseToSap implements Schedulable{
    global void execute(SchedulableContext sc){
        String typeObj = 'Case';
        List<String> statusToQuery = new List<String>{'Autorizado', 'Cerrado'};
        //List<String> casosQueryTest = new List<String>{'5004C00000BQm3SQAT','5004C00000BQvfXQAT', '5004C00000BQvfcQAD'};
        Map<String,Case> caseMap = new Map<String,Case>();
        for(Case reclamo : [
            SELECT Id, CaseNumber, Dan360_MotivoDeReclamo__c, RecordType.Name, Dan360_Pedido__c, Dan360_EnviadoSAP__c,
            Description, Dan360_RequiredDeliveryDate__c, Dan360_OrderedDate__c, Dan360_OrderGetStart__c,Dan360_OrderGetEnd__c,
            Dan360_Remito__r.Dan360_Delivery__c, Dan360_Factura__r.Dan360_Id_Externo__c
            FROM Case 
            WHERE Status IN :statusToQuery AND  Dan360_EnviadoSAP__c = False
                //iD IN :casosQueryTest AND Dan360_EnviadoSAP__c = False AND Status IN :statusToQuery
        ]){
            System.debug('Reclamo '+ reclamo);
            if(!caseMap.containsKey(reclamo.Dan360_Pedido__c)){
                caseMap.put(reclamo.Id, reclamo);
            }
        }

        if(caseMap.size() > 0){
            for(String key : caseMap.keySet()){
                System.debug('CASO ID: ' + key);
                Case caso = caseMap.get(key);
                System.debug('Caso Numero: ' + caso.CaseNumber);
            }
            try {
                BatchSendOrdersToSap caseBatch = new BatchSendOrdersToSap(caseMap,typeObj);
                ID batchId = Database.executeBatch(caseBatch, 10);
            } catch (Exception e) {
                System.debug('Error al encolar el batch: ' + e.getMessage());
            }
        }
    }
}