({
    callMethod : function(component, event, helper) {
        // call database methods by name
        helper.method(
            component,
            event.getParam("name"),
            event.getParam("arguments")
        );
    }
})