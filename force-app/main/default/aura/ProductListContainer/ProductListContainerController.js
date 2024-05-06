({
    doInit: function (component, event, helper) {
        
        //console.log(component.get("v.recordId"));
		var action = component.get("c.updateMaterials");
        action.setParams({
            "pedidoId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                //console.log(response.getReturnValue());
                component.set('v.isLoading', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Exito!",
                    "message": response.getReturnValue(),
                    "type" : 'success'
                });
                toastEvent.fire();
            } else {
                component.set('v.isLoading', false);
                // var toastEvent = $A.get("e.force:showToast");
                // toastEvent.setParams({
                    //     "title": "Error!",
                    //     "message": response.getReturnValue(),
                    //     "type" : 'error'
                    // });
                    // toastEvent.fire();
                    
                    let errors = response.getError();
                    let message = 'Unknown error'; // Default error message
                    //console.error(errors);
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0 && Array.isArray(errors[0].pageErrors) && errors[0].pageErrors.length > 0) {
                        message = errors[0].pageErrors[0].message;
                    }
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "ERROR",
                        "message": message
                    });
                }
            });
            $A.enqueueAction(action);
            
        },
        
        closeWindow : function(component, event, helper) {
            //console.log('Aura component');
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        },
        
        // show toast
        // recordUpdate : function(component, event, helper){
        //     let changeType = event.getParams().changeType
        //     var orderRecord = component.get("v.orderRecord");
        //     console.log('etapa: '+ orderRecord.Status);
        //     if (changeType === "CHANGED" || changeType === "LOADED") {
        //         if( orderRecord.Status !== 'Borrador' ){
        //             // var toastEvent = $A.get("e.force:showToast");
        //             // toastEvent.setParams({
        //             //     "title": "Prohibido Agregar!",
        //             //     "message": "Solo se puede agregar productos en la etapa Borrador."
        //             // });            
                
        //             // toastEvent.fire();
        
                
        //         }
        //     }
        // }

})