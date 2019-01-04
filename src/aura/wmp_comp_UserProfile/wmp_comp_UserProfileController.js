({
	doInit : function(component, event, helper) {
		helper.initLanguage(component);
		helper.getName(component);
	},

    runCollapse : function(component, event, helper){
		//console.log('inside runDropdown ');
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
    
    changeLanguage : function(component, event, helper){
    	//get the current selected language
    	var lang = component.get('v.lang');
    	
    	//get the selected id aura:id which will tell you the language selected
    	var currTarget = event.currentTarget;
    	var scId = currTarget.dataset.id;
    	
    	//if lang is different that the selected lang then update the lang on the user record
    	if(lang != scId ){
    		var action = component.get('c.setLanguage');
    		action.setParams({'langSelected': scId});
    		action.setCallback(this, function(response){
    			var state = response.getState();
    			if(state == 'SUCCESS'){
    				window.location.reload();
    			}
    		});
    		
    		$A.enqueueAction(action);
    	}
    },
    
    redirectUrl : function(component, event, helper){
		var selectItem = event.currentTarget;
		var pageName = selectItem.dataset.loc;
		var subId = '';
		var planId = '';
		
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
						'pageName' : pageName
		});
		redirectEvent.fire();
		
        $('.navModalPopup').removeClass('slds-fade-in-open');
		$('.slds-backdrop').removeClass('slds-backdrop--open');
	},
	
})