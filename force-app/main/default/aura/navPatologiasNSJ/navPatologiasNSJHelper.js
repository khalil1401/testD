({
    items : [
        {'dataId':'Alergia__c', 'label':'Alergia', 'url':'alergia', 'id':'alergia-item-nav', 'idTablet':'alergia-item-nav-tablet', 'class' : 'first-td-patologia'},
        {'dataId':'Stroke__c', 'label':'Disfagia', 'url':'disfagia', 'id':'disfagia-item-nav', 'idTablet':'disfagia-item-nav-tablet', 'class' : 'td-patologia'},
        {'dataId':'custom_terapia_cetogenica__c', 'label':'Terapia Cetogénica', 'url':'terapia-cetogenica', 'id':'cetogenica-item-nav', 'idTablet':'cetogenica-item-nav-tablet', 'class' : 'td-patologia'},
        {'dataId':'digestivos__c', 'label':'Digestivos', 'url':'digestivos', 'id':'digestivos-item-nav', 'idTablet':'digestivos-item-nav-tablet', 'class' : 'td-patologia'},
        {'dataId':'malnutricion_home__c', 'label':'Malnutrición', 'url':'malnutricion', 'id':'malnutricion-item-nav', 'idTablet':'malnutricion-item-nav-tablet', 'class' : 'td-patologia'},
        {'dataId':'desafios_del_crecimiento__c', 'label':'Desafíos del Crecimiento', 'url':'desafios', 'id':'desafios-item-nav', 'idTablet':'desafios-item-nav-tablet', 'class' : 'td-patologia'},
        {'dataId':'metabolicos__c', 'label':'Metabólicos', 'url':'metabolicos', 'id':'metabolicos-item-nav', 'idTablet':'metabolicos-item-nav-tablet', 'class' : 'td-patologia'},
        {'dataId':'custom_oncologia__c', 'label':'Oncología', 'url':'oncologia', 'id':'oncologia-item-nav', 'idTablet':'oncologia-item-nav-tablet', 'class' : 'last-td-patologia'},
    ],

    setPatologias : function(component) {
        component.set("v.patologias", this.items);
    },

    redirect : function(component, event) {
        let apiName = event.currentTarget.dataset.id;
        let idTarget = event.currentTarget.id;
        
        //Seteo estilos para td
        for(let i = 0; i < this.items.length; i++){
            let patologiaCmp = document.getElementById(this.items[i].id);
            patologiaCmp.style.backgroundColor = "#ECF1F4";
            patologiaCmp.style.color = "#4A2A80";
            if(this.items[i].id == idTarget){
                patologiaCmp.style.backgroundColor = "#B59AC8";
                patologiaCmp.style.color = "white";
            }
        }

        //Redirect a ta correspondiente
        let navService = component.find("navService");
        let pageReference = {
            "type":'comm__namedPage',
            "attributes": {
                "name": apiName
            },
        };
        navService.navigate(pageReference);
        /**         
        if(apiName == 'digestivos__c'){
            //Redirect a ta correspondiente
            let navService = component.find("navService");
            let pageReference = {
                "type":'comm__namedPage',
                "attributes": {
                    "name": "registro_y_solicitud__c"
                },
				"state": {
                    "area": "Digestivos" 
				}
            };
            navService.navigate(pageReference);
        }
        else{
            //Redirect a ta correspondiente
            let navService = component.find("navService");
            let pageReference = {
                "type":'comm__namedPage',
                "attributes": {
                    "name": apiName
                },
            };
            navService.navigate(pageReference);
        }
        */
    },

    hideTableNav : function(component) {
        let patologiaCmp = document.getElementById("nav-patologias-nsj");
        if(patologiaCmp){
            document.getElementById("nav-patologias-nsj").style.display = "none";
        }
    },
})