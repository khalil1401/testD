({
	loadBackgroundImage : function (component,event){ 
		let imagePath = component.get("v.imageName");
		let staticResourceName = component.get("v.staticResourceName");
		if(!staticResourceName){
			return;
		}
		component.set("v.imagenFondo", $A.get('$Resource.'+staticResourceName) + imagePath); 
	},
})