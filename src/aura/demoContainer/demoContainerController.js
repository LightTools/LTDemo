({
    handleContentChange : function(component, event, helper) {
        // add class to content block
        $A.util.addClass(component.find("content"), "ready");
    }
})