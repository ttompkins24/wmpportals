({
  /**************************************************************************************************************
     * Name                      : wmp_comp_DocumentController
     * Developed By              : West Monroe Partners
     * Purpose                   : To fetch the necessary information  
     *                     
     History
     Version#   Build#    Date                by                      Comments
     1.0        8.0       19th October 2017   West Monroe Partners    See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
        $A.util.toggleClass(component.find("documentContainer"), "slds-hide");
        // $A.util.toggleClass(component.find("loadingSpinner"), "slds-show");


        helper.getPortalConfig(component);

		//get the current member information
		helper.getCurrentMember(component);
		//get the current member plans information
		helper.getCurrentMemberPlans(component, helper);
		

        console.log('time to get EOBs');	
        component.set("v.Spinner", true); 

        helper.getCurrentEobs(component, helper);
	},
	
	changeInMemCov : function(component, event, helper){
		var memCovId = event.currentTarget.dataset.memcovid;
		console.log('memCovId:::'+memCovId);
		component.set('v.chosen_memCov', memCovId);
	},
	showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
       console.log('showing spinner');
        component.set("v.Spinner", true); 
   },
   // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
     console.log('hiding spinner');
        component.set("v.Spinner", true); 
    },

    //this function gets the document that has been clicked
    openEOB : function(component, event, helper){
        console.log('click');
        var eobLink = event.currentTarget.dataset.eoblink;
        var claim = event.currentTarget.dataset.claim;
        console.log('claim ' + claim);

        var name = 'Claim ' + claim;

        helper.fetchEOBDocument(component, helper, eobLink, name);
    }
})