({
    doInit : function(component, event, helper){
        helper.setDevice(component, event);
        helper.getTiposDeEjercicios(component, event);
    },
    showInformacionArticulo : function(component, event, helper){
        let tipoEjercicio = event.target.dataset.id;
        component.set("v.tipoEjercicio", tipoEjercicio);
        helper.getEjercicios(component, event);        
        let staticResourceName = component.get("v.articuloSeleccionado.Imagen__c");
		component.set("v.rutaRecursoEstatico", staticResourceName); 
        document.getElementById('descripcion').scrollIntoView({
            behavior: 'smooth',
            block: 'start',
            inline: 'center'
        });
    },
    mostrarUnoMas : function(component, event, helper){
        helper.adelantar(component, event);
    },
    mostrarUnoMenos : function(component, event, helper){
        helper.atrasar(component, event);
    },
    onMouseOver : function(component, event, helper){
        event.target.classList.add('withOpacity');
    },
    onMouseOut : function(component, event, helper){
        event.target.classList.remove('withOpacity');
    },
})