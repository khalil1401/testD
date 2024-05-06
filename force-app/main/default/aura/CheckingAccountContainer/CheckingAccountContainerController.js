({
	doInit: function (component, event, helper) {
		let data = {fromInternal: true, d: ''};

		if (component.get('v.recordId')) {
			data.d = component.get('v.recordId');
		} else {
			let userInfo = JSON.parse(JSON.stringify($A.get("$SObjectType.CurrentUser")));
			data.fromInternal = false;
			data.d = userInfo.Id;
		}
		console.log('data');
		console.log(data);
		helper.enableSearch(component, event, helper, 'c.getUserInfo', data);

		component.set('v.canDownload', true);
	},

	handleSearchDocuments: function (component, event, helper) {
		let filters = JSON.parse(JSON.stringify(event.getParams()));

		component.set('v.filters', filters);
		let hasData = component.find('documents').getCheckingAccountReport();

		component.set('v.canDownload', !hasData);
	},
	// handleValidateDateRange: function (component, event, helper) {
	// 	let dateRangeValidate = JSON.parse(JSON.stringify(event.getParams()));
	// 	let dateRangeIsValid = dateRangeValidate.isValid;

	// 	component.set('v.dateRangeIsValid', dateRangeIsValid);
	// },
	handleCanDownloadCsvFile: function (component, event, helper) {
		let result = JSON.parse(JSON.stringify(event.getParams()));
		
		component.set('v.canDownload', !result.hasData);
	},
	handleDownloadCsvFile: function (component, event, helper) {
		component.find('documents').downloadCsvFile();
	},
	handleFiltersFeedback: function (component, event, helper) {
		let filters = JSON.parse(JSON.stringify(event.getParams()));
		console.log(filters);
		component.set('v.filters', filters);
		if (Object.keys(filters.filters).length == 0) {
			var init = component.get('c.doInit');
			$A.enqueueAction(init);
		}
	},

	handleClose: function (component, event, helper) {
		console.log('Cerrar modal');
		var modal = component.find("messageModal");
		var presentation = component.find("presentationModal");
        $A.util.addClass(modal, 'hideDiv');
		$A.util.addClass(presentation, 'hideDiv');
		helper.hideExampleModal(component);
	}


})