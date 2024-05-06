({
	validateProfile: function (component, event, helper, actionName, value) {
		let action;

		if (value) {
			action = component.get(actionName);
			action.setParams({userId: value})
			action.setCallback(this, function (response) {
				let data = response.getReturnValue();
				component.set('v.enableSupervisorFilter', data == 'System Administrator');
			});
		}

		if (action != undefined) {
			$A.enqueueAction(action);
		}
	}
})