({
    // describe methods

    /**
      * @description Method to build SOQL query string.
      * @param Object component - component reference.
      * @param Object config - this object should contain object name, object fields and query conditions for SOQL.
      * @param Object callback - external function to handle response from server.
    */
    describe : function(component, config, callback) {
        // call apex method from controller
        this.callApex(component, "describe", callback, {
            "config": JSON.stringify(config || [])
        });
    },

    // build methods

    /**
      * @description Method to build SOQL query string.
      * @param Object component - component reference.
      * @param Object config - this object should contain object name, object fields and query conditions for SOQL.
      * @param Object callback - external function to handle response from server.
    */
    buildSOQL : function(component, config, callback) {
        // call apex method from controller
        this.callApex(component, "buildSOQL", callback, {
            "config": JSON.stringify(config || {})
        });
    },
    /**
      * @description Method to build SOSL query string.
      * @param Object component - component reference.
      * @param Object config - this object should contain search text, search entities and query conditions for SOSL.
      * @param Object callback - external function to handle response from server.
    */
    buildSOSL : function(component, config, callback) {
        // call apex method from controller
        this.callApex(component, "buildSOSL", callback, {
            "config": JSON.stringify(config || {})
        });
    },

    // data methods

    /**
      * @description Method to create callback for query and search.
      * @param Object component - component reference.
      * @param Object callback - external function to handle response from server.
    */
    callback : function(component, callback) {
        // inner methods
        let createRecord = function(source) {
            let result = {};
            // check each field in the source record
            for (let field in source) {
                // get current field value
                let fieldValue = source[field];
                // identify field value
                if (fieldValue.hasOwnProperty("type")) { // for attributes of main record
                    // set object type
                    result["sObjectType"] = fieldValue.type;
                } else if (fieldValue.hasOwnProperty("records")) { // for child relationships
                    // create empty array of childs
                    let childs = [];
                    // parse childs
                    fieldValue.records.forEach(function(child) {
                        childs.push(createRecord(child));
                    });
                    // set childs
                    result[field] = childs;
                } else if (fieldValue.hasOwnProperty("attributes")) { // for reference fields
                    result[field] = createRecord(fieldValue);
                } else { // for simple fields
                    result[field] = fieldValue;
                }
            }
            return result;
        };
        // return callback
        return $A.getCallback(function(response) {
            if (component.isValid()) {
                // create empty result
                let records = [];
                // parse response data
                try {
                    // if data exists in the response
                    if (response.hasOwnProperty("data") &&
                            !$A.util.isEmpty(response.data)) {
                        // parse data items
                        JSON.parse(response.data).forEach(function(dataItem) {
                            // for search result
                            if (dataItem.hasOwnProperty("length")) {
                                let dataItemChilds = [];
                                dataItem.forEach(function(dataItemChild) {
                                    dataItemChilds.push(createRecord(dataItemChild));
                                });
                                records.push(dataItemChilds);
                            } else { // for query result
                                records.push(createRecord(dataItem));
                            }
                        });
                    }
                } catch(e) {
                    console.error(e);
                } finally {
                    // if callback exists
                    if (!$A.util.isEmpty(callback)) {
                        // add records to the response and return
                        callback(Object.assign(
                            response, {
                                "records": records
                            }
                        ));
                    }
                }
            }
        });
    },
    /**
      * @description Method to get records from server using SOQL query.
      * @param Object component - component reference.
      * @param Object config - this object should contain object name, object fields and query conditions for SOQL.
      * @param Object callback - external function to handle response from server.
    */
    query : function(component, config, callback) {
        // call apex method from controller
        this.callApex(component, "query", this.callback(component, callback), {
            "config": JSON.stringify(config || {})
        });
    },
    /**
      * @description Method to get records from server using SOSL query.
      * @param Object component - component reference.
      * @param Object config - this object should contain search text, search entities and query conditions for SOSL.
      * @param Object callback - external function to handle response from server.
    */
    search : function(component, config, callback) {
        // call apex method from controller
        this.callApex(component, "search", this.callback(component, callback), {
            "config": JSON.stringify(config || {})
        });
    }
})