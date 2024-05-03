({
    doInit : function(component, event, helper) {

        let recursoEstaticoBackground = component.get("v.recursoEstaticoBackground");
        component.set("v.rutaImagenBackground", recursoEstaticoBackground);

        //Seteo altura Mobile
        var device = $A.get("$Browser.formFactor");
        if(device === 'DESKTOP'){
            component.set('v.isDesktop', true);
            let recursoEstaticoImagen = component.get("v.recursoEstaticoImagen");
            component.set("v.rutaImagen", recursoEstaticoImagen);
        }
        else{
            component.set('v.isDesktop', false);
            let recursoEstaticoImagen = component.get("v.recursoEstaticoImagenMobile");
            component.set("v.rutaImagen", recursoEstaticoImagen);
        }

    },
})