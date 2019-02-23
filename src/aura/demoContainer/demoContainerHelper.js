({
    setPhotoUrl : function(component) {
        component.set("v.photoURL", "https://media.licdn.com/dms/image/C4D03AQHfjpNcJwunjw/profile-displayphoto-shrink_200_200/0?e=1554336000&v=beta&t=RdY4U8Tz7H3qZQt50Rs2B-U98_JcVztwIWNRGHQyCWg");
    },
    createDemoItems : function(component) {
        // create a list of demo items with 3s delay
        window.setTimeout($A.getCallback(function() {
            if (component.isValid()) {
                component.set("v.demoItems", [
                    ["c:demoDatabase"],
                    ["c:demoBatch"],
                    ["c:demoScroller"],
                    ["c:demoChart"],
                    ["c:demoDynamic"],
                    ["c:demoSection"],
                    ["c:demoSpinner"]
                ]);
            }
        }), 3000);
    }
})