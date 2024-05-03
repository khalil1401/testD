({
    goToDiv : function(component, event, helper) {
        let seccion = event.getParam('value');
        setTimeout(() => {document.getElementById(seccion).scrollIntoView({
            behavior: 'smooth',
            block: 'start',
            inline: 'start'
        });}, 200);
    }
})