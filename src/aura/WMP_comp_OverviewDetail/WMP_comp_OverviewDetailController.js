({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# current member from cache class
     * 											# Other information that needs to be displayed on the page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			19th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
        //helper.setTextVariables(component);
		//fetch the logged in user
		helper.getLoggedInUser(component,helper);
		//helper to get the config to replace find a dentist text
		helper.helperLoadConfig(component);
		//fetch the overview information
		helper.getOverviewInformation(component, helper);
		 //helpbox
        /*$('html').not( $('.helpIcon') ).click(function(){
                $('.helpBox').removeClass('in');
        });*/
	},
	/**************************************************************************************************************
     * Method Name							: openModal
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# ensuring that the modal opens for the clicked account
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			25th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	openModal : function(component, event, helper){
		//getting the clicked provider id from the dataset of the clicked event
		var providerId = event.currentTarget.dataset.providerid;
		var providerName = event.currentTarget.dataset.providername;
		
		//now creating the modal to create the modal and reusing wmp_comp_modal
		$A.createComponent(
			"c:WMP_comp_Modal",
			{
				'value' : providerId,
				'typeName': 'RECDETAIL',
				'headerText' : providerName
			},
			function(modalPopUp, status, errorMessage){
				if(status === "SUCCESS"){
					var body = component.get("v.body");
	                body.push(modalPopUp);
	                component.set("v.body", body);
				}else if (status === "ERROR") {
					component.set("v.bln_isError",true);
					component.set("v.str_errorMsg",$A.get("$Label.c.Portal_Error_Message"));
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
			}
		);
	},
	/**************************************************************************************************************
     * Method Name							: redirectView
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To get the member id and the plan id to redirect the user to the respective page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			25th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	redirectView : function (component, event, helper){
		//get the member id and plan id
		var memberId = event.currentTarget.dataset.memberid;
		var planId = event.currentTarget.dataset.planid;
		var pageName = event.currentTarget.dataset.pagename;
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
			   'subscriberGuid' : memberId,
		       'planGuid' : planId,
		       'pageName' : pageName
		});
		redirectEvent.fire();

	},

	openHelpBox : function(component, event, helper) {
		console.log('in openHelpBox');
		var curTarget = event.currentTarget;
				console.log('current target' + curTarget);

		$(curTarget).siblings('.helpBox').toggleClass('in');
    },
    
    closeHelpBox : function(component, event, helper) {
		console.log('in closeHelpBox');
		var curTarget = event.currentTarget;
		$(curTarget).parents('.helpBox').removeClass('in');
    }
})