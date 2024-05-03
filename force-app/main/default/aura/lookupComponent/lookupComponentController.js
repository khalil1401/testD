({
    doInit: function(component, event, helper) {
        helper.doInit(component, event);
    },
    changeInput: function(component, event, helper) {
        helper.filtrar(component, event);
    },
    seleccionarItem: function(component, event, helper) {
        helper.setSeleccionado(component, event);
    },
    handleIdMunicipioChange: function(component, event, helper) {
        helper.reloadLocalidades(component, event);
    },
})