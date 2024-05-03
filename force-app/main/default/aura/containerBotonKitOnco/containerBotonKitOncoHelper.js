({
    goToRegister : function(component, event) {
        let area = component.get("v.area");
        if(area){
            let navService = component.find("navService");
            let pageReference = {
                "type":'comm__namedPage',
                "attributes": {
                    "name": 'registro_y_solicitud__c'
                },
                "state": {
                    "area": area
                }
            };
            navService.navigate(pageReference);
        }
    }
})