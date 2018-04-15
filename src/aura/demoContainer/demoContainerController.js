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
                component.find("database").buildSOQL(
                    JSON.parse(component.get("v.databaseQueryConfig")),
                    $A.getCallback(function(response) {
                        if (component.isValid()) {
                            // set debug result
                            component.set(
                                "v.databaseQueryDebug",
                                helper.parseDebug(response)
                            );
                            // get records
                            component.find("database").query(
                                JSON.parse(component.get("v.databaseQueryConfig")),
                                $A.getCallback(function(response) {
                                    if (component.isValid()) {
                                        // set query result
                                        component.set(
                                            "v.databaseQueryResponse",
                                            helper.parseResponse(response)
                                        );
                                        // hide spinner
                                        toggleSpinner(false);
                                    }
                                })
                            );
                        }
                    })
                );
                break;
            case "databaseSearch":
                component.find("database").buildSOSL(
                    JSON.parse(component.get("v.databaseSearchConfig")),
                    $A.getCallback(function(response) {
                        if (component.isValid()) {
                            // set debug result
                            component.set(
                                "v.databaseSearchDebug",
                                helper.parseDebug(response)
                            );
                            // get records
                            component.find("database").search(
                                JSON.parse(component.get("v.databaseSearchConfig")),
                                $A.getCallback(function(response) {
                                    if (component.isValid()) {
                                        component.set(
                                            "v.databaseSearchResponse",
                                            helper.parseResponse(response)
                                        );
                                        // hide spinner
                                        toggleSpinner(false);
                                    }
                                })
                            );
                        }
                    })
                );
                break;
        }
    }
})