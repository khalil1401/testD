({
    goToLogin : function(component, event) {
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('/s'));
  
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": baseURL + '/s/login/'
        });
        urlEvent.fire();
    }
})