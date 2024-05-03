({
    goTo : function(component, event, helper) {
        let testimonio = event.target.dataset.id;
        let navService = component.find("navService");
        let pageReference = {
            type: 'comm__namedPage',
            attributes: {
               name: 'Testimonios_Stroke__c'
            },
            state: {
                testimonio : testimonio
            }
        };
        navService.navigate(pageReference);
    }
})