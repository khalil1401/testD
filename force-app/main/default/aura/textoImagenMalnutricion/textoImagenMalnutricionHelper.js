({
    goTo : function(component, event, helper) {
        let apiName = component.get("v.apiName");
        let navService = component.find("navService");
        if(apiName == 'envejecimiento'){
            let pageReference = {
                type: 'comm__namedPage',
                attributes: {
                    name: 'vida_saludable__c'
                },
                state: {
                    seccion : 'envejecimiento'
                }
            };
            navService.navigate(pageReference);
        }
        else if(apiName == 'comidas-nutritivas'){
            let pageReference = {
                type: 'comm__namedPage',
                attributes: {
                    name: 'recomendaciones_nutricionales__c'
                },
                state: {
                    seccion : 'comidas-nutritivas'
                }
            };
            navService.navigate(pageReference);
        }
        else if(apiName == 'suplementos'){
            let pageReference = {
                type: 'comm__namedPage',
                attributes: {
                    name: 'recomendaciones_nutricionales__c'
                },
                state: {
                    seccion : 'suplementos'
                }
            };
            navService.navigate(pageReference);
        }
        else{
            let pageReference = {
                type: 'comm__namedPage',
                attributes: {
                    name: apiName
                }
            };
            navService.navigate(pageReference);
        }
    },
    goToRE : function(component, event, helper) {
        let apiName = "";
        let navService = component.find("navService");
        let pageReference = {
           type: 'comm__namedPage',
           attributes: {
               name: apiName
           }
        };
        navService.navigate(pageReference);
    },
    goToSN : function(component, event, helper) {
        let navService = component.find("navService");
        let pageReference = {
           type: 'comm__namedPage',
           attributes: {
               name: 'recomendaciones_nutricionales__c'
           },
           state: {
               seccion : 'suplementos'
           }
        };
        navService.navigate(pageReference);
    }
})