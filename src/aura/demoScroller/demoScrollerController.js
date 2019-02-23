({
    initialize : function(component, event, helper) {
        // set title
        component.set("v.title", "Scroller");
        // set config
        helper.setDefaults(component);
    },
    handleScroll : function(component, event) {
        let eventData = event.getParam("data");
        // set position values
        component.set("v.position", {
            "horizontal": eventData.target.scrollLeft,
            "horizontalOffset": eventData.target.scrollLeft + eventData.target.clientWidth,
            "vertical": eventData.target.scrollTop,
            "verticalOffset": eventData.target.scrollTop + eventData.target.clientHeight
        });
        // set scroll size
        component.set("v.size", component.find("scroller").getSize());
    },
    setPosition : function(component, event) {
        let scroller = component.find("scroller");
        switch (event.getSource().get("v.value")) {
            case "horizontalStart":
                scroller.setPosition({ "horizontal": "start" });
                break;
            case "horizontalEnd":
                scroller.setPosition({ "horizontal": "end" })
                break;
            case "verticalStart":
                scroller.setPosition({ "vertical": "start" })
                break;
            case "verticalEnd":
                scroller.setPosition({ "vertical": "end" })
                break;
        }
    }
})