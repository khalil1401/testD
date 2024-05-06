({
    doInit : function(component, event, helper) {
        // Find the component whose aura:id is “flowData”
		var flow = component.find("flowData");
        var inputVariables = [
            {
                name : 'UsuarioId',
                type : 'String',
                value : $A.get("$SObjectType.CurrentUser.Id")
            }
            ];
		// In that component, start your flow. Reference the flow’s Unique Name.
		flow.startFlow("CrearPedioAsignarCustomerSalesArea",inputVariables);
    }
})