({
    doInit : function(component, event, helper) {
        let recursoEstaticoImagenPrincipal;
        let device = $A.get("$Browser.formFactor");

        if(device === 'DESKTOP'){
            recursoEstaticoImagenPrincipal = component.get("v.recursoEstaticoImagenPrincipal");
            component.set("v.rutaImagenPrincipal", recursoEstaticoImagenPrincipal);
        }
        else{
            recursoEstaticoImagenPrincipal = component.get("v.recursoEstaticoImagenPrincipalMobile");
            component.set("v.rutaImagenPrincipal", recursoEstaticoImagenPrincipal);
        }
    },

    redireccionar : function(component, event, helper){
        helper.goTo(component, event, helper);
    }
})