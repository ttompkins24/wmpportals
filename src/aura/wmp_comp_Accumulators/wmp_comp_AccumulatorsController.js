({
	/**************************************************************************************************************
     * Name									: wmp_comp_AccumulatorsController
     * Developed By							: West Monroe Partners
     * Purpose								: To fetch the necessary information  
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			8.0			19th October 2017		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
    //load the accumulator data for the current member
	doInit : function(component, event, helper) {
		helper.fetchAccumulators(component, helper);
	},
	
	//reload accumulator data, happens when plan is switched
	reloadAccumulators : function(component, event, helper){
		helper.fetchAccumulators(component, helper);
	},
	//Opens the pop up when the question mark icon is clicked
	openHelpBox : function(component, event, helper) {
		console.log('in openHelpBox');
		var curTarget = event.currentTarget;
		console.log('current target' + curTarget);
		$(curTarget).siblings().toggleClass('in');
    },

    //closes the pop up
    closeHelpBox : function(component, event, helper) {
		console.log('in closeHelpBox');
		var curTarget = event.currentTarget;
		$(curTarget).parents().removeClass('in');
    }
})