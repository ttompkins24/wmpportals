({
	NUM_RESULTS : 10,

	/**
     * Get service history records
     * configure paging from client
     */
	getHistory : function(component, memberGuid) {

		var action = component.get("c.getHistoryApex");		

        var plans = component.get('v.plans');
        var planGuids = [];

        // grab all the plan guid winward ids
		plans.forEach(function(entry) {
			planGuids.push(entry.windward_guid__c);
		});

		var params = { 
        	"memberGuid" 	: memberGuid, 
        	"planGuids" 	: planGuids, 
        	"pageNumS" 		: ''+component.get('v.pageNum'), 
        	"numResultsS" 	: ''+this.NUM_RESULTS, 
        	"sortByField" 	: component.get('v.fieldNameSorted'), 
        	"sortDirection" : component.get('v.sortDirection')
        };

        action.setParams(params);

        action.setCallback(this, function(response) {
	        var state = response.getState();
	        if(state === "SUCCESS"){    
	            var data = response.getReturnValue();
	           	//console.log('### got data: ' + JSON.stringify(data));
	           	//console.log('date services size' + data.services.length);
	           	var paid_services = [];
	           	data.services.forEach(function(entry) {
	           		if(entry.ServiceLineStatus__c == 'Paid') {
	           			paid_services.push(entry);
	           		}
	           	});
                //console.log('paid services size' + paid_services.length);
	            component.set('v.services', paid_services);
	            component.set('v.totalResults', data.totalResults);
	            component.set('v.totalPages', Math.ceil(data.totalResults / this.NUM_RESULTS));
	        } 
	        
	        $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
	        $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
            $A.util.removeClass(component.find("saving-backdrop"), "slds-is-fixed");
	        component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);		
	}
})