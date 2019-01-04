({
	doInit : function(component, event, helper) {
        //console.log('***********************************************');
//        console.log('homepage init');
		component.set('v.notifLoading', true);
		component.set('v.eventLoading', true);
//		console.log('contact ' + JSON.stringify(component.get('v.currentContact')));
//		console.log('contact task starter ' + component.get('v.currentContact.Default_Dashboard_Starter_Task__c'));
        try{
            helper.retrieveBanner(component);
            helper.recentMessages(component);
            helper.recentEvents(component);
            helper.setDefaultTaskStarter(component);
        } catch (err){
            //console.log('error: ' + err);
        }
	},
	
	switchTaskStarter : function(component, event, helper) {
        //console.log('homepage switch');
        //$A.util.toggleClass(component.find('searchSpinnerId_home'), 'slds-show');
       // $A.util.toggleClass(component.find('searchSpinnerId_home'), 'slds-hide');
		var currentTarget = event.currentTarget;
		var tabName = currentTarget.dataset.tabname;
		//console.log('tabname::'+tabName);

        component.set('v.taskStarter' , tabName);
        //$A.util.toggleClass(component.find('searchSpinnerId_home'), 'slds-show');
       /// $A.util.toggleClass(component.find('searchSpinnerId_home'), 'slds-hide');
	},
	
	//redirects the URL when a user selects a business from the business picklist
    redirectUrl : function(component, event, helper){
        //console.log('homepage redirect');
    	event.preventDefault();
    	//get all the potential variables to pass
		var selectItem = event.currentTarget;
		var pageName = selectItem.dataset.pagename;
		window.history.pushState("", "", window.location.pathname);
		
		
		//console.log('params removed');
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : pageName
		});
		redirectEvent.fire();
	},
	
	launchEventModal : function(component, event, helper){
        //console.log('homepage modal');
		var target = event.currentTarget;
		var recid = target.dataset.value;
		
		var eventList = component.get('v.eventList');
		
		for(var i in eventList){
			if(eventList[i].eventId == recid){
				$A.createComponent(
						'c:prov_common_Modal',
						{
							'value' : eventList[i].messageContent,
							'typeName' : 'TEXT',
							'headerText' : eventList[i].messageContentHeader
						},
						function(newModal, status, errorMessage){
							//Add the new button to the body array
							if (status === "SUCCESS") {
								//push the modal onto the page for it to be displayed
								var body = component.get("v.body");
								body.push(newModal);
								component.set('v.body', body);
							}
						}
				);
			}
		}
	},
})