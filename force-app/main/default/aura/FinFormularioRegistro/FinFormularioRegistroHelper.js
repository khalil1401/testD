({
    doInit: function(component, event) {
        let area = component.get("v.area");
        if(area) {            
            let urlString = window.location.href;
            var url = new URL(urlString);
            url.searchParams.set('area', area + '-confirmacion-registro');
            window.history.pushState({}, '', url.toString());
        }
    },

    close: function(component, event) {
        this.gotoHome(component, event);
    },

    gotoHome : function (component, event) {
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('/s'));
  
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": baseURL + '/s/'
        });
        urlEvent.fire();
    }

})