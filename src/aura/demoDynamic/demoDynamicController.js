({
    initialize : function(component, event, helper) {
        // set title
        component.set("v.title", "Dynamic");
        // set config
        helper.setDefaults(component);
    },
    action : function(component, event, helper) {
        let sender = event.getSource();
        // select action
        switch (sender.get("v.name")) {
            case "append":
                component.find("dynamic").append(helper.parseCustomConfig(component));
                break;
            case "replace":
                component.set("v.config", helper.parseCustomConfig(component));
                break;
        }
    },
    handleResult : function(component, event, helper) {
        event.stopPropagation();
        // set result data
        component.set("v.result", helper.parseResult(event.getParam("data")));
    }
})