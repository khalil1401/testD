public class CommunitySurveyController{
    @AuraEnabled public static ValidationWrapper validationResponse {get; set;}
    
    @AuraEnabled
    public static ValidationWrapper surveyDuplicatesValidation(String surveyUrl, String userId){
        System.debug('Variables de entrada: ' + surveyUrl + ' ' + userId);
        validationResponse = new ValidationWrapper();
        if(!String.isBlank(surveyUrl) && userId != 'undefined'){     
            PageReference survey = new PageReference(surveyUrl);
            String surveyId = survey.getParameters().get('id');
            
            List<User> ct = [
                SELECT Id, contactId
                FROM User
                WHERE Id = :userId
                LIMIT 1
            ];
        
            if(ct.size() == 1 && ct[0].contactId != null){
                List<SurveyTaker__c> surveyTaker = [
                    SELECT Id, Contact__c, Survey__c,Taken__c
                    FROM SurveyTaker__c
                    WHERE (Contact__c = :ct[0].contactId 
                           AND Survey__c = :surveyId 
                           AND Taken__c = 'true')
                    LIMIT 1
                ];
                
                if(surveyTaker.size() == 1){
                    validationResponse.status = false;
                    validationResponse.messageResponse = getMessageText('Surveyforce_comunidad_contestada');	
                    return validationResponse;
                }   

                survey.getParameters().put('cId', ct[0].contactId);
                validationResponse.status = true;
                validationResponse.messageResponse = survey.getUrl();
                return validationResponse;
            }
        }
        validationResponse.status = false;
        validationResponse.messageResponse = getMessageText('Validacion_de_registro');
        
        return validationResponse; 
    }
    
    @AuraEnabled
    public static String getMessageText(String templateDeveloperName){
        
        List<EmailTemplate> emailTemplate = [
            SELECT Id, Body, HtmlValue
            FROM EmailTemplate 
            WHERE DeveloperName = :templateDeveloperName
			LIMIT 1
        ];
        if(!emailTemplate.isEmpty()){
            return emailTemplate[0].HtmlValue;
        } 
        return null;
    }
    
    @AuraEnabled
    public static ValidationWrapper getOnlyLoggingValidation(String userId){
        validationResponse = new ValidationWrapper();
        if(userId == 'undefined'){
            validationResponse.messageResponse = getMessageText('Validacion_de_registro');
            return validationResponse;
        }
        else{
            validationResponse.status = true;
            return validationResponse;
        }
    }
      
    public class ValidationWrapper{
        @AuraEnabled public Boolean status {get;set;}
        @AuraEnabled public String messageResponse {get; set;}
        public ValidationWrapper(){
            status = false;
            messageResponse = '';
        }
    }
}