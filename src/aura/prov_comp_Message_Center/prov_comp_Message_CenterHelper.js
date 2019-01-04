({
	getMessages : function(component, pageNum, sortField, sortDirection) {
		var currentBusinessId = component.get('v.currentBusinessId');
        var action = component.get("c.getMessagesApex");

        var params = {
            currentBusinessId : currentBusinessId,
            pageNum : ''+pageNum,
            sortField : sortField,
            sortDirection : sortDirection,
            pageSize : ''+component.get('v.pageSize')
        };  
        var helper = this;  

        action.setParams(params);  
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(state === "SUCCESS"){    
                var data = response.getReturnValue();
                //console.log('### got messages: ' + JSON.stringify(data));
                component.set('v.messages', data.messages);
                component.set('v.totalPages', Math.ceil(data.totalPages / component.get('v.pageSize')));
                localStorage['message_read'] = true;
            } else {  
                //console.log('error');
            } 
            $A.util.addClass(component.find("loadingSpinner"), "slds-hide");

        });

        $A.enqueueAction(action);
	}
})