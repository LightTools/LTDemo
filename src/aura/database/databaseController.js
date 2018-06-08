({
    // describe methods

    callDescribe : function(component, event, helper) {
        helper.describe(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback
        );
    },

    // build methods

    callBuildSOQL : function(component, event, helper) {
        helper.buildSOQL(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback
        );
    },
    callBuildSOSL : function(component, event, helper) {
        helper.buildSOSL(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback
        );
    },

    // data methods

    callQuery : function(component, event, helper) {
        helper.query(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback
        );
    },
    callSearch : function(component, event, helper) {
        helper.search(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback
        );
    },
    callSave : function(component, event, helper) {
        helper.save(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback
        );
    },
    callRemove : function(component, event, helper) {
        helper.remove(
            component,
            event.getParam("arguments").config,
            event.getParam("arguments").callback
        );
    }
})