({
	/*** Method to load the current member subscriber id*****/
	helperLoadSubId : function(component){
		var action= component.get('c.getSubscriberId');
		
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var subId = response.getReturnValue();
				component.set('v.currSubId', subId);
			}
		});
		
		$A.enqueueAction(action);
	
	},
	/*** Method to load the current member plan id*****/
	helperLoadPlanId : function(component){
		var action= component.get('c.getPlanGUID');
		
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var planId = response.getReturnValue();
				component.set('v.currPlanId', planId);
			}
		});
		
		$A.enqueueAction(action);
	
	},
	
	/***** METHOD to retrieve the current page that the user is on *****/
	setCurrentPage : function(component) {
		var pathname = window.location.pathname;//ex = /member/s/home?id=9234
		var params = pathname.split('?');//ex ['/member/s/home', 'id=9234']
		var locs = params[0].split('/'); //ex [ ,member,s,home]
		
		var pageRef = locs[3];//ex home
		
		if(pageRef == null){
			component.set('v.currPage', pageRef);
		}else{
			component.set('v.currPage', pageRef.toLowerCase());
			
			if(pageRef.toLowerCase() == 'benefits' || pageRef.toLowerCase() == 'id-card' || 
					pageRef.toLowerCase() == 'documents' || pageRef.toLowerCase() == 'history')	{
				component.set('v.onUserDropdown', true);
			} 
		}
	},
	/*********** Method for the reinitialize for the page components *********************/
	reInitialize : function(component){
		this.setCurrentPage(component);
		this.helperLoadSubId(component);
		this.helperLoadPlanId(component);
	},
	
	/****METHOD TO LOAD THE PORTAL CONFIGURATION RECORD **/
	loadStaticResource : function(component){
		console.log('loadStaticResource....');
		var action = component.get('c.getPortalConfiguration');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var portalConfig = response.getReturnValue();
				
				component.set('v.staticResource', portalConfig.Static_Resource_Name__c);
				component.set('v.staticResourcePicked', true);
				
			} else {
				this.checkCache(component);
			}
		});
		$A.enqueueAction(action);
	},
	
	checkCache : function(component){
	console.log('checkCache.....');
		var action = component.get('c.getIsAvailable');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
                console.log('cache avaialble');
				var result = response.getReturnValue();
				
				if(result){
					//everything is fine, cache is working
					component.set('v.displayPage', true);
					component.set('v.isAvailable', true);
				} else {
					component.set('v.isAvailable', false);
					component.set('v.displayPage', true);
					//cache is not working, go to error page and display message
					var redirectEvent = $A.get('e.c:wmp_event_Redirect');
					redirectEvent.setParams({
									'pageName' : 'error'
					});
					redirectEvent.fire();
				}
			}
			else {
                console.log('cache not avaialble');
				component.set('v.isAvailable', false);
				component.set('v.displayPage', true);
				//cache is not working, go to error page and display message
				var redirectEvent = $A.get('e.c:wmp_event_Redirect');
				redirectEvent.setParams({
								'pageName' : 'error'
				});
				redirectEvent.fire();
			}
			});
		$A.enqueueAction(action);
	},
})