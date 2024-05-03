({
    clickButton : function(component, event, helper) {
        let data = event.getParam('value');
        let typeRedirect = data.typeRedirect;
        let namePage = data.buttonId;
        
        let navService = component.find("navService");
        let pageReference = null;
        if(typeRedirect != 'standard__webPage'){
            pageReference = {
               type: typeRedirect,
               attributes: {
                   name: namePage
               }
            };
        }
        else{
            pageReference = {
                type: typeRedirect, 
                attributes: { 
                    url: namePage
                } 
            };
        }
        navService.navigate(pageReference);
    }
})