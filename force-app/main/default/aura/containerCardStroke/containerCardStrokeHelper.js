({
    goTo : function(component, event, helper) {
        let apiName = component.get("v.apiName");

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