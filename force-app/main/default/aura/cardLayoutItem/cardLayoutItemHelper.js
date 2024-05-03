({
    goToSeccion : function(component, event) {

        let page = component.get("v.urlPage");
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('/s'));

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": baseURL + '/s'+ page
        });
        urlEvent.fire();

    }
})