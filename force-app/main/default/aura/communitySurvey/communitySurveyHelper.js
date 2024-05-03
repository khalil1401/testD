({
    validationDoInit : function(component, event){
        var userId = $A.get( "$SObjectType.CurrentUser.Id" );
        var surveyUrl = component.get('v.surveyUrl');
        var cmpEvent = component.getEvent("initialValidationEvent"); 
        
        var action = component.get('c.surveyDuplicatesValidation');
        action.setParams({ surveyUrl:surveyUrl,
                          userId:userId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var returnValues = response.getReturnValue();
                if(userId === undefined){
                    cmpEvent.setParams({
                        "isAvailable" : false,
                        "unAvailableMessage": returnValues.messageResponse });
                    cmpEvent.fire(); 
                }
                else{
                    if(response.getReturnValue().status){
                        cmpEvent.setParams({
                            "isAvailable" : returnValues.status,
                            "unAvailableMessage": returnValues.messageResponse });   
                        cmpEvent.fire(); 
                        
                        component.set('v.surveyUrl', response.getReturnValue().messageResponse);
						component.set('v.isLoading',false);
                        component.set('v.termCond', true);
                    }
                    else{
                        cmpEvent.setParams({
                            "isAvailable" : returnValues.status,
                            "unAvailableMessage": returnValues.messageResponse });   
                        cmpEvent.fire(); 
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getTermAndCondsBody : function(component, event){
        console.log('Entro al helper');
        var templateDeveloperName = component.get('v.templateDeveloperName');
        var action = component.get('c.getMessageText');
        action.setParams({ templateDeveloperName: templateDeveloperName });
        action.setCallback(this, function(response){
        	var state = response.getState();
            console.log('Response: ' , state);
            if(state === 'SUCCESS'){
                component.set('v.termsAndCondsBody', response.getReturnValue());
            }
        });  
        $A.enqueueAction(action);
    }
})