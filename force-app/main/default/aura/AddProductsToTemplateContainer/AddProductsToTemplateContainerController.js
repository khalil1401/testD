({
    closeWindow : function(component, event, helper) {
        console.log('Aura component');
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
})