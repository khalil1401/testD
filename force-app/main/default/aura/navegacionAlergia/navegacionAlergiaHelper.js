({
	goToRedSocial : function(component,event,helper){
        let seleccionado = event.target.dataset.id;
        let ruta = component.get("v." + seleccionado);

        let navService = component.find("navService");
        let pageReference = {
           type: 'standard__webPage',
           attributes: {
                url: ruta
           }
        };
        navService.navigate(pageReference);

    },

	goToPortalPage : function(component,event,helper){
        let seleccionado = event.target.dataset.id;
        let apiName = component.get("v." + seleccionado);

        let navService = component.find("navService");
        let pageReference = {
            type: 'comm__namedPage',
            attributes: {
                name: apiName
            }
        };
        navService.navigate(pageReference);
    },

	selectTab : function(component,event,helper){
        let tab = component.get("v.currentPage");
        //chequeo si me encuentro en la descripcion de la receta para tambien aplicar estilo a recetario
        let tabEditada = tab.substr(0, 18);
        if(tabEditada == 'descripcion-receta'){
            tab = 'recetario-alergia';
        }
        let cmp = component.find(tab);
        $A.util.addClass(cmp, 'tabSeleccionadaAlergia');
    },
})