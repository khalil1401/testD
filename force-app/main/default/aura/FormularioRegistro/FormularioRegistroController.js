({
    doInit: function(component, event, helper) {
        helper.doInit(component, event);
    },
    handleOptionSexoSelected: function(component, event, helper) {
        helper.setSexo(component, event);
    },
    handleOptionTipoTelSelected: function(component, event, helper) {
        helper.setTipoDeTelefono(component, event);
    },
    handleOptionProduct: function(component, event, helper) {
        helper.setProduct(component, event);
    },
    changeNoTengoDNI: function(component, event, helper) {
        helper.setNoTengoDNI(component, event);
    },
    validarEdad: function(component, event, helper) {
        helper.setMenores(component, event);
    },
    siguiente: function(component, event, helper) {
        helper.siguienteForm(component, event);
    },
    anterior: function(component, event, helper) {
        helper.gotoLogin(component, event);
    },
    hideSpinner : function (component, event) {
        var msg = event.getParam("message");
        component.set("v.showSpinner", msg);
    }
})