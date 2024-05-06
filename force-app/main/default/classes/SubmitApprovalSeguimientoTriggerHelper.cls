public with sharing class SubmitApprovalSeguimientoTriggerHelper {
    public  static void SubmitApprovalProcess(List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos) {
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (VisMed_Contacto_Cuenta_Usuario__c seg : seguimientos) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setObjectId(seg.Id);            
            // Submit on behalf of a specific submitter
            req.setSubmitterId(seg.Owner.Id);             
            // Submit the record to specific process and skip the criteria evaluation
            req.setProcessDefinitionNameOrId('Proceso_de_aprobacion_de_Seguimientos');
            requests.add(req);
        }
        // Submit the approval requests
        Approval.ProcessResult[] result = Approval.process(requests);
        System.debug('Result proceso aprobacion altas: ' +result);
    }
}