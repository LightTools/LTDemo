({
    // describe methods

    callDescribe : function(component, event, helper) {
        helper.describe(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback,
            event.getParam("arguments").options
        );
    },

    // build methods

    callBuildSOQL : function(component, event, helper) {
        helper.buildSOQL(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback,
            event.getParam("arguments").options
        );
    },
    callBuildSOSL : function(component, event, helper) {
        helper.buildSOSL(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback,
            event.getParam("arguments").options
        );
    },

    // data methods

    callQuery : function(component, event, helper) {
        helper.query(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback,
            event.getParam("arguments").options
        );
    },
    callSearch : function(component, event, helper) {
        helper.search(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback,
            event.getParam("arguments").options
        );
    },
    callSave : function(component, event, helper) {
        helper.save(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback,
            event.getParam("arguments").options
        );
    },
    callRemove : function(component, event, helper) {
        helper.remove(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback,
            event.getParam("arguments").options
        );
    }
})