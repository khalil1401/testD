({
    redireccionar : function(component, event, helper) {
        helper.goTo(component, event, helper);
    },
    downloadPDF : function(component, event, helper) {
        let navService = component.find("navService");
        let pageReference = {
           type: 'standard__webPage',
           attributes: {
            url: 'https://www.clickdimensions.com/links/TestPDFfile.pdf'
            }
        };
        navService.navigate(pageReference);
    },
})