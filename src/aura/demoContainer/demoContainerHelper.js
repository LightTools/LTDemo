({
	setDefaults : function(component) {
        // set default config for database query
        component.set(
            "v.databaseQueryConfig",
            JSON.stringify({
                "object": "Demo__c",
                "fields": [
                    "Name"
                ],
                "filters": [],
                "sort": [
                    "Name"
                ],
                "offset": 0,
                "limit": 5000,
                "childs": [{
                    "object": "DemoChilds__r",
                    "fields": [
                        "Name"
                    ],
                    "filters": [],
                    "sort": [
                        "Name"
                    ],
                    "limit": 5000
                }]
            }, null, 4)
        );
	},
    parseResponse : function(response) {
        let result = null;
        if (response.isSuccess) {
            result = JSON.stringify(
                response.records.slice(),
                null, 4
            );
        } else {
            result = JSON.stringify(
                response.messages.slice(),
                null, 4
            );
        }
        return result;
    }
})