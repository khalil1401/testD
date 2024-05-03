({
    close: function(component, event) {
        var titulo = component.get("v.tituloError");
        if (titulo === 'DNI duplicado') {
            component.set("v.paginaActual", "1");
        }
        if (titulo === 'Error Contacto') {
            component.set("v.revisarDatos", false);
            this.gotoHome(component, event);
        }
        if (titulo === 'Error Tratamiento') {
            component.set("v.revisarDatos", false);
            this.gotoHome(component, event);
        }
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