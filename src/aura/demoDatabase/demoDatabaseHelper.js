({
    setDefaults : function(component) {
        // set default config for database describe
        component.set(
            "v.databaseDescribeConfig",
            JSON.stringify([
                "Demo__c"
            ], null, 4)
        );
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
        // set default config for database search
        component.set(
            "v.databaseSearchConfig",
            JSON.stringify({
                "filter": "Demo",
                "group": "All",
                "entities": [{
                    "object": "Demo__c",
                    "fields": [
                        "Name",
                        "CreatedDate"
                    ],
                    "functions": {
                        "CreatedDate": "FORMAT({0})"
                    },
                    "options": ""
                }],
                "options": "",
                "crud": true,
                "fls": true,
                "sharing": true
            }, null, 4)
        );
        // set default config for database save
        component.set(
            "v.databaseSaveConfig",
            JSON.stringify({
                "records": [
                    {
                        "sObjectType": "Demo__c",
                        "RequiredField__c": "Hello world!"
                    }
                ],
                "crud": true,
                "fls": true,
                "sharing": true
            }, null, 4)
        );
        // set default config for database remove
        component.set(
            "v.databaseRemoveConfig",
            JSON.stringify({
                "items": [
                    "<recordId>",
                    "<recordId>"
                ],
                "crud": true,
                "fls": true,
                "sharing": true
            }, null, 4)
        );
    },
    parseDebug : function(response) {
        let result = null;
        if (response.isSuccess) {
            result = response.data;
        } else {
            result = JSON.stringify(
                response.messages.slice(),
                null, 4
            );
        }
        return result;
    },
    parseResponse : function(response) {
        let result = null;
        if (response.isSuccess) {
            result = JSON.stringify(
                response.hasOwnProperty("records") ?
                response.records.slice() :
                JSON.parse(response.data),
                null, 4
            );
        } else {
            result = JSON.stringify(
                response.messages.slice(),
                null, 4
            );
        }
        return result;
    },
    toggleSpinner : function(sender, state) {
        // show spinner
        sender.set(
            "v.iconName",
            state === true ? "utility:spinner" : null
        );
        // disable sender
        sender.set("v.disabled", state);
    }
})