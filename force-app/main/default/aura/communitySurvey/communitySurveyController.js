({
    doInit :function(component, event, helper) {
        console.log('Entra al survey y templateName es: ' , component.get('v.templateDeveloperName'));
        helper.getTermAndCondsBody(component, event);
        helper.validationDoInit(component, event);
    },
    handleAnswerTermCond :function(component, event, helper) {
        var eventValue = event.getParam("answer");
        if(eventValue){
            component.set('v.termCond', false);
            component.set('v.openSurvey', true);
        }
        else{
            component.set('v.termCond', false);
        }        
    }, 
    handleSurveyClose :function(component, event, helper) {
        component.set('v.isNew', true);
        component.set('v.openSurvey', false);
    }
})