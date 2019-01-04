({
	getEvents : function(component, event, helper) {
		var action = component.get("c.getEventsApex");
        var businessId = component.get('v.currentBusinessId');
        var params = {
            businessId : businessId,
            pageNumS : '' + component.get('v.pageNum')
        };  

        var helper = this;  

        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                console.log('### got data: ' + JSON.stringify(data));


                data.events = data.events;
                component.set('v.events', data.events);
                component.set('v.totalPages', Math.ceil((data.totalSize / data.pageSize)));
            } 
            component.set('v.isLoading', false);
        });

        $A.enqueueAction(action);
	}
})