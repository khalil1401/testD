@isTest(SeeAllData=true)
private class CommunitySurveyControllerTest {
    @isTest 
    static void whenTheContactHasAlreadyAnswerTheSurveyAndTheUserClicksStartButtonItMustReturnFalseAndANullURL(){
        surveyTaker1 = Build.aSurveyTaker()
            .withContact(user.ContactId)
            .withSurvey(survey.Id)
            .withTaken('true')
            .build();
        insert surveyTaker1;
        
        CommunitySurveyController.ValidationWrapper result = new CommunitySurveyController.ValidationWrapper();
        
        Test.startTest();
        result = CommunitySurveyController.surveyDuplicatesValidation(surveyUrl, String.valueOf(user.Id)); 
        Test.stopTest();

        System.assertEquals(false, result.status);
    }
    
    @isTest
    static void whenTheContactHasNotAnswerTheSurveyAndTheUserClicksStartButtonItMustReturnTrueAndTheUrlFilledWithContactAndSurveyId(){  
        
        CommunitySurveyController.ValidationWrapper result = new CommunitySurveyController.ValidationWrapper();
        Test.startTest();
        result = CommunitySurveyController.surveyDuplicatesValidation(surveyUrl, String.valueOf(user.Id));
        Test.stopTest();
        
        PageReference surveyRecord = new PageReference(result.messageResponse);
        System.assert(result.status);
        System.assertEquals(user.ContactId, surveyRecord.getParameters().get('cId'));
        System.assertEquals(survey.Id, surveyRecord.getParameters().get('Id'));
    }
    
    @isTest
    static void ifTheUserClicksStartButtonAndUrlValueIsEmptyItMustReturnFalseAndANullURL(){  
        surveyUrl = '';
        CommunitySurveyController.ValidationWrapper result = new CommunitySurveyController.ValidationWrapper();
        
        Test.startTest();
        result = CommunitySurveyController.surveyDuplicatesValidation(surveyUrl, String.valueOf(user.Id));
        Test.stopTest();
        
        System.assertEquals(false, result.status);
    }
    
    @isTest
    static void ifTheUserClicksStartButtonAndIdValueIsEmptyItMustReturnFalseAndANullURL(){  
        String userId = 'undefined';
        
        CommunitySurveyController.ValidationWrapper result = new CommunitySurveyController.ValidationWrapper();
        
        Test.startTest();
        result = CommunitySurveyController.surveyDuplicatesValidation(surveyUrl, userId);
        Test.stopTest();
        
        System.assertEquals(false, result.status);
    }
    
    @isTest
    static void whenThetemplateDeveloperNameIsNotEmptyReturnedTheHTMLValueOfTheTemplate(){
        Test.startTest();
        String message = CommunitySurveyController.getMessageText('For_testing');
        Test.stopTest();
        System.assertEquals(null, message);        
    }
    
    @isTest
    static void whenAUserInACommunityTryToDoSomethingThatRequiresOnlyBeLoggedAndItisNotLoggedItMustReturnStatusFalseAndMessageAlert(){
        String userId = 'undefined';
        CommunitySurveyController.ValidationWrapper reponseValues = new CommunitySurveyController.ValidationWrapper();
        
        Test.startTest();
        reponseValues = CommunitySurveyController.getOnlyLoggingValidation(userId);
        Test.stopTest();
        
        System.assertEquals(reponseValues.status, false);
        
    }
    
    @isTest
    static void whenAUserInACommunityTryToDoSomethingThatRequiresOnlyBeLoogedAndItisLoggedTheValueReturnMustBeTrueAsStatusAndMessageMustBeEmpty(){
        String userId = 'userId';
        CommunitySurveyController.ValidationWrapper reponseValues = new CommunitySurveyController.ValidationWrapper();
        
        Test.startTest();
        reponseValues = CommunitySurveyController.getOnlyLoggingValidation(userId);
        Test.stopTest();
        
        System.assertEquals(reponseValues.status, true);   
    }
    
    @isTest
    static void whenThetemplateDeveloperNameIsEmptyTheValueReturnedMustBeNull(){
        Test.startTest();
        String message = CommunitySurveyController.getMessageText('');
        Test.stopTest();
        System.assertEquals(null, message);
    }
    
    static Survey__c survey;
    static SurveyTaker__c surveyTaker1;
    static User user;
    static String surveyUrl;
    
    static{    
        user = [SELECT Id, contactId 
                FROM USER 
                WHERE contactId != null 
                LIMIT 1];
        
        survey = Build.aSurvey()
            .withName('SurveyForce1')
            .withSubmitResponse('Nothig')
            .build();
        insert survey;
        
        surveyUrl = 'https://danonedev--dev--c.cs13.visual.force.com/apex/takesurvey?id=' + survey.Id + '&cId=none&caId=none';
    }    
}