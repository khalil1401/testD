({
    // Your renderer method overrides go here
    afterRender: function (component, helper) {
        this.superAfterRender();
        // interact with the DOM here
        let urlString = window.location.href;
        let baseURL = urlString.substring(urlString.indexOf("/s/")+3, urlString.length);
        let ta = baseURL.split('/');

        if(ta.length > 0){
            for(let i = 0; i < helper.items.length; i++){
                if(helper.items[i].url == ta[0]){
                    //set color patologia items selected desktop
                    let patologiaCmp = document.getElementById(helper.items[i].id);
                    if(patologiaCmp){
                        patologiaCmp.style.backgroundColor = "#B59AC8";
                        patologiaCmp.style.color = "white";
                        patologiaCmp.style.borderRadius = "8px";
                    }
                    if(i-1 >= 0){
                        //set color patologia last item selected desktop
                        let lastPatologiaCmp = document.getElementById(helper.items[i-1].id);
                        if(lastPatologiaCmp){
                            if(i-1 == 0){
                                lastPatologiaCmp.style.borderRadius = "0px 0px 8px 8px";
                            }
                            else{                                
                                lastPatologiaCmp.style.borderRadius = "0px 0px 8px 0px";
                            }
                        }
                    }
                    if(i+1 <= helper.items.length-1) {
                        //set color patologia next item selected desktop
                        let nextPatologiaCmp = document.getElementById(helper.items[i+1].id);
                        if(nextPatologiaCmp) {
                            if(i+1 == helper.items.length-1) {
                                nextPatologiaCmp.style.borderRadius = "0px 0px 8px 8px";
                            }
                            else {
                                nextPatologiaCmp.style.borderRadius = "0px 0px 0px 8px";
                            }
                        }
                    }
                    //set color patologia items selected tablet
                    let patologiaCmpTablet = document.getElementById(helper.items[i].idTablet);
                    if(patologiaCmpTablet){
                        patologiaCmpTablet.style.backgroundColor = "#B59AC8";
                        patologiaCmpTablet.style.color = "white";
                    }                    
                }
            }
        }
    },
})