({
	//initialize functions
	doInit : function(component, event, helper){
		helper.retrieveOpenCases(component);
		helper.retrieveLiveAgent(component);
		helper.retrievePhoneArticle(component);
	},
	

	//redirect to the page found on the element
	redirectUrl : function(component, event, helper) {
		var selectItem = event.currentTarget;
		var pageName = selectItem.dataset.loc;
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : pageName
		});
		redirectEvent.fire();
	},
	//redirect to the page found on the element
	redirectUrlFAQ : function(component, event, helper) {
		var selectItem = event.currentTarget;
		var articleName = selectItem.dataset.loc;
		 var dataCategory = component.get('v.portalConfig.Data_category_mapping__c');
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
				"pageName" :"faq?articlename="+articleName+"&datacategory="+dataCategory
		});
		redirectEvent.fire();
	},
	
	//launch the live agent chat functionality
	launchLiveAgent : function(component, event, helper){
		//console.log(component.get('v.chatId'));
		liveagent.startChat(component.get('v.chatId'));
	
	},
	
	//redirect to the phone article page
	redirectToPhone : function(component, event, helper){
		//console.log('here');
		var articleName = component.get('v.phoneTitle');
		console.log(articleName);
        var dataCategory = component.get('v.dataCategory');
        //console.log(dataCategory);
		
		  var urlEvent = $A.get("e.c:prov_event_Redirect");
         urlEvent.setParams({
             "pageName" :"faq?articlename="+articleName+"&datacategory="+dataCategory
         });
         urlEvent.fire();
	}
	
})