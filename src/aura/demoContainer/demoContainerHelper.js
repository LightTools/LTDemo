({
	setDefaults : function(component) {
        // set default config for database query
        component.set(
            "v.databaseQueryConfig",
            JSON.stringify({
                "object": "Demo__c",
                "fields": [
                    "Id",
                    "Name",
                    "CreatedDate"
                ],
                "functions": {
                    "CreatedDate": "FORMAT({0})"
                },
                "filter": "",
                "grouping": "",
                "sort": "",
                "offset": 0,
                "limit": 5000,
                "options": "",
                "crud": true,
                "fls": true,
                "sharing": true,
                "childs": [{
                    "object": "DemoChilds__r",
                    "fields": [
                        "Name"
                    ],
                    "limit": 5000,
                    "crud": true
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