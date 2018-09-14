({
    initialize : function(component, event, helper) {
        helper.addEventListeners(component);
    },
    destroy : function(component, event, helper) {
        helper.removeEventListeners(component);
    },
    callMethod : function(component, event, helper) {
        switch (event.getParam("name")) {
            case "setPosition":
                helper.setPosition(
                    component,
                    event.getParam("arguments").position
                );
                break;
            case "getPosition":
                return helper.getPosition(component);
                break;
            case "getSize":
                return helper.getSize(component);
                break;
        }
    }
})