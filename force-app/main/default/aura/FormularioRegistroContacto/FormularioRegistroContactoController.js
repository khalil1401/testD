({
    doInit: function(component, event, helper) {
        helper.doInit(component, event);
    },
    siguiente : function(component, event, helper) {
        helper.siguienteForm(component, event);
    },
    anterior : function(component, event, helper) {
        helper.anteriorForm(component, event);
    },
    handleOptionRelacionSelected: function(component, event, helper) {
        helper.setRelacion(component, event);
    },
    handleOptionRelacionSelectedContact2: function(component, event, helper) {
        helper.setRelacionContact2(component, event);
    },
    agregarContacto: function(component, event, helper) {
        helper.agregarSegundoContacto(component, event);
    },
    eliminarContacto: function(component, event, helper) {
        helper.eliminarSegundoContacto(component, event);
    }
})