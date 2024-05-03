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
            })
            $A.enqueueAction(action);            
        }
    },

    login : function(component, event, helper) {
        //Set style button selected
        let cmp = component.find("login-modal-item-profile");
        if(cmp){
            cmp.getElement().style.backgroundColor = "#B59AC8";
            cmp.getElement().style.color = "white";
        }
        //nav
        let urlLogout = '/login';
        let urlString = window.location.href;
        let baseURL = urlString.substring(0, urlString.indexOf("/s")+2);
        let url = baseURL + urlLogout ;
        window.location.href = url;
    },

    logOut : function(component, event, helper) {
        //Set style button selected
        let cmp = component.find("logout-modal-item-profile");
        if(cmp){
            cmp.getElement().style.backgroundColor = "#B59AC8";
            cmp.getElement().style.color = "white";
        }
        //nav
        let urlLogout = '/secur/logout.jsp?retUrl=';
        let urlString = window.location.href;
        let baseURL = urlString.substring(0, urlString.indexOf("/s"));
        let url = baseURL + urlLogout + baseURL;
        window.location.href = url;
    },
    
    redirect : function(component, event){
        let apiName = event.target.dataset.id;
        //Set style button selected
        let cmp = component.find(apiName + "-modal-item-profile");
        if(cmp){
            cmp.getElement().style.backgroundColor = "#B59AC8";
            cmp.getElement().style.color = "white";
        }
        //redirect to ta
        let navService = component.find("navService");
        let pageReference = {
            "type":'comm__namedPage',
            "attributes": {
                "name": apiName
            },
        };
        navService.navigate(pageReference);
    },
})