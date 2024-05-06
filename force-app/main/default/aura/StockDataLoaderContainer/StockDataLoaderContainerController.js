({
	closeQA: function (component, event, helper) {
		$A.get('e.force:closeQuickAction').fire();
		this.dispatchEvent(new CustomEvent('success'));
	}
})