({
    doInit : function(component, event, helper){
		let textTwitter = component.get('v.twitterText');
		if(!$A.util.isEmpty(textTwitter)){
			textTwitter.concat(' \n ');
			component.set('v.twitterText', encodeURIComponent(textTwitter));
		}

		let facebookText = component.get('v.facebookText');
		if(!$A.util.isEmpty(facebookText)){
			facebookText.concat(' \n ');
			component.set('v.facebookText', encodeURIComponent(facebookText));
		}

		let linkedinText = component.get('v.linkedinText');
		if(!$A.util.isEmpty(linkedinText)){
			linkedinText.concat(' \n ');
			component.set('v.linkedinText', encodeURIComponent(linkedinText));
		}

		let whatsappText = component.get('v.whatsappText');
		if(!$A.util.isEmpty(whatsappText)){
			whatsappText.concat(' \n ');
			component.set('v.whatsappText', encodeURIComponent(whatsappText));
		}
    }
})