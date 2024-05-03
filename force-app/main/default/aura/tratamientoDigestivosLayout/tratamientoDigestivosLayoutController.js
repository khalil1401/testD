({
    goToDiv : function(component, event, helper) {
        let div = event.target.dataset.seccion;
        document.getElementById(div).scrollIntoView({
            behavior: 'smooth',
            block: 'center',
            inline: 'center'
        });
    }
})