({
    mostrarMasMenos : function(component, event, helper) {
        let verDetalles = component.get("v.verDetalles");
        if(!verDetalles){
            component.set("v.verDetalles", true);
        }
        else{
            component.set("v.verDetalles", false);
        }
    }
})