({
    goToDiv : function(component, event, helper) {
        let seccion = event.getParam('value');
        document.getElementById(seccion).scrollIntoView({
            behavior: 'smooth',
            block: 'start',
            inline: 'center'
        });
    }
})