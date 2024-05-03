({
    redirect : function(component, event, helper) {
        let apiName = event.currentTarget.dataset.id;
        //Set style button selected
        if(apiName == 'registro_y_solicitud__c'){
            let cmp = component.find("register-btn-nsj");
            if(cmp){
                cmp.getElement().style.backgroundColor = "#B59AC8";
                cmp.getElement().style.boxShadow  = "4px 4px 10px rgba(0, 0, 0, 0.25)";
            }
        }
        //set style to items
        let id = apiName + '-item-profile-menu';
        let divItem = component.find(id);
        if(divItem) {
            divItem.getElement().style.backgroundColor = "#B59AC8";
            divItem.getElement().style.color = "white";
        }
        //nav
        let navService = component.find("navService");
        let pageReference = {
            "type":'comm__namedPage',
            "attributes": {
                "name": apiName
            },
        };
        navService.navigate(pageReference);
        component.set("v.showList", false);
    },

    login : function(component, event, helper) {
        //Set style button selected
        let cmp = component.find("login-btn-nsj");
        if(cmp){
            cmp.getElement().style.backgroundColor = "#B59AC8";
            cmp.getElement().style.boxShadow  = "4px 4px 10px rgba(0, 0, 0, 0.25)";
        }
        let cmpTablet = component.find("login-btn-nsj-tablet");
        if(cmpTablet){
            cmpTablet.getElement().style.backgroundColor = "#B59AC8";
            cmpTablet.getElement().style.color = "white";
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
        let cmpTablet = component.find("logout-item-profile");
        if(cmpTablet){
            cmpTablet.getElement().style.backgroundColor = "#B59AC8";
            cmpTablet.getElement().style.color = "white";
        }
        //nav
        let urlLogout = '/secur/logout.jsp?retUrl=';
        let urlString = window.location.href;
        let baseURL = urlString.substring(0, urlString.indexOf("/s"));
        let url = baseURL + urlLogout + baseURL;
        window.location.href = url;
    },

    showModal : function(component, event, helper) {
        let compModal = document.getElementById("items-profile-menu-nsj");
        if(compModal){
            let display = window.getComputedStyle(compModal).display;
            if(display == 'none'){
                compModal.style.display = "initial";
            }
            else{
                compModal.style.display = "none";
            }
        }
    },
})