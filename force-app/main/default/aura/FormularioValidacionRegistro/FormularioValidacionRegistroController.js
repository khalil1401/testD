({
    doInit: function(component, event, helper) {
        helper.setIsPaciente(component, event, helper);
        helper.createOptionsAreas(component, event, helper);
    },
    likenClose: function(component, event, helper) {
        helper.close(component, event, helper);
    },
    backToSetDNI: function(component, event, helper) {
        helper.setDNI(component, event, helper);
    },
    validateDNI: function(component, event, helper) {
        helper.getPacientes(component, event, helper);
    },
    checkValidaciones: function(component, event, helper) {
        helper.checkTerminosEIrAFormulario(component, event, helper);
    },
    pressKeyEnterFormDNI: function(component, event, helper) {
        if (event.which == 13){
            event.preventDefault();
            helper.getPacientes(component, event);
        }
    },
    pressKeyEnterFormValidaciones: function(component, event, helper) {
        if (event.which == 13){
            event.preventDefault();
            helper.checkTerminosEIrAFormulario(component, event);
        }
    },
    redirectTo : function (component, event, helper){
		helper.goTo(component, event, helper)
	},
    handleChangeArea : function (component, event, helper){
        helper.changeUrl(component);
    },
})