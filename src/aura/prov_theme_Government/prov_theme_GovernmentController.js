({
	doInit : function(component, event, helper){
		//helper.checkIncognitoWindow(component, helper);
		////console.log('out');
		//helper.loadCache(component, helper);
		//console.log('Theme init');
		helper.loadSessionId(component, helper);
		//helper.loadStaticResource(component);
		helper.setCurrentPage(component);
		
	},

	navigate: function(component, event, helper){

	},
	
	reInit : function(component, event, helper){
		//console.log('reInit...5');
		helper.reInitialize(component);
	},
	
	redirectEventHandler : function(component, event, helper){
		//console.log('redirectEventHandler...');
		var pageName = event.getParam('pageName');
		var memberProfileGuid = event.getParam('memberProfileGuid');
		var serviceLocationId = event.getParam('serviceLocationId');
		var extraParams = event.getParam('extraParams');
		var providerId = event.getParam('providerId');
		var businessId = event.getParam('businessId');
		var serviceDate = event.getParam('serviceDate');
		var portalName = event.getParam('portalName');
        var refreshNavE = event.getParam('refreshNav');
        var openInNewTab = event.getParam('newTab');
        var searchCriteriaId = event.getParam('searchCriteriaId');
        var isAvailable = component.get('v.isAvailable');
        //console.log('isavailable...');
        if(!isAvailable){//stop calling since ww is down or error in loading the cache
        	var urlEvent = $A.get("e.force:navigateToURL");
			urlEvent.setParams({
				'url' : '/error',
				'isredirect' : true
			});
			urlEvent.fire();
//			component.set('v.onUserDropdown', false);
        } else {//continue with the call
        	if(pageName == 'member-eligibility' || pageName == 'member-intervention' || pageName == 'broken-appointment' || pageName == 'panel-roster' || pageName == 'broken-appointment-list'){
				component.set('v.currTab', 'member');
			} else if(pageName == 'claim-entry' || pageName == 'claim-search' || pageName == 'claim-drafts' || pageName == 'claim-confirmation-report'){
				component.set('v.currTab', 'claim');
			} else if(pageName == 'pre-auth-entry' || pageName == 'pre-auth-search' || pageName == 'pre-auth-drafts' || pageName == 'pre-auth-confirmation-report'){
				component.set('v.currTab', 'preauth');
			}  else if(pageName == 'referral-entry' || pageName == 'referral-search' || pageName == 'referral-drafts' || pageName == 'referral-confirmation-report'){
				component.set('v.currTab', 'referral');
			} else if(pageName == 'eob-search'){
				component.set('v.currTab', 'payment');
			} else if(pageName == 'dentist-list' || pageName == 'dentist-detail' || pageName == 'service-office-detail' || pageName == 'business-detail' ||
						pageName == 'billed-amount' || pageName == 'billed-amount-detail' || pageName == 'fee-schedule' || pageName == 'reports'){
				component.set('v.currTab', 'practice');
			} else if(pageName == 'find-a-provider'){
				component.set('v.currTab', 'fad');
			} else if(pageName == 'contact-us' || pageName == 'help-request' || pageName == 'help-request-detail'){
				component.set('v.currTab', 'help');			
			} else {
				component.set('v.currTab', '');	
			}
			
			if(pageName == 'message-center'){
				localStorage['message_read'] = true;
				component.set('v.hasOpenNotification', false);
			}
			////console.log(pageName+subscriberGuid+planGuid);
			/*if(planGuid != undefined && planGuid != '' && 
				subscriberGuid != undefined && subscriberGuid != ''){
				
				var action = component.get('c.setCurrentMemberInfo');
				action.setParams({'subscriberGuid' : subscriberGuid,
								  'planGuid' : planGuid});
				action.setCallback(this, function(response){
					
					if(response.getState() == 'SUCCESS'){
						component.set('v.currSubId', subscriberGuid);
						component.set('v.currPlanId', planGuid);
	                    if(refreshNavE){
	                        var refreshNav = component.get('v.refreshNav');
	                        component.set('v.refreshNav', !refreshNav);
	                    }
	                    
						var urlEvent = $A.get("e.force:navigateToURL");
						urlEvent.setParams({
							'url' : '/'+pageName,
							'isredirect' : true
						});
						urlEvent.fire();
						helper.reInitialize(component);
						component.set('v.currPage', pageName);
						if(pageName.toLowerCase() == 'benefits' || pageName.toLowerCase() == 'id-card' || 
							pageName.toLowerCase() == 'documents' || pageName.toLowerCase() == 'history')	{
							component.set('v.onUserDropdown', true);
						} else {
							component.set('v.onUserDropdown', false);
						}
						helper.checkCache(component);
						
					}
				});
				$A.enqueueAction(action);
			} else {*/
			var fullUrl = pageName;
			var params = '';
			if(memberProfileGuid != null){
				params += 'id='+ memberProfileGuid + '&';
			}
			if(serviceLocationId != null){
				params += 'location='+ serviceLocationId + '&';
			}
			if(providerId != null){
				params += 'provider='+ providerId + '&';
			}
			if(serviceDate != null){
				params += 'date='+ serviceDate + '&';
			}
			if(searchCriteriaId != null){
				params += 'criteria=' + searchCriteriaId + '&';
			}
			if(extraParams != null){
				params += extraParams + '&';
			}
			if(fullUrl.indexOf('?') == -1)
				fullUrl += '?';
			else
				fullUrl += '&';
				
			if(params.length > 0){
				fullUrl += params;
			}
			 if(refreshNavE){
                var refreshNav = component.get('v.refreshNav');
                component.set('v.refreshNav', !refreshNav);
            }
            
            //check if it should open in a new tab 
            if(openInNewTab && openInNewTab != undefined){
            	//console.log('openInNewTab::'+openInNewTab);
            	////console.log('open a new tab');
            	//pass the current session storage in param
            	var portalConfig;var paramBusId;
            	
            	if(businessId == undefined){
            		paramBusId = sessionStorage['businessid'];
            	}else{
            		paramBusId = businessId;
           			paramBusId = paramBusId.substring(0,15);
            	}
	            
	            if(portalName == undefined)
	            	portalConfig = sessionStorage['portalconfig'];
	            else
	            	portalConfig = portalName;
            	//console.log('businessId ::'+paramBusId );
            	var portalDecoded = localStorage['param.config.'+portalConfig];
            	var businessDecoded = localStorage['param.bus.'+paramBusId];
            	//console.log('businessDecoded ::'+businessDecoded );
            	
            	fullUrl += 'pc='+portalDecoded + '&';
            	fullUrl += 'bc='+businessDecoded + '&';
            
            	//console.log('fullUrl::'+fullUrl);
            	window.open(fullUrl, '_blank');
            }else{
            	//console.log('not opening new tab');
            	fullUrl = '/'+fullUrl;
            	//console.log('fullUrl::'+fullUrl);
				var urlEvent = $A.get("e.force:navigateToURL");
				urlEvent.setParams({
					'url' : fullUrl 
				});
				//console.log('fire event...');
				urlEvent.fire();
			}
            component.set('v.currPage', pageName);
			//console.log('done...');
		}
		//$A.get("e.force:refreshView").fire();
	},
	
	showBodyText : function(component, event, helper){
        //console.log('show body text');
		helper.checkCache(component);
		component.set('v.displayPage', true);
	}
})