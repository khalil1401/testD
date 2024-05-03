({ 
	validateUserLogging : function(component){
		var userId = $A.get("$SObjectType.CurrentUser.Id");
		if(userId == null){
			component.set('v.userLogged', false);
		}
		else{
			component.set('v.userLogged', true);
		}
	},

	hideHover : function (component){ 
		let imagenFondo = component.get("v.imagenFondo"); 

		component.find("container").getElement().style.backgroundImage = "url("+imagenFondo+")";
		component.find("container").getElement().style.backgroundPosition = "center";
		component.find("container").getElement().style.backgroundSize = "cover";

		component.find("label").getElement().style.visibility = "hidden";
		component.find("footIzq").getElement().style.display = "block"; 
		component.find("footDer").getElement().style.display = "block"; 
		component.find("footCentro").getElement().style.display = "block"; 
		component.find("footerHover").getElement().style.display = "none";
		component.find("footer").getElement().style.justifyContent  = "space-between";
	},

	showHover : function (component){
		let imagenFondo = component.get("v.imagenFondo");
		let colorHover = component.get("v.colorHover");

		let rgb = this.hexToRgb(colorHover);
		let r = rgb.r;
		let g = rgb.g;
		let b = rgb.b;  
		let alpha = component.get("v.hoverColorTransparency");
		let setting = "linear-gradient( rgba("+r+","+g+","+b+","+alpha+"), rgba("+r+","+g+","+b+", "+alpha+")), url("+imagenFondo+")"; 
		
		
		component.find("container").getElement().style.background = setting; 
		component.find("container").getElement().style.backgroundPosition = "center";
		component.find("container").getElement().style.backgroundSize = "cover"; 

		component.find("label").getElement().style.visibility = "visible";
		component.find("footIzq").getElement().style.display = "none"; 
		component.find("footDer").getElement().style.display = "none"; 
		component.find("footCentro").getElement().style.display = "none"; 
		component.find("footerHover").getElement().style.display = "block";
		component.find("footer").getElement().style.justifyContent  = "center";
	},

	hexToRgb: function (hex) {
	  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
	  return result ? {
		r: parseInt(result[1], 16),
		g: parseInt(result[2], 16),
		b: parseInt(result[3], 16)
	  } : null;
	}, 

	callForm : function(component, event) { 
		let isAvailable = component.get("v.available"); 
		let unAvailableMessage = component.get("v.unAvailableMessage"); 
		if(!isAvailable) { 
			this.showMessage(component,"Aviso",unAvailableMessage);
		} else {  
			this.callModal(component,event);
		} 
	},

	setAvailability : function (component,event){
		var isAvailable = event.getParam("isAvailable"); 
		if(!isAvailable){
			component.set("v.available", false);
			component.set("v.unAvailableMessage", event.getParam("unAvailableMessage"));
		}  
		component.set("v.validationExecuted", true); 
		component.set("v.isLoading", false);  
	},

	loadBackgroundImage : function (component,event){ 
		let imagePath = component.get("v.imageName");
		let staticResourceName = component.get("v.staticResourceName");
		let staticResourceFontName = component.get("v.textoHoverFuente");
		component.set("v.imagenFondo", $A.get('$Resource.'+staticResourceName) + imagePath); 
	},

	callModal : function(component, event) {
        var surveyUrl = component.get('v.surveyUrl');
        var templateDeveloperName = component.get('v.templateDeveloperName');
		let componentToBeCreated = component.get("v.formComponentName");
        let modalBody;
		let modalHeader = component.get("v.titleForModal");
		let communitySource = component.get("v.comunidadOrigen");
        var modalFooter;
        $A.createComponents([
            [componentToBeCreated,{
				"registerEvent": true,
				"communitySource": communitySource,
                "surveyUrl": surveyUrl,
                "templateDeveloperName": templateDeveloperName
			}],
			["c:ModalFooterCloseButton",{}]
        ],
         function(components, status){
             if (status === "SUCCESS") {
                 modalBody = components[0];
				 modalFooter =  components[1];
                 component.find('overlayLib').showCustomModal({
                     //header: modalHeader,
                     body: modalBody,
                     //footer: modalFooter,
                     //showCloseButton: true, 
                     closeCallback: function() {
                     }
                 });
             }
         });
    }, 

	createComponent : function(component,event) { 
        var surveyUrl = component.get('v.surveyUrl');
		let componentToBeCreated = component.get("v.formComponentName"); 
		let communitySource = component.get("v.comunidadOrigen");
		$A.createComponent(
            componentToBeCreated,
            {
                "registerEvent": component.get("v.imFullyLoad"),
				"communitySource": communitySource,
				"initialValidationEvent": component.getReference("c.handleInitialFormEvent"),
                "surveyUrl": surveyUrl
            }, 
            function(newInp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newInp);
                    component.set("v.body", body);
					component.set("v.imFullyLoad",true);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
	},

	showMessage : function(component, header, message) {  
        var modalFooter;  
		var modalBody; 
		$A.createComponents([
			["c:ModalFooterCloseButton",{}],
			["aura:unescapedHtml",{"value": message}] 
		],
		function(components, status){
			if (status === "SUCCESS") {
				modalFooter = components[0]; 
				modalBody = components[1]; 
				component.find('overlayLib').showCustomModal({
				    header: header,
					body: modalBody,
					footer: modalFooter,
					showCloseButton: true, 
					closeCallback: function() {
					}
			   })
			}
		}
	   ); 
    }, 

	redirectToSite : function(component, event) {  
        let url = component.get("v.linkString");
		let target = component.get("v.linkTarget"); 
		window.open(url,target);
    }, 
})