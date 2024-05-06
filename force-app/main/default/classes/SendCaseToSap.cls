public with sharing class SendCaseToSap {
    @InvocableMethod(label='Send Case To SAP' description='Send case to sap')
    public static void sendCaseToSapFlow(List<string> recordId){
        System.debug('Entro');
        String caseId = recordId[0];
        Case reclamo = [
            SELECT Id, CaseNumber, Dan360_MotivoDeReclamo__c, RecordType.Name, Dan360_Pedido__c,Dan360_EnviadoSAP__c, Description, 
            Dan360_RequiredDeliveryDate__c, Dan360_OrderedDate__c, Dan360_OrderGetStart__c,Dan360_OrderGetEnd__c,
            Dan360_Remito__r.Dan360_Delivery__c, Dan360_Factura__r.Dan360_Id_Externo__c, CreatedDate
            FROM Case 
            WHERE iD = :caseId
        ];

        Map<String,Case> caseMap = new Map<String,Case>();
        caseMap.put(reclamo.Id, reclamo);
        String typeObj = 'Case';
        BatchSendOrdersToSap caseBatch = new BatchSendOrdersToSap(caseMap, typeObj);
        ID batchId = Database.executeBatch(caseBatch); 
    }
}