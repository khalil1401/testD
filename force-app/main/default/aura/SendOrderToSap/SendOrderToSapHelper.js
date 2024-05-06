({
    sendOrder : function(component, recordId) {
        let action = component.get('c.sendOrderToSap');
        action.setParams({
            recordId
        });

        $A.enqueueAction(action);
    },

    sendCase : function(component, recordId) {
        console.log(recordId);
        let action = component.get('c.sendCaseToSap');
        action.setParams({
            recordId
        });

        $A.enqueueAction(action);
    }
})