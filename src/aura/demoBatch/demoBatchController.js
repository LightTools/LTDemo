({
    initialize : function(component, event, helper) {
        // set title
        component.set("v.title", "Batch");
    },
    action : function(component, event, helper) {
        let sender = event.getSource();
        // select action
        switch (sender.get("v.name")) {
            case "run":
                helper.runBatch(component);
                break;
            case "abort":
                helper.abortBatch(component);
                break;
        }
    }
})