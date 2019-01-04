({
	//initialize functions
	doInit : function(component, event, helper){
		helper.retrieveOpenCases(component);
		helper.retrieveLiveAgent(component);
		helper.retrievePhoneArticle(component);

        //getting the portal config information
		helper.getPortalConfig(component, event, helper);
	},

	//redirect to the page found on the element
	redirectUrl : function(component, event, helper) {
		var selectItem = event.currentTarget;
		var pageName = selectItem.dataset.loc;
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
						'pageName' : pageName
		});
		redirectEvent.fire();
	},
	
	//launch the live agent chat functionality
	launchLiveAgent : function(component, event, helper){
		console.log(component.get('v.chatId'));
		liveagent.startChat(component.get('v.chatId'));
	
	},
	
	//redirect to the phone article page
	redirectToPhone : function(component, event, helper){
		var articleName = component.get('v.phoneTitle');
		var dataCategory = component.get('v.dataCategory');
		
		 var urlEvent = $A.get("e.force:navigateToURL");
		 urlEvent.setParams({
			 "url":"/faq?articlename="+articleName+"&datacategory="+dataCategory
		 });
		 urlEvent.fire();
	}
	
})