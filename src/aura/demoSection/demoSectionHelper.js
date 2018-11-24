({
    showMessage : function(component, message) {
        // set message text
        component.set("v.message", message);
        // clear old timeout
        window.clearTimeout(component.get("v.timeout"));
        // set new timeout
        component.set("v.timeout", window.setTimeout($A.getCallback(function() {
            if (component.isValid()) {
                component.set("v.message", null);
            }
        }), 2000));
    }
})