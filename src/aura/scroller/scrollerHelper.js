({
    /**
      * @description Method to add event listeners for scroll bar.
      * @param Object component - component reference.
    */
    addEventListeners : function(component) {
        try {
            // get scroll element
            let element = component.getElement();
            // add touch move event listener, just for touch devices
            element.addEventListener("touchmove", $A.getCallback(function(event) {
                if (component.isValid()) {
                    // prevent touch move event propagation
                    event.stopPropagation();
                }
            }));
            // add scroll event listener
            element.addEventListener("scroll", $A.getCallback(function(event) {
                if (component.isValid()) {
                    // execute onscroll event
                    component.getEvent("onscroll").fire({
                        "data": event
                    });
                }
            }));
        } catch(e) {
            console.error(e);
        }
    },
    /**
      * @description Method to define current position of scroll bar.
      * @param Object component - component reference.
      * @param Object position - object with two fields to define horizontal and vertical position (acceptable values: integer, "start", "end").
    */
    setPosition : function(component, position) {
        try {
            if (!$A.util.isEmpty(position)) {
                // get scroll element
                let element = component.getElement();
                // set vertical position
                if (position.hasOwnProperty("vertical")) {
                    switch (position.vertical) {
                        case "start":
                            element.scrollTop = 0;
                            break;
                        case "end":
                            element.scrollTop = element.scrollHeight;
                            break;
                        default:
                            element.scrollTop = position.vertical;
                    }
                }
                // set horizontal position
                if (position.hasOwnProperty("horizontal")) {
                    switch (position.horizontal) {
                        case "start":
                            element.scrollLeft = 0;
                            break;
                        case "end":
                            element.scrollLeft = element.scrollWidth;
                            break;
                        default:
                            element.scrollLeft = position.horizontal;
                    }
                }
            }
        } catch(e) {
            console.error(e);
        }
    },
    /**
      * @description Method to get current position of scroll bar.
      * @param Object component - component reference.
      * @return Object - object with two fields: horizontal and vertical positions.
    */
    getPosition : function(component) {
        try {
            // get scroll element
            let element = component.getElement();
            // create result
            return {
                "vertical": element.scrollTop,
                "horizontal": element.scrollLeft
            };
        } catch(e) {
            console.error(e);
        }
    },
    /**
      * @description Method to get current size (height and width) of scroll content.
      * @param Object component - component reference.
      * @return Object - object with two fields: horizontal and vertical size.
    */
    getSize : function(component) {
        try {
            // get scroll element
            let element = component.getElement();
            // create result
            return {
                "vertical": element.scrollHeight,
                "horizontal": element.scrollWidth
            };
        } catch(e) {
            console.error(e);
        }
    }
})