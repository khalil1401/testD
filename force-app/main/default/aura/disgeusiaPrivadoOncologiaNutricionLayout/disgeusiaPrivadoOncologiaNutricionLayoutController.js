({
    clickButton : function(component, event, helper) {
        let data = event.getParam('value');
        let typeRedirect = data.typeRedirect;
        let namePage = data.buttonId;

        let navService = component.find("navService");
        let pageReference = {
           type: typeRedirect,
           attributes: {
               name: namePage
           }
        };
        navService.navigate(pageReference);
    }
})