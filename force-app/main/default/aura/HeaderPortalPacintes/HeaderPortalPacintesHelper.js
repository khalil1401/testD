({
    setIconos : function(component, event) {
        let icono1 = component.get("v.icono1");
        let icono2 = component.get("v.icono2");
        if(icono1 && icono2){
            component.set("v.multipleIcons", true);
        }
    },

    goToLinkPrimerIcono : function(component, event) {
        let page = component.get("v.linkToIcono1");
        let navService = component.find("navService");
        let pageReference = {
            "type":'comm__namedPage',
            "attributes": {
                "name": page
            },
        };
        navService.navigate(pageReference);
    },

    goToLinkSegundoIcono : function(component, event) {
        let page = component.get("v.linkToIcono2");
        let navService = component.find("navService");
        let pageReference = {
            "type":'comm__namedPage',
            "attributes": {
                "name": page
            },
        };
        navService.navigate(pageReference);
    },
})