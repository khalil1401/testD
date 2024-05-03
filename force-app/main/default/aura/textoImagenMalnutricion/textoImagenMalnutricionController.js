({
    redireccionar : function(component, event, helper) {
        helper.goTo(component, event, helper);
    },
    redireccionarRecetasEnriquecidas : function(component, event, helper) {
        helper.goToRE(component, event, helper);
    },
    redireccionarSuplementosNutricionales : function(component, event, helper) {
        helper.goToSN(component, event, helper);
    }
})