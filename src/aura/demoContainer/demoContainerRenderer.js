({
    afterRender : function(component, helper) {
        this.superAfterRender();
        // remove slds-hidden class with 1s delay
        setTimeout($A.getCallback(function() {
            if (component.isValid()) {
                $A.util.removeClass(component.find("container"), "slds-hidden");
            }
        }), 1000);
    }
})