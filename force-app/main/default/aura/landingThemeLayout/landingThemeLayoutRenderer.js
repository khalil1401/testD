({
	afterRender : function(component, helper) {
        this.superAfterRender();
        var marginTopBody = component.find('myFixedHeaderDesktop').reduce(function (totalHeight, currentElement) {
			return totalHeight + currentElement.getElement().offsetHeight;
		}, 0);
        component.set('v.headerMarginTopInit', (marginTopBody).toString() + 'px !important;');
        var bodyHeaderFixed = component.find('bodyHeaderFixed');
		$A.util.addClass(bodyHeaderFixed, 'bodyRenderClass');
    }
})