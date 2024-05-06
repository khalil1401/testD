({
	onInit: function (component, event, helper) {
		helper.getOrdersHelper(component, 'c.GetRetainedOrders');
	},
	onSelect: function (component, event, helper) {
		let retainedOrders = component.find('retainedOrders');
		let selectedOrders = retainedOrders.getSelectedRows();

		component.set('v.canSave', !(selectedOrders != null && selectedOrders.length > 0));
	},
	
	onSave: function (component, event, helper) {
		let retainedOrders = component.find('retainedOrders');
		let selectedOrders = retainedOrders.getSelectedRows();
		component.set('v.showModal', true);
		let flow = component.find("flowConfirmarPeidos");
		let selectedOrderIdList = []; 
		
		if (selectedOrders != null && selectedOrders.length > 0) {
			
			for (let i = 0; i < selectedOrders.length; i++) {
				selectedOrderIdList.push(selectedOrders[i].Id);
			}

			let idListToFlow = [{
					name : 'listaIdComponente',
					type : 'String',
					value : selectedOrderIdList
				}				
			];
			console.log('Empezo el flow');
			console.log(event.getParam('status'));
			flow.startFlow("Confirmacion_Masiva_de_Pedidos_Componente_Final", idListToFlow);
			console.log(event.getParam('status'));		
			if (event.getParam('status') === "FINISHED" ) {
				console.log('finalizo el flow');
				$A.get("e.force:closeQuickAction").fire();
				$A.get('e.force:refreshView').fire();
			}			
			
		} else {
			helper.showNotification('¡ERROR!', 'Debe seleccionar al menos una orden.', 'info', 'dismissable');
		}
	},
	onRefresh: function (component, event, helper) {
		helper.refreshFocusedTab(component);
	},
	onCancel: function (component, event, helper) {
		helper.navigateToList(component);
	},
	waiting: function (component, event, helper) {
		helper.showSpinner(component);
	},
	doneWaiting: function (component, event, helper) {
		helper.hideSpinner(component);
	},
	closeWindow : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
		component.set('v.showModal', false);
	}, 
	onEventChange : function (component, event, helper) {
		console.log('event.detail.status');
		console.log(event.getParam('status'));
		if (event.getParam('status') === "FINISHED" ) {
			console.log('finalizo el flow');
			$A.get("e.force:closeQuickAction").fire();
			$A.get('e.force:refreshView').fire();
		}
	}
})