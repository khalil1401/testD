({
    doInit : function(component, event, helper) {

        let staticResourceName = component.get("v.recursoEstatico");
        let staticResourceNameBoton = component.get("v.recursoEstaticoBoton");
        let staticResourceNameCard = component.get("v.recursoEstaticoCard");
        component.set("v.rutaRecursoEstatico", staticResourceName);
        component.set("v.rutaRecursoEstaticoBoton", staticResourceNameBoton);
        component.set("v.rutaImagen", staticResourceNameCard);

        //Seteo altura Mobile
        var device = $A.get("$Browser.formFactor");
        if(device != 'DESKTOP'){
            component.set('v.height', component.get("v.heightMobile"));
        }        
    },
    redireccionar : function(component, event, helper) {
        helper.goTo(component, event, helper);
    }
})