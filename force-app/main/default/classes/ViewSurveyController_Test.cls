@istest
private class ViewSurveyController_Test{
    //------------------------------------------------------------------------------//
    //------------------------------------------------------------------------------//
    private static Testmethod void testViewSurveyController() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc); 
        vsc.init();
        System.assert(vsc.allQuestionsSize == 4);
        System.assert(tu.surveyId != null);


        vsc.submitResults();
        for (SFQuestion q : vsc.allQuestions)
        {
            q.selectedOption = String.valueof(2);
            q.choices = String.valueof(2);
            q.selectedOptions = new List<String>();
            q.selectedOptions.add(String.valueof(2));
            vsc.submitResults();
        }
        System.assertEquals(true, vsc.thankYouRendered);


        //test something
    }


    private static Testmethod void testUpdateSurveyName() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyName = 'new name';
        system.assert(vsc.updateSurveyName() == null);

    }


    private static Testmethod void testupdateSurveyThankYouAndLink() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyThankYouText = 'new stuff';
        vsc.surveyThankYouURL = 'more new stff';
        system.assert(vsc.updateSurveyThankYouAndLink()==null);
    }
    @isTest
    private static void testGetResponses(){
        
        Survey__c s = new Survey__c();
        insert s;
        
        Survey_Question__c sq = new Survey_Question__c(Survey__c=s.Id, OrderNumber__c=1, Question__c='asd?');
        insert sq;
        
        SurveyTaker__c st = new SurveyTaker__c(Survey__c=s.id);
        insert st;
        
        SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c (Survey_Question__c=sq.id, SurveyTaker__c = st.id);
        insert sqr;
        
        system.debug(sqr);
        
        Contact cnt = new Contact(LastName='Test');
        insert cnt;
        ApexPages.StandardController std = new ApexPages.StandardController(cnt);
        ViewSurveyController vsc = new ViewSurveyController(std);
        
        Test.startTest();
        	List<String> responses = vsc.getResponses();
        Test.stopTest();
        
        system.assert(responses.size()>=1);
    }


}