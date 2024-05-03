({    
    getUser : function(component, helper){
        let userId = $A.get("$SObjectType.CurrentUser.Id");
        if(userId){    
            var action = component.get("c.getDataUser");
            action.setParams({
                userId : userId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    let res = response.getReturnValue();
                    if(res){
                        component.set("v.currentUser", res);
                    }
                }
                //agregar error
            })
            $A.enqueueAction(action);            
        }
    },
})