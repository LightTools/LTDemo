({
	initialize : function(component, event, helper) {
        helper.setDefaults(component);
	},
    action : function(component, event, helper) {
        let sender = event.getSource(),
        // inner methods
        toggleSpinner = function(state) {
            // show spinner
            sender.set(
                "v.iconName",
                state === true ? "utility:spinner" : null
            );
            // disable sender
            sender.set("v.disabled", state);
        }
        // show spinner
        toggleSpinner(true);
        // select action
        switch (sender.get("v.name")) {
            case "databaseQuery":
                component.find("database").query(
                    JSON.parse(component.get("v.databaseQueryConfig")),
                    $A.getCallback(function(response) {
                        if (component.isValid()) {
                            component.set(
                                "v.databaseQueryResponse",
                                helper.parseResponse(response)
                            );
                            // hide spinner
                            toggleSpinner(false);
                        }
                    })
                );
                break;
        }
    }
})