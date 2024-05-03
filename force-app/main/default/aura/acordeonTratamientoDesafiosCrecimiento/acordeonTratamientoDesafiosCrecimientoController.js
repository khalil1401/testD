({
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },

    redirect: function (cmp, event) {        
        let apiName = event.target.dataset.apiname;
        if(apiName){
            let navService = cmp.find("navService");
            let pageReference = {
                type: 'comm__namedPage',
                attributes: {
                    name: apiName
                }
            };
            navService.navigate(pageReference);
        }
    }
})