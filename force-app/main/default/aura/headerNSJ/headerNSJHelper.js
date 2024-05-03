({
    redirect : function(component, event) {
        let apiName = event.currentTarget.dataset.id;
        let navService = component.find("navService");
        let pageReference = {
            "type":'comm__namedPage',
            "attributes": {
                "name": apiName
            },
        };
        navService.navigate(pageReference);
    },

    showDropdown : function(component, event) {
        let patologiaCmp = document.getElementById("nav-patologias-nsj");
        if(patologiaCmp){
            let display = window.getComputedStyle(patologiaCmp).display;
            if(display == 'none'){
                document.getElementById("nav-patologias-nsj").style.display = "initial";
            }
            else{
                document.getElementById("nav-patologias-nsj").style.display = "none";
            }
        }
    }
})