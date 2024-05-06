({
    duplicateOrderHelper: function (component, actionName, value) {
        let action = component.get(actionName);
        let newOrder = null;
        let navEvt = null;

        action.setParams({
            originalOrderId: value.originalOrderId,
            order: value.newOrder
        });
        action.setCallback(this, function (response) {
            let oResponse = response.getReturnValue();

            if (oResponse.state === 'SUCCESS') {
                newOrder = oResponse.data;
                navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": newOrder,
                    "slideDevName": "related"
                });
                component.find('notifLib').showToast({
                    'title': '¡EXITÓSO!',
                    'message': oResponse.message,
                    'variant': 'success',
                    'mode': 'dismissable'
                });
                navEvt.fire();
            } else if (oResponse.state === 'ERROR') {
                component.find('notifLib').showToast({
                    'title': '¡ERROR!',
                    'message': oResponse.message,
                    'variant': 'error',
                    'mode': 'sticky'
                });
                component.set("v.isDisabled",false);
            }
        });

        $A.getCallback(function () {
            $A.enqueueAction(action);
        })();
    },
})