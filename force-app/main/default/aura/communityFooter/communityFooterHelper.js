({    
	goToTerminos : function(component,event,helper){
		let apiName = component.get("v.apiNamePageTerminos");
        let navService = component.find("navService");
        let pageReference = {
           type: 'comm__namedPage',
           attributes: {
               name: apiName
           }
        };
        navService.navigate(pageReference);
    },
	goToPoliticas : function(component,event,helper){
		let apiName = component.get("v.apiNamePagePoliticas");
        let navService = component.find("navService");
        let pageReference = {
           type: 'comm__namedPage',
           attributes: {
               name: apiName
           }
        };
        navService.navigate(pageReference);
    },
})