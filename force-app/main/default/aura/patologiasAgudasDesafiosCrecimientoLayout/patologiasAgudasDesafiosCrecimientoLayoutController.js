({
    goToDiv : function(component, event, helper) {
        let div = event.target.dataset.seccion;
        let type = event.target.dataset.type;
        document.getElementById(div).scrollIntoView({
            behavior: 'smooth',
            block: type,
            inline: type
        });
    }
})