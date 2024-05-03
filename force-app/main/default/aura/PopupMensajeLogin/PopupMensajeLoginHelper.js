({
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

    },

    setDevice : function(component, event){

      var device = $A.get("$Browser.formFactor");
      if(device === 'DESKTOP'){
        component.set('v.isDesktop', true);
              var modalMensaje = component.find('modalMensaje');
              $A.util.addClass(modalMensaje, 'slds-modal__container modalDesktop');
      }

    }

})