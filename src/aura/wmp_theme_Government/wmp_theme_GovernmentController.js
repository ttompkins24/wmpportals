({
	doInit : function(component, event, helper){
        console.log('init');
		helper.loadStaticResource(component);
		helper.setCurrentPage(component);
		helper.helperLoadSubId(component);
		helper.helperLoadPlanId(component);
		/*ga('send', {
		  hitType: 'pageview',
		  location: 'TXMember'
		});*/
		
	},
	
	reInit : function(component, event, helper){
		console.log('reInit...5');
		helper.reInitialize(component);
	},
	
	redirectEventHandler : function(component, event, helper){
		console.log('redirectEventHandler...');
		var pageName = event.getParam('pageName');
		var subscriberGuid = event.getParam('subscriberGuid');
		var planGuid = event.getParam('planGuid');
        var refreshNavE = event.getParam('refreshNav');
        var isAvailable = component.get('v.isAvailable');
        if(!isAvailable){//stop calling since ww is down or error in loading the cache
        	var urlEvent = $A.get("e.force:navigateToURL");
			urlEvent.setParams({
				'url' : '/error',
				'isredirect' : true
			});
			urlEvent.fire();
			component.set('v.onUserDropdown', false);
        } else {//continue with the call
			//console.log(pageName+subscriberGuid+planGuid);
			if(planGuid != undefined && planGuid != '' && 
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
			} else {
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
				component.set('v.currPage', pageName);
				if(pageName.toLowerCase() == 'benefits' || pageName.toLowerCase() == 'id-card' || 
					pageName.toLowerCase() == 'documents' || pageName.toLowerCase() == 'history')	{
					component.set('v.onUserDropdown', true);
				} else {
					component.set('v.onUserDropdown', false);
				}
				
				
			}
		}
		//$A.get("e.force:refreshView").fire();
	},
	
	showBodyText : function(component, event, helper){
		// store the name of the Analytics object
		/*window.GoogleAnalyticsObject = 'ga';
		// check whether the Analytics object is defined
		if (!('ga' in window)) {
		    // define the Analytics object
		    window.ga = function() {
		        // add the tasks to the queue
		        window.ga.q.push(arguments);
		    };
		
		    // create the queue
		    window.ga.q = [];
		}
		// store the current timestamp
		window.ga.l = (new Date()).getTime();
		window.ga_debug = { trace: true };
		*/
		//console.log('complete...1');
		/*gtag('config', 'UA-108547920-1', {
		  'custom_map': {'1': 'TXMember'}
		});*/
		//gtag('set', {'PortalName': 'TXMember'}); 
		
        /*
        
		ga('set', {'PortalName': 'TXMember'});
//		gtag('set', {'user_id': 'USER_ID2'});
		ga('set', 'userId', 'USER_ID'); 
		ga('send', 'pageview');
        
        */
        console.log('showBodyText');
		helper.checkCache(component);
		component.set('v.displayPage', true);
		console.log('complete...');
	}
})