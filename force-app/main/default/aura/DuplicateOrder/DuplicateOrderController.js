({
    duplicateOrder: function (component, event, helper) {
        event.preventDefault();
        let newOrder = event.getParam('fields');
        let originalOrderId = component.get('v.recordId');
        component.set("v.isDisabled",true);
        helper.duplicateOrderHelper(component, 'c.Duplicate', { originalOrderId, newOrder });
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleUpdate: function(component, event, helper) {
        let changeType = event.getParams().changeType;
        let recordType = JSON.stringify(component.get("v.orderShowData").RecordType.DeveloperName).toString();

        if (changeType === "LOADED") {
            let actionAcessRecord = component.get('c.hasAccess');
            actionAcessRecord.setParams({
                recordId: component.get('v.recordId')
            });
            actionAcessRecord.setCallback(this, function(response){   
                var state = response.getState();            
                if(state == 'SUCCESS') {  
                    let acceso = response.getReturnValue();
                    console.log(acceso);
                    component.set('v.accessRecord', acceso);
                }
                component.set('v.enableSpinner', false);
                
            }); 
            $A.enqueueAction(actionAcessRecord);

            let action = component.get('c.getObjectsFields');
            action.setParams({
                recordTypeName: recordType
            });
            action.setCallback(this, function(response){   
                var state = response.getState();            
                if(state == 'SUCCESS') {  
                    let fields = response.getReturnValue();
                    component.set('v.fields', fields);
                }
            });       

            $A.enqueueAction(action);
        }
    }
    /*doInit:function(component, event, helper) {
        let changeType = event.getParams().changeType;
        console.log(changeType);
        let recordType = JSON.stringify(component.get("v.orderShowData").RecordType.DeveloperName).toString();
            console.log(recordType);
        if (changeType === "LOADED") {
            let action = component.get('c.getObjectsFields');
            console.log("Loaded successfully.");
            action.setParams({
                recordTypeName: recordType
            });
            action.setCallback(this, function(response){   
                var state = response.getState();            
                if(state == 'SUCCESS') {  
                    let fields = response.getReturnValue();
                    component.set('v.fields', fields);
                }
            });       

            $A.enqueueAction(action);
        }
    }*/
})