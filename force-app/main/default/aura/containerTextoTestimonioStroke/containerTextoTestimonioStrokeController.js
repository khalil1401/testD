({
    doInit : function(component, event, helper) {

        let staticResourceName = component.get("v.recursoEstatico");
        component.set("v.rutaImg", staticResourceName);

    }
})