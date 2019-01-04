({
	//destroys component
	defaultClose : function(component, event, helper){
        component.destroy();
    },
    
    //calls helper method to save the search criteria
	saveSearch : function(component, event, helper) {
		component.set('v.isError', false);
		helper.saveSearch(component, event, helper);
	},
	
})