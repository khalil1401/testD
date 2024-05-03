({
    doInit : function(component, event, helper) {

        helper.setDevice(component, event);

        var listaDataCards = component.get("v.dataCards");
        var numberShowCards = component.get("v.numberShowCards");
        var list = JSON.parse(listaDataCards);
        var listToShow = [];

        for (let i = 0; i < numberShowCards; i++) {
            listToShow[i] = list[i];
        }

        component.set("v.listDataCards", list);
        component.set("v.listToShow", listToShow);
        component.set("v.cantidadCards", list.length);

    },
    mostrarUnoMas : function(component, event, helper) {

        var indiceInicial = component.get("v.indiceInicial");
        var listDataCards = component.get("v.listDataCards");
        var listToShow = component.get("v.listToShow");
        var numberShowCards = component.get("v.numberShowCards");

        if( indiceInicial + numberShowCards < listDataCards.length) {

            component.set("v.indiceInicial", indiceInicial+1);
            var indiceActual = component.get("v.indiceInicial");
    
            for (let i = 0; i < numberShowCards; i++) {
                listToShow[i] = listDataCards[indiceActual+i];
            }
    
            component.set("v.listToShow", listToShow);
        }

    },
    mostrarUnoMenos : function(component, event, helper) {

        var indiceInicial = component.get("v.indiceInicial");
        var listDataCards = component.get("v.listDataCards");
        var listToShow = component.get("v.listToShow");
        var numberShowCards = component.get("v.numberShowCards");

        if( indiceInicial > 0) {
            component.set("v.indiceInicial", indiceInicial-1);
            var indiceActual = component.get("v.indiceInicial");
    
            for (let i = 0; i < numberShowCards; i++) {
                listToShow[i] = listDataCards[indiceActual+i];
            }
    
            component.set("v.listToShow", listToShow);
        }

    },
})