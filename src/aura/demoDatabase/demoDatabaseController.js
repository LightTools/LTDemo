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
                    helper,
                    $A.getCallback(function(response) {
                        if (component.isValid()) {
                            // set describe result
                            component.set(
                                "v.databaseDescribeResponse",
                                this.parseResponse(response)
                            );
                            // hide spinner
                            this.toggleSpinner(sender, false);
                        }
                    })
                );
                break;
            case "databaseQuery":
                component.find("database").buildSOQL(
                    JSON.parse(component.get("v.databaseQueryConfig")),
                    helper,
                    $A.getCallback(function(response) {
                        if (component.isValid()) {
                            // set debug result
                            component.set(
                                "v.databaseQueryDebug",
                                this.parseDebug(response)
                            );
                            // get records
                            component.find("database").query(
                                JSON.parse(component.get("v.databaseQueryConfig")),
                                this,
                                $A.getCallback(function(response) {
                                    if (component.isValid()) {
                                        // set query result
                                        component.set(
                                            "v.databaseQueryResponse",
                                            this.parseResponse(response)
                                        );
                                        // hide spinner
                                        this.toggleSpinner(sender, false);
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
                    helper,
                    $A.getCallback(function(response) {
                        if (component.isValid()) {
                            // set debug result
                            component.set(
                                "v.databaseSearchDebug",
                                this.parseDebug(response)
                            );
                            // get records
                            component.find("database").search(
                                JSON.parse(component.get("v.databaseSearchConfig")),
                                this,
                                $A.getCallback(function(response) {
                                    if (component.isValid()) {
                                        component.set(
                                            "v.databaseSearchResponse",
                                            this.parseResponse(response)
                                        );
                                        // hide spinner
                                        this.toggleSpinner(sender, false);
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
                    helper,
                    $A.getCallback(function(response) {
                        if (component.isValid()) {
                            // set save result
                            component.set(
                                "v.databaseSaveResponse",
                                this.parseResponse(response)
                            );
                            // hide spinner
                            this.toggleSpinner(sender, false);
                        }
                    })
                );
                break;
            case "databaseRemove":
                component.find("database").remove(
                    JSON.parse(component.get("v.databaseRemoveConfig")),
                    helper,
                    $A.getCallback(function(response) {
                        if (component.isValid()) {
                            // set remove result
                            component.set(
                                "v.databaseRemoveResponse",
                                this.parseResponse(response)
                            );
                            // hide spinner
                            this.toggleSpinner(sender, false);
                        }
                    })
                );
                break;
        }
    }
})