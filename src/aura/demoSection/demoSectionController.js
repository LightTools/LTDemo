({
    sectionToggle : function(component, event, helper) {
        event.stopPropagation();
        // show message
        helper.showMessage(component, (
            event.getSource().get("v.expanded") === true ?
            "Expanded" :
            "Collapsed" 
        ) + " Section");
    },
    buttonClick : function(component, event, helper) {
        event.stopPropagation();
        // show message
        helper.showMessage(component, "Clicked " + event.getSource().get("v.title"));
    }
})