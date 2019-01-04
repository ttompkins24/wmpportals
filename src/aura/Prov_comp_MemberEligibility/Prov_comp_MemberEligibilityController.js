({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: West Monroe Partners
     * Purpose								: To fetch the necessary information  
     *										 
     History
     Version#		Sprint#		Date				by  						Comments
	 1.0			1.0			2 Jan 2018			West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
    doInit : function(component, event, helper) {
    	//console.log('do INIT...');
    	if(component.get('v.params.showpage') != 'sc'){
    		//turn on search section
    		component.set("v.showSearch", true);
    	} else {
            //turn on search criteria
    		component.set('v.showSearchCriteria', true);
    		window.history.pushState("", "", window.location.pathname);
    	}

    	if(component.get('v.isHomepage') == true){
    		//console.log('in default tab section');
    		var defaultTab = component.get('v.currentContact.Default_Dashboard_Starter_Task__c');
    		//console.log('defaultTab ' + defaultTab);
    		if(defaultTab == 'Eligibility'){
    			//console.log('marking as default tab');
    			component.set('v.defaultTab', true);
    		}
    	}

    	//console.log('member eligibility done');
    },

    //turns off search section and on manage search section
    openManageSearchPage : function(component, event, helper){
    	component.set("v.showSearch", false);
    	component.set("v.showSearchCriteria", true);

    },

    //fires when the "Your Saved Searches" button is clicked
    //opens the modal
	launchModal : function(component, event, helper){
		$A.createComponent(
			'c:prov_comp_SearchCriteria_Modal',
			{},
			function(newModal, status, errorMessage){
				//Add the new button to the body array
				if (status === "SUCCESS") {
					var body = component.get("v.body");
					body.push(newModal);
					component.set('v.body', body);
				}
			}
		);
	},

	//prints the screen view when print button is clicked on the Results page
	printScreen : function(component, event, helper){
		//console.log('printing');
		window.print();
	}, 
	
	//turns off the results section and turns on the search section
	backToSearchResults: function(component, event, helper){
		component.set("v.showSearch", true);
		component.set("v.showResults", false);
	},
	setDefaultTab :function (component, event, helper) {
		//console.log('time to set the default tab');
		var tabName;
		var defaultTab = component.get('v.defaultTab');
		//console.log('defaultTab ' + defaultTab);
		if(defaultTab == true){
			tabName = 'Eligibility';
		} else {
			tabName = '';
		}
		helper.setDefaultTab(component, tabName);
	}
})