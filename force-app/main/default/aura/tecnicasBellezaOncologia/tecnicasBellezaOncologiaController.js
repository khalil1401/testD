({
    doInit : function(component, event, helper) {
        helper.getTecnicasDeBelleza(component, event);
    },
    showInformacionArticulo : function(component, event, helper) {
        let tituloArticuloSeleccionado = event.target.dataset.id;
        let listaArticulos = component.get("v.articulos");

        for(let i = 0; i<listaArticulos.length; i++){
            if(listaArticulos[i].Title == tituloArticuloSeleccionado){
                component.set("v.articuloSeleccionado", listaArticulos[i]);
                //imagen
                let staticResourceName = listaArticulos[i].Imagen__c;
                if(!staticResourceName){
                    return;
                }
                component.set("v.rutaImg", staticResourceName);
            }
        }
        document.getElementById('descripcion').scrollIntoView({
            behavior: 'smooth',
            block: 'start',
            inline: 'start'
        });
    },
    onMouseOver : function(component, event, helper) {
        event.target.classList.add('withOpacity');
    },
    onMouseOut : function(component, event, helper) {
        event.target.classList.remove('withOpacity');
    },
})