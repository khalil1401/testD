({
    openDropdown : function(component, event, helper) {
        component.set("v.dropdownIsTrue", true);
    },
    closeDropdown : function(component, event, helper) {
        component.set("v.dropdownIsTrue", false);
    },
})