({
	createOrder : function (component) {
		var record = component.get("v.recordId");
		var userId = $A.get("$SObjectType.CurrentUser.Id");
		console.log(userId);
		console.log(record);
		var modalBody;
		$A.createComponent("c:FlowToolkitModal", {
		}, (content, status) => {
			if (status === "SUCCESS") {
				modalBody = content;
				component.find('overlayLibModal').showCustomModal({
					body: modalBody,
					showCloseButton: true,
					/* closeCallback: function() {
						$A.get('e.force:refreshView').fire();
					} */
				}).then(function (overlay) {
					// cache the overlay into the component
					component._overlay = overlay;
				});
			}
		});
	},

})