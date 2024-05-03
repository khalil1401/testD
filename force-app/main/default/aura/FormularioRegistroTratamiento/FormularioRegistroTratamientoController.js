({
    doInit: function(component, event, helper) {
        helper.doInit(component, event);
    },
    enviar : function(component, event, helper) {
        helper.crearDatos(component, event);
    },
    anterior : function(component, event, helper) {
        helper.anteriorForm(component, event);
    },
    handleOptionDiagnosticoSelected: function(component, event, helper) {
        helper.setDiagnostico(component, event);
    },
    handleOptionAlimentacionSelected: function(component, event, helper) {
        helper.setAlimentacion(component, event);
    },
    handleOptionScreeningSelected: function(component, event, helper) {
        helper.setScreening(component, event);
    },
    changeNoTengoObraSocial: function (component, event, helper) {
        helper.deleteObraSocial(component, event);
    },
    handleFileChange: function (component, event, helper) {
        helper.setArchivo(component, event);
    },
    hideSpinner : function (component, event) {
        var msg = event.getParam("message");
        component.set("v.showSpinner", msg);
    },
})