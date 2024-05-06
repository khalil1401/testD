({
	enableSearch: function (component, event, helper, actionName, value) {
		let action;

		if (value.fromInternal) {
			component.set('v.accountId', value.d);
			this.doSearchHelper(component, helper);
		} else {
			action = component.get(actionName);
			action.setParams({userId: value.d});
			action.setCallback(this, function (oResponse) {
				if (oResponse.getState() == 'SUCCESS') {
					let data = oResponse.getReturnValue();
					console.log(data.data[0].AccountId);
					component.set('v.accountId', data.data[0].AccountId);
					this.doSearchHelper(component, helper);
				}
			});
		}

		if (action != undefined) {
			$A.enqueueAction(action);
		}
	},
	doSearchHelper: function (component, helper) {
		component.find('documents').getCheckingAccountReport();
	},
	hideExampleModal : function(component) {
		console.log('Helper');
        var modal = component.find("exampleModal");
        $A.util.addClass(modal, 'hideDiv');
    }
})