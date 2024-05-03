({
    doInit : function(component, event, helper) {

        var listaDataCards = component.get("v.dataCards");
        var numberShowCards = component.get("v.numberShowCards");
        var indiceInicial = component.get("v.indiceInicial");
        var list = JSON.parse(listaDataCards);
        var listToShow = [];

        for (let i = 0; i < numberShowCards; i++) {
            listToShow[i] = list[i];
        }

        component.set("v.listDataCards", list);
        component.set("v.listToShow", listToShow);

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
            component.find("iconReversa").getElement().style.opacity  = "1";
        }
        else {
            component.find("iconAdelantar").getElement().style.opacity  = "0.2";
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
            component.find("iconAdelantar").getElement().style.opacity  = "1";
        }
        else{
            component.find("iconReversa").getElement().style.opacity  = "0.2";
        }

    },
})