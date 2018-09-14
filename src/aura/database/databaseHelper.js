({
    /**
      * @description Common method to call database methods by name.
      * @param Object component - component reference.
      * @param String name - Apex method name.
      * @param Object params - set of parameters for method.
    */
    launch : function(component, name, params) {
        // call apex method from controller
        this.callApex(
            component,
            // set method name
            name,
            // set method callback
            this.getCallback(component, params, (
                ["query", "search", "save"].indexOf(name) !== -1 // identify query, search and save methods and use wrapping for them
            )),
            // set method params
            this.wrapParams(params),
            // set method options
            params.options
        );
    },
    /**
      * @description Method to create callback for database methods. 
      * @param Object component - component reference.
      * @param Object params - set of parameters to create callback method.
      * @param Boolean wrapping - whether to use wrap feature.
    */
    getCallback : function(component, params, wrapping) {
        // return callback
        return $A.getCallback(function(response) {
            if (component.isValid()) {
                try {
                    // if callback is not empty
                    if (!$A.util.isEmpty(params.callback)) {
                        // return result with callback
                        params.callback(
                            // if need to user wrapping
                            wrapping === true ?
                            // wrap response
                            this.wrapResponse(response) :
                            // return original response
                            response
                        );
                    }
                } catch(e) {
                    console.error(e);
                }
            }
        }.bind(this));
    },
    /**
      * @description Method to create parameters for Apex method.
      * @param Object params - set of parameters to create callback method.
    */
    wrapParams : function(params) {
        return {
            "config": (
                // if config is not empty and not null
                !$A.util.isEmpty(params.config) ?
                // convert config to JSON
                JSON.stringify(params.config) :
                // or just return null as config
                null
            )
        };
    },
    /**
      * @description Method to wrap records inside database response.
      * @param Object response - data from Apex.
    */
    wrapResponse : function(response) {
        // create empty result
        let records = [];
        // parse response data
        try {
            // if data exists in the response
            if (response.hasOwnProperty("data") &&
                    !$A.util.isEmpty(response.data)) {
                // parse data items
                for (let dataItem of JSON.parse(response.data)) {
                    // for search result
                    if (dataItem.hasOwnProperty("length")) {
                        let dataItemChilds = [];
                        for (let dataItemChild of dataItem) {
                            dataItemChilds.push(this.wrapRecord(dataItemChild));
                        };
                        records.push(dataItemChilds);
                    } else { // for query result
                        records.push(this.wrapRecord(dataItem));
                    }
                };
            }
        } catch(e) {
            console.error(e);
        } finally {
            // add records to response and return
            return Object.assign(response, {
                "records": records
            });
        }
    },
    /**
      * @description Method to wrap a record.
      * @param Object source - original record.
    */
    wrapRecord : function(source) {
        // create empty result
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
                for (let child of fieldValue.records) {
                    childs.push(this.wrapRecord(child));
                };
                // set childs
                result[field] = childs;
            } else if (fieldValue.hasOwnProperty("attributes")) { // for reference fields
                result[field] = this.wrapRecord(fieldValue);
            } else { // for simple fields
                result[field] = fieldValue;
            }
        }
        return result;
    }
})