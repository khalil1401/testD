({
    doInit: function(component, event, helper) {
        helper.doInit(component, event);
    },
    handleOptionProvinciaSelected: function(component, event, helper) {
        helper.cargarMunicipios(component, event);
    },
    handleOptionMunicipioSelected: function(component, event, helper) {
        helper.cargarLocalidades(component, event);
    },
    siguiente : function(component, event, helper) {
        helper.siguienteForm(component, event);
    },
    anterior : function(component, event, helper) {
        helper.anteriorForm(component, event);
    },
})