({
    setDefaults : function(component) {
        // set default config
        component.set("v.customConfig", JSON.stringify([
            ["lightning:button", {
                "label": "Dynamic Created Button"
            }]
        ], null, 4));
    },
    parseCustomConfig : function(component) {
        let result = null;
        try {
            result = JSON.parse(component.get("v.customConfig"));
        } catch(e) {
            // keep result null
        }
        return result;
    },
    parseResult : function(result) {
        return JSON.stringify(result, null, 4);
    }
})