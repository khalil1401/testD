({
    doInit: function(component, event, helper) {
      helper.setDevice(component, event);
    },
    goTo : function(component, event, helper) {
      let button = event.target.dataset.id;
      button == "RdU" ? helper.goToRecomendacionesDeUso(component, event, helper) : helper.goToFAQ(component, event, helper);
    }
})