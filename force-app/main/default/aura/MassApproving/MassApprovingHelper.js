({
	getOrdersHelper: function (component, actionName, value) {
		let action = component.get(actionName);

		action.setCallback(this, function (response) {
			let oResponse = response.getReturnValue();

			if (oResponse.state == 'SUCCESS') {
				let data = oResponse.data;
				let orders = [];

				data.GridData.forEach(record => {
					orders.push(
						{
							'Id': record.Id,
							'OrderNumberLink': '/' + record.Id,
							'OrderNumber': record.OrderNumber,
							'AccountId': record.Account.Name,
							//'Dan360_UnidadNegocio__c': record.Dan360_UnidadNegocio__c,
							'EffectiveDate' : record.EffectiveDate,
							'TotalAmount' : record.TotalAmount,
							'Status': record.Status,
							'Orden_de_compra__c' : record.Orden_de_compra__c,
							'Dan360_Semaforo__c': record.Dan360_Semaforo__c
						}
					);
				});

				component.set('v.columns', data.GridColumns);
				component.set('v.orders', orders);
			}
		});

		$A.getCallback(function () {
			$A.enqueueAction(action);
		})();
	},
	approveOrders: function (component, actionName, value) {
		const notification = component.find('notification');
		let action = component.get(actionName);
		let oResponse = null;
		let data = null;
		let orders = [];
		let errors = [];

		action.setParams({orders: value});
		action.setCallback(this, function (response) {
			oResponse = response.getReturnValue();
			data = oResponse.data;

			if (oResponse.state == 'SUCCESS') {
				notification.showToast({
					'title': '¡EXITOSO!',
					'message': oResponse.message,
					'variant': 'success',
					'mode': 'dismissable'
				});
			} else if (oResponse.state == 'ERROR') {
				errors = oResponse.message + '\r\n';
				notification.showToast({
					'title': 'ERROR!',
					'message': errors,
					'variant': 'error',
					'mode': 'dismissable'
				});
			}

			data.GridData.forEach(record => {
				orders.push(
					{
						'Id': record.Id,
						'OrderNumberLink': '/' + record.Id,
						'OrderNumber': record.OrderNumber,
						'AccountId': record.Account.Name,
						'Dan360_UnidadNegocio__c': record.Dan360_UnidadNegocio__c,
						'Status': record.Status,
						'Dan360_Semaforo__c': record.Dan360_Semaforo__c,
						'Result': oResponse.errors[record.Id]
					}
				);
			});
			component.set('v.canReturn', true);
			component.set('v.columns', oResponse.data.GridColumns);
			component.set('v.orders', orders);
			// component.set("v.HideSpinner", true);
		});

		$A.getCallback(function () {
			$A.enqueueAction(action);
		})();
	},
	navigateToList: function (component, actionName, helper) {
		var navEvent = $A.get('e.force:navigateToList');
		navEvent.setParams({
			'listViewId': '00B5e00000F3RfHEAV',
			'listViewName': null,
			'scope': 'Order'
		});
		navEvent.fire();
	},
	refreshFocusedTab: function (component, event, helper) {
		// var workspaceAPI = component.find('workspace');
		// workspaceAPI.getFocusedTabInfo()
		// 	.then(function (response) {
		// 		var focusedTabId = response.tabId;
		// 		workspaceAPI.refreshTab({
		// 			tabId: focusedTabId,
		// 			includeAllSubtabs: true
		// 		});
		// 	})
		// 	.catch(function (error) {
		// 		console.log(error);
		// 	});
		$A.get('e.force:refreshView').fire();
	},
	showSpinner: function (component, event, helper) {
		component.set("v.HideSpinner", true);
	},
	hideSpinner: function (component, event, helper) {
		component.set("v.HideSpinner", false);
	}
})