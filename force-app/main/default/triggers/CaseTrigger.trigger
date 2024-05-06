trigger CaseTrigger on Case (after update) {
	if(Trigger.isAfter){
        if(Trigger.isUpdate){
            List<String> casesToSendSap = new List<String>();
            List<String> casesIds = new List<String>();
            for(Case aCase : Trigger.new){
                if(aCase.Dan360_ReclamoAprobado__c == true && Trigger.oldMap.get(aCase.Id).Dan360_ReclamoAprobado__c == false){
                    casesIds.add(aCase.id);
                }
            }
            for(ProcessInstance instacia : [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId IN :casesIds AND Status = 'Approved']){
                casesToSendSap.add(instacia.TargetObjectId);
            }
            if(!casesToSendSap.isEmpty()){
                SendCaseToSap.sendCaseToSapFlow(casesToSendSap);
                CaseTriggerHelper.updateCaseFields(casesToSendSap);
            }

        }
    }
}