({
	//init function
	doInit : function(component, event, helper){
		//get the businesses a user is part of for the dropdown
		helper.getBusinesses(component, event, helper);
		
		//helper.retrieveLabels(component);
		helper.hasMessages(component);
		
		helper.retrieveLabels(component);
	},

	//function that fires when a user changes the business selected in the Business dropdwon
    changeBusinessContext : function(component, event, helper){
    	$A.util.addClass(component.find("saving-backdrop"), "slds-show");
    	$A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
    	//helper.setBusinessContext(component, event, helper);
    	
    	var currentTarget = event.currentTarget;
    	var accId = currentTarget.dataset.value;
    	console.log('accId::'+accId);
    	var pageName = '';
    	var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : pageName,
			'businessId' : accId,
			'newTab' : true

		});
		redirectEvent.fire();
    },
    
    closeModal:function(component,event,helper){
        var cmpTarget = component.find('navContentModal');
        var cmpBack = component.find('navBackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    openModal: function(component,event,helper) {
        var cmpTarget = component.find('navContentModal');
        var cmpBack = component.find('navBackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    
    runCollapse : function(component, event, helper){
		//console.log('inside runCollapse');
		var curTarget = event.currentTarget;
		$(curTarget).toggleClass('open');
		$(curTarget).siblings('.dropdown-collapse').toggleClass('in');
		var sibling = $(curTarget).siblings('.dropdown-collapse').get(0);
    	$('#navModalConId .dropdown-collapse.in').not(sibling).each(function(){
    		$(this).removeClass('in');
	     });
	     
	     $('#navModalConId .open').not(curTarget).each(function(){
    		$(this).removeClass('open');
	     });
	     
		event.stopPropagation();
		 
	},

    //redirects the URL when a user selects a business from the business picklist
    redirectUrl : function(component, event, helper){
    	var cmpTarget = component.find('navContentModal');
        var cmpBack = component.find('navBackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    	event.preventDefault();
    	//get all the potential variables to pass
		var selectItem = event.currentTarget;
		var pageName = selectItem.dataset.pagename;
		var memberGuid = selectItem.dataset.memberguid;
		var providerId = selectItem.dataset.providerid;
		var slId = selectItem.dataset.slid;
		var serviceDate = selectItem.dataset.servicedate;
		var businessId = selectItem.dataset.businessid;
		var refreshNav = selectItem.dataset.refreshnav;
		var searchCriteriaId = selectItem.dataset.criteriaid;
		//console.log('nav:pathname::'+window.location.pathname);
		//remove any extra parameters
		window.history.pushState("", "", window.location.pathname);
		
		if(pageName == 'message-center'){
			localStorage['message_read'] = true;
			component.set('v.hasOpenNotification', false);
		}
		//console.log('params removed');
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : pageName,
			'memberProfileGuid' :memberGuid,
			'serviceLocationId' : slId,
			'providerId' : providerId,
			'serviceDate' : serviceDate,
			'searchCriteriaId' : searchCriteriaId,
			'businessId' : businessId,
			'refreshNav' : refreshNav

		});
		console.log('fire event');
		redirectEvent.fire();
	},
	
	removeCache : function(component, event, helper){
		
		localStorage.removeItem('isAvailable');
		localStorage.removeItem('providercache');
		
		window.location.href = component.get('v.logoutURL');
	},
  
})