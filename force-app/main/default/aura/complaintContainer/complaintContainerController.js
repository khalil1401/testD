({
    closeQA: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire()
    },

    doInit: function (component, event, helper) {
        var action = component.get('c.getObjApiName');
        action.setParams({
            "objectId": component.get('v.recordId')
        });

        action.setCallback(this, function (a) {
            var state = a.getState(); // get the response state
            if (state == 'SUCCESS') {
                component.set('v.objApiName', a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})