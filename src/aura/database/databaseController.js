({
	callQuery : function(component, event, helper) {
		helper.query(
			component,
			event.getParam("arguments").config,
            event.getParam("arguments").callback
		);
	}
})