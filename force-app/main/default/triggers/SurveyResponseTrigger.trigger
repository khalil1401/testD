trigger SurveyResponseTrigger on SurveyQuestionResponse__c (before insert) {
	if(Trigger.isBefore && Trigger.isInsert)
    {
        Map<Id, SurveyQuestionResponse__c> takersResponse = new Map<Id, SurveyQuestionResponse__c>();
        for(SurveyQuestionResponse__c response : Trigger.new)
        {
            takersResponse.put(response.SurveyTaker__c, response);
        }
        System.debug(takersResponse);
        List<SurveyTaker__c> takers = [SELECT Id, Case__c FROM SurveyTaker__c WHERE Id IN :takersResponse.keySet()];
        Map<Id,Id> CaseTaker = new Map<Id,Id>();
        for(SurveyTaker__c takerUnit : takers)
        {
            CaseTaker.put(takerUnit.Case__c, takerUnit.Id);
        }
        System.debug(CaseTaker);
        List<Case> cases = [SELECT Id, CerradoPor__c FROM Case WHERE Id IN :CaseTaker.keySet()];
        for(Case casoUnit : cases)
        {
            
            takersResponse.get(CaseTaker.get(casoUnit.Id)).CasoCerradoPor__c = casoUnit.CerradoPor__c;
        }
    }
}