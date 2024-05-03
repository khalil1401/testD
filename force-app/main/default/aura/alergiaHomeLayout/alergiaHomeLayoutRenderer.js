({
    // Your renderer method overrides go here
    afterRender: function (component, helper) {
        this.superAfterRender();
        //Se toma los varoles de los parámetros
        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        var sURLVariables = sPageURL.split('=');
        var sParameterName = sURLVariables[1];
        if(sParameterName == 'registro'){
            let div = document.getElementById("bki");
            if(div){
                setTimeout(() => {div.scrollIntoView({
                    behavior: 'smooth',
                    block: 'center',
                    inline: 'center'
                });}, 1);
            }
        }
    },
})