({
    runBatch : function(component) {
        component.set("v.runned", true);
        // clear debug
        component.set("v.debug", null);
        // get batch
        let batch = component.find("batch"),
        // get initial scope
        initialData = (
            !$A.util.isEmpty(component.get("v.scope")) ?
            component.get("v.scope").split(",").map(function(value) {
                return value.trim();
            }) :
            []
        ),
        // get chunk size
        chunkSize = parseInt(component.get("v.chunkSize")),
        // set initial iteration
        iteration = 0;
        // run batch
        batch.run({
            "start": $A.getCallback(function(scope, callback) {
                this.debug(component, "> " + batch.getStatus());
                if (component.isValid()) {
                    window.setTimeout($A.getCallback(function() {
                        if (component.isValid()) {
                            if ($A.util.isEmpty(initialData)) {
                                callback(null, true, "Scope is empty.");
                            } else {
                                // calculate values to copy part of array
                                let offset = iteration * chunkSize,
                                // copy part of array
                                currentScope = initialData.slice(offset, offset + chunkSize);
                                // debug current scope
                                this.debug(component, "scope: " + JSON.stringify(currentScope));
                                // increase iteration number
                                iteration++;
                                // return result
                                callback(currentScope, offset + chunkSize > initialData.length - 1);
                            }
                        }
                    }.bind(this)), 500);
                }
            }.bind(this)),
            "execute": $A.getCallback(function(scope, data, index, callback) {
                if (component.isValid()) {
                    this.debug(component, "> " + batch.getStatus())
                    window.setTimeout($A.getCallback(function() {
                        if (component.isValid()) {
                            // create data if it is empty
                            if ($A.util.isEmpty(data)) {
                                data = [scope[index]];
                            } else {
                                data.push(scope[index]);
                            }
                            // debug current value
                            this.debug(component, "chunk: " + scope[index]);
                            // return data, eof if current index = last element in scope
                            callback(data, index >= scope.length - 1);
                        }
                    }.bind(this)), 500);
                }
            }.bind(this)),
            "finish": $A.getCallback(function(scope, data) {
                this.debug(component, "> " + batch.getStatus());
                this.debug(component, "result: " + JSON.stringify(data.slice()));
                component.set("v.runned", false);
            }.bind(this)),
            "fail": $A.getCallback(function(method, error) {
                this.debug(component, "> " + batch.getStatus());
                this.debug(component, method + ": " + error);
                component.set("v.runned", false);
            }.bind(this)),
            "chunk": chunkSize
        });
    },
    abortBatch : function(component) {
        // get batch
        let batch = component.find("batch");
        // abort batch
        if (batch.abort()) {
            this.debug(component, "> " + batch.getStatus());
            component.set("v.runned", false);
        };
    },
    debug : function(component, log) {
        let debug = component.get("v.debug") || "";
        debug += log + "\n";
        component.set("v.debug", debug);
    }
})