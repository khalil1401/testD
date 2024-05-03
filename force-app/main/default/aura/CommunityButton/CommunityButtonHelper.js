({ 
	hideHover : function (component){
		let imagenFondo = component.get("v.staticResourceName"); 

		component.find("container").getElement().style.backgroundImage = "url("+imagenFondo+")";
		component.find("container").getElement().style.backgroundPosition = "center";
		component.find("container").getElement().style.backgroundSize = "cover";
		component.find("label").getElement().style.visibility = "hidden";
		component.find("footer").getElement().style.display = "";
	},

	showHover : function (component){
		let imagenFondo = component.get("v.staticResourceName");
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
		component.find("footer").getElement().style.display = "none";
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

	callModal : function(component, event) {
		let componentToBeCreated = component.get("v.formComponentName");
		if(!componentToBeCreated){
			return;
		}
        let modalBody;
		let modalHeader = component.get("v.titleForModal");
		let communitySource = component.get("v.comunidadOrigen");
        var modalFooter;
        $A.createComponents([
            [componentToBeCreated,{
				"registerEvent": true,
				"communitySource": communitySource
			}],
			["c:ModalFooterCloseButton",{}]
        ],
         function(components, status){
             if (status === "SUCCESS") {
                 modalBody = components[0];
				 modalFooter =  components[1];
                 component.find('overlayLib').showCustomModal({
                     header: modalHeader,
                     body: modalBody,
                     footer: modalFooter,
                     showCloseButton: true, 
                     closeCallback: function() {
                     }
                 });
             }
         });
    }, 

	createComponent : function(component,event) { 
		let componentToBeCreated = component.get("v.formComponentName"); 
		if(!componentToBeCreated){
			return;
		}
		let communitySource = component.get("v.comunidadOrigen");
		$A.createComponent(
            componentToBeCreated,
            {
                "registerEvent": component.get("v.imFullyLoad"),
				"communitySource": communitySource,
				"initialValidationEvent": component.getReference("c.handleInitialFormEvent")
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

	/**
	goTo : function(component,event,helper){
		let apiName = component.get("v.apiNamePage");
		if(apiName == 'Login'){
			let urlLogout = '/login';
			let urlString = window.location.href;
			let baseURL = urlString.substring(0, urlString.indexOf("/s")+2);
			let url = baseURL + urlLogout ;
			window.location.href = url;
		}
		else if(apiName == 'registro_y_solicitud__c'){
			let navService = component.find("navService");
			let pageReference = {
				type: 'comm__namedPage',
				attributes: {
					name: apiName
				},
				state: {
					area: 'Digestivos'
				}
			};
			navService.navigate(pageReference);
		}
		else{
			let navService = component.find("navService");
			let pageReference = {
			   type: 'comm__namedPage',
			   attributes: {
				   name: apiName
			   }
			};
//			navService.navigate(pageReference);
			// Set the URL on the link or use the default if there's an error
			var defaultUrl = "#";
			navService.generateUrl(pageReference)
				.then($A.getCallback(function(url) {
					console.log(url);
				}), $A.getCallback(function(error) {
					console.log(defaultUrl);
				}));
		}
    },
	 */

	setURls : function(component,event,helper){
		//Seteo de url para redirección
		let apiName = component.get("v.apiNamePage");
		if(apiName){
			if(apiName == 'Login'){
				let urlLogout = '/login';
				let urlString = window.location.href;
				let baseURL = urlString.substring(0, urlString.indexOf("/s")+2);
				let url = baseURL + urlLogout ;
				component.set("v.url", url);
			}
			/** 
			else if(apiName == 'digestivos__c'){
				let navService = component.find("navService");
				let pageReference = {
					type: 'comm__namedPage',
					attributes: {
						name: 'registro_y_solicitud__c'
					},
					state: {
						area: 'Digestivos'
					}
				};
				var defaultUrl = "#";
				navService.generateUrl(pageReference)
					.then($A.getCallback(function(url) {
						component.set("v.url", url ? url : defaultUrl);
					}), $A.getCallback(function(error) {
						component.set("v.url", defaultUrl);
					}));
			}
			*/
			else{
				let navService = component.find("navService");
				let pageReference = {
					type: 'comm__namedPage',
					attributes: {
						name: apiName
					}
				};
				var defaultUrl = "#";
				navService.generateUrl(pageReference)
					.then($A.getCallback(function(url) {
						component.set("v.url", url ? url : defaultUrl);
					}), $A.getCallback(function(error) {
						component.set("v.url", defaultUrl);
					}));
			}
		}
	}

})