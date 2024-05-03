({
    redirectTo : function(component, event, helper) {
        let apiName = event.currentTarget.dataset.id;
        let navService = component.find("navService");
        let pageReference = {
           type: 'comm__namedPage',
           attributes: {
               name: apiName
           }
        };
        navService.navigate(pageReference);
    }

})