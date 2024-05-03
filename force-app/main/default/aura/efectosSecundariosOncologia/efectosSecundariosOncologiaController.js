({
    doInit: function(component, event, helper) {
        helper.setDevice(component, event, helper);
    },
    showInfo : function(component, event, helper) {
        component.set("v.disfagia", false);
        component.set("v.perdidaApetito", false);        
        component.set("v.estrenimiento", false);
        component.set("v.fatiga", false);
        component.set("v.gustoYOlfato", false);
        component.set("v.diarrea", false);
        component.set("v.vomitos", false);
        component.set("v.mucositis", false);

        let card = "v." + event.currentTarget.dataset.id;
        component.set(card, true);
        document.getElementById('descripcion').scrollIntoView({
            behavior: 'smooth',
            block: 'start',
            inline: 'center'
        });
    }
})