({
    sendCase : function(component, event, helper) {
        let recordId = component.get('v.recordId');
        let action = component.get('c.sendCaseToSap');
        action.setParams({
            recordId
        });

        $A.enqueueAction(action);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Enviado!",
            "message": "El Caso ha sido enviado a SAP",
            "type" : 'success'
        });
        toastEvent.fire();
    }
})