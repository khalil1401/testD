trigger CaseTrigger on Case (before insert, before update, after insert, after update, before delete, after delete, after undelete) {

    if (Trigger.isBefore && Trigger.isInsert) {
        List<Case> casesAssignEntitlements = new List<Case>();
        for (Case aCase : Trigger.new) {
            if (aCase.Status != 'Cerrado' && aCase.AccountId != null) {
                casesAssignEntitlements.add(aCase);
            }
        }
        if (!casesAssignEntitlements.isEmpty()) {
            SLAUtils.assignEntitlements(casesAssignEntitlements);
        }
    } 
    else if (Trigger.isBefore && Trigger.isUpdate) {
        List<Case> caseToAssignEntitlement = new List<Case>();

        for (Case aCase : Trigger.new) {
            Case oldCase = Trigger.oldMap.get(aCase.Id);
            Boolean typeChanged = aCase.Type != oldCase.Type;
            if (typeChanged) {
                caseToAssignEntitlement.add(aCase);
            }
            // Caso cerrado por
            Boolean StatusChanged = aCase.Status != oldCase.Status;
            if (StatusChanged && aCase.Status == 'Cerrado') {
                aCase.CerradoPor__c = aCase.LastModifiedById;
            }
            Boolean ownerChanged = aCase.OwnerId != oldCase.OwnerId;
            Id caseRecordType = XappiaHelper.getRecordType('Case', 'Reclamo').Id;
            
            if((((StatusChanged && aCase.Status == 'Trabajando') || ownerChanged) &&
                aCase.RecordTypeId == caseRecordType &&
                aCase.Subtipo__c =='Calidad'))
            {
                CaseHelper.validateFormularioDeCalidad(aCase);
            }
        }
        if (!caseToAssignEntitlement.isEmpty()) {
            SLAUtils.assignEntitlements(caseToAssignEntitlement);
        }

    } 
    else if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUndelete)) { 
        List<Case> casesToCountInAccount = new List<Case>();
        for (Case aCase : Trigger.new) {
            if(aCase.AccountId != null && CaseHelper.isCaseToCountInAccount(aCase)) {
                casesToCountInAccount.add(aCase);
            }
        }
        if(!casesToCountInAccount.isEmpty()) CaseHelper.countCasesInAccount(casesToCountInAccount); 
    } 
    else if (Trigger.isAfter && Trigger.isUpdate) {     
        List<Case> casesToCloseMilestones = new List<Case>();

        List<Case> casesToCountInAccount = new List<Case>();

        for (Case aCase : Trigger.new) {
            Case oldCase = Trigger.oldMap.get(aCase.Id);
            Boolean StatusChanged = aCase.Status != oldCase.Status;

            if (StatusChanged && aCase.Status == 'Cerrado') {

                casesToCloseMilestones.add(oldCase);
            }
            Boolean hasAccount = aCase.AccountId != null || oldCase.AccountId != null;
            if(hasAccount && CaseHelper.isCaseToCountInAccount(aCase, oldCase)) {
                casesToCountInAccount.add(CaseHelper.getCaseWithAccount(aCase, oldCase));
            }
        }

        if (!casesToCloseMilestones.isEmpty()) {
            SLAUtils.closeMilestones(casesToCloseMilestones);
        }

        if(!casesToCountInAccount.isEmpty()) CaseHelper.countCasesInAccount(casesToCountInAccount); 
    }
    else if (Trigger.isAfter && Trigger.isDelete) { 
        List<Case> casesToCountInAccount = new List<Case>();
        for (Case aCase : Trigger.old) {
            if(aCase.AccountId != null && CaseHelper.isCaseToCountInAccountDelete(aCase)) {
                casesToCountInAccount.add(aCase);
            }
        }
        if(!casesToCountInAccount.isEmpty()) CaseHelper.countCasesInAccount(casesToCountInAccount); 
    } 
}