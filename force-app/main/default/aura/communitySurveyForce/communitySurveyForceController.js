({        
    close : function(component, event, helper) {
        var answerTermCond = component.getEvent('surveyClose');
        answerTermCond.setParams({ 'answer':false});
        answerTermCond.fire();
        component.find("overlayLib").notifyClose();
    }
})