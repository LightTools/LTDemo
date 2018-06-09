({
    initialize : function(component, event, helper) {
        helper.setDefaults(component);
    },
    action : function(component, event, helper) {
        let sender = event.getSource();
        // show spinner
        helper.toggleSpinner(sender, true);
        // select action
        switch (sender.get("v.name")) {
            case "databaseDescribe":
                component.find("database").describe(
                    JSON.parse(component.get("v.databaseDescribeConfig")),
                    $A.getCallback(function(response) {
                        if (component.isValid()) {
                            component.set(
                                "v.databaseDescribeResponse",
                                helper.parseResponse(response)
                            );
                            // hide spinner
                            helper.toggleSpinner(sender, false);
                        }
                    })
                );
                break;
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
                                        helper.toggleSpinner(sender, false);
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
                                        helper.toggleSpinner(sender, false);
                                    }
                                })
                            );
                        }
                    })
                );
                break;
            case "databaseSave":
                component.find("database").save(
                    JSON.parse(component.get("v.databaseSaveConfig")),
                    $A.getCallback(function(response) {
                        if (component.isValid()) {
                            component.set(
                                "v.databaseSaveResponse",
                                helper.parseResponse(response)
                            );
                            // hide spinner
                            helper.toggleSpinner(sender, false);
                        }
                    })
                );
                break;
            case "databaseRemove":
                component.find("database").remove(
                    JSON.parse(component.get("v.databaseRemoveConfig")),
                    $A.getCallback(function(response) {
                        if (component.isValid()) {
                            component.set(
                                "v.databaseRemoveResponse",
                                helper.parseResponse(response)
                            );
                            // hide spinner
                            helper.toggleSpinner(sender, false);
                        }
                    })
                );
                break;
        }
    }
})