({
    shareDocument : function(component, event, helper){
        var socialMediaUrl = component.get('v.url'); 
        var documentUrl = encodeURIComponent(window.location.href);
        shareSocialMediaPopUpWindow = window.open(
            socialMediaUrl + ' ' + documentUrl,
            'shareSocialMediaPopUpWindow','width=600,height=300'
     	);
    }
})