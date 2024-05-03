({
    goToFAQ : function(component, event, helper) {

        let urlfaq = component.get("v.urlFAQ");
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('/s'));
  
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": baseURL + '/s' + urlfaq
        });
        urlEvent.fire();

    },
    goToRecomendacionesDeUso : function(component, event, helper) {

        let urlfaq = component.get("v.urlRecomendaciones");
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('/s'));
  
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": baseURL + '/s' + urlfaq
        });
        urlEvent.fire();

    },
    setDevice : function(component, event){

      var device = $A.get("$Browser.formFactor");
  if(device === 'DESKTOP'){
    component.set('v.isDesktop', true);
  }
      else{
    component.set('v.isDesktop', false);
      }

   },
})