({
    
	answer : function(component, event, helper) {
        var answerLabel = component.find(event.getSource().getLocalId()).get('v.value');
        var answerTermCond = component.getEvent('answerTermCond');
        if(answerLabel === '1'){
            answerTermCond.setParams({ 'answer':true});
            answerTermCond.fire();
        }
        else{
            answerTermCond.setParams({ 'answer':false});
            answerTermCond.fire();
            component.find("overlayLib").notifyClose();
        }
        
    }
})