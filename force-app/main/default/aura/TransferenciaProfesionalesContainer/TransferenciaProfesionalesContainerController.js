({
	doInit: function (component, event, helper) {
		let data = {fromInternal: true, d: ''};
		let userInfo = JSON.parse(JSON.stringify($A.get("$SObjectType.CurrentUser")));

		data.fromInternal = false;
		data.d = userInfo.Id;
		helper.validateProfile(component, event, helper, 'c.getUserInfo', userInfo.Id);
	},
	handleFiltersFeedback: function (component, event, helper) {
		let params = JSON.parse(JSON.stringify(event.getParams()));

		component.set('v.filters', params.filters);
		component.find('tracking').loadData();
	},
	handleOpenTransferModal: function (component, event, helper) {
		const detail = JSON.parse(JSON.stringify(event.getParams()));

		component.set('v.showModal', detail.showModal);
		component.set('v.modalTitle', detail.title);
		component.set('v.action', detail.action);
		component.get('v.action');
	},
	handleCloseTransferModal: function (component, event, helper) {
		const detail = JSON.parse(JSON.stringify(event.getParams()));

		component.set('v.showModal', false);
	},
	handleNotifyRecordsSelection: function (component, event, helper) {
		const detail = JSON.parse(JSON.stringify(event.getParams()));

		component.set('v.numberOfSelectedRecords', detail.numberOfSelectedRecords);
		component.set('v.hasSelectedRecords', detail.hasSelectedRecords);
	}
})