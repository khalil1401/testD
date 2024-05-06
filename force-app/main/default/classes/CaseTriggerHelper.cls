public class CaseTriggerHelper {
    public static void updateCaseFields(List<String> aCaseIds){
        List<Case> casesToUpdate = new List<Case>();
        Id devolucionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Dan360_Devoluciones').getRecordTypeId();
        for(Case caseToUpdate : [SELECT Id,RecordTypeId, Dan360_ReclamoAprobado__c, Dan360_OrderGetStart__c, Status, Dan360_OrderedDate__c, Dan360_OrderGetEnd__c, CreatedDate 
                                    FROM Case 
                                    WHERE Id IN :aCaseIds]){            
            caseToUpdate.Dan360_OrderGetStart__c = Date.today();
            Date createdDateCase = date.newinstance(caseToUpdate.CreatedDate.year(), caseToUpdate.CreatedDate.month(), caseToUpdate.CreatedDate.day());
            caseToUpdate.Dan360_OrderedDate__c = createdDateCase;
            caseToUpdate.Dan360_OrderGetEnd__c = Date.today();
            caseToUpdate.Status = caseToUpdate.RecordTypeId == devolucionRecordTypeId ? 'Autorizado' : 'Cerrado';
            casesToUpdate.add(caseToUpdate);
        }
        if(!casesToUpdate.isEmpty()){
            Database.update(casesToUpdate);
        }
    }
}