({
    renderBody : false,
    render : function(component) {
        this.renderBody = true;
        console.log("render");
        window.setTimeout($A.getCallback(function() {
            if (component.isValid()) {
                component.set("v.renderBody", true);
            }
        }), 500);
    }
})