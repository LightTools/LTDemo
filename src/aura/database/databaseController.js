({
    callMethod : function(component, event, helper) {
        // launch database methods by name
        helper.launch(
            component,
            // method name
            event.getParam("name"),
            // method params
            event.getParam("arguments")
        );
    }
})