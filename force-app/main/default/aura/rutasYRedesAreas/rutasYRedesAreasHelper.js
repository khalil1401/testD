({
    redirectToSocialMediaLink : function(component, event) {

        let rutaFacebook = component.get("v.rutaFacebook");
        let rutaInstagram = component.get("v.rutaInstagram");
        let rutaYoutube = component.get("v.rutaYoutube");

        let seleccionado = event.target.dataset.id;

        if(seleccionado === 'fb') {
            component.set("v.link", rutaFacebook);
            this.redirect(component, event);
        }
        if(seleccionado === 'ig') {
            component.set("v.link", rutaInstagram);
            this.redirect(component, event);
        }
        if(seleccionado === 'yt') {
            component.set("v.link", rutaYoutube);
            this.redirect(component, event);
        }

    },

    redirect : function(component, event) {

        let link = component.get("v.link");
        if(link.length > 0){
            let urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": '' + link
            });
            urlEvent.fire();    
        }

    }
})