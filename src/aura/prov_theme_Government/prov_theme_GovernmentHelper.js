({
	/**CHECK IF THE WINDOW IS IN AN INCOGNITO WINDOW SINCE THEY WILL NOT BE ABLE TO USE SESSIONSTORAGES*/
	checkIncognitoWindow : function(component, helper){
		 var fs = window.RequestFileSystem || window.webkitRequestFileSystem;
		if (!fs) {
		  //console.log("check failed?");
		} else {
		  fs(window.TEMPORARY,
		     100,
		    console.log.bind(console, "not in incognito mode"),
     console.log.bind(console, "incognito mode"));
		}
	 },
	 
	/***** METHOD to retrieve the current page that the user is on *****/
	setCurrentPage : function(component) {
		var pathname = window.location.pathname;//ex = /member/s/home?id=9234
		var params = pathname.split('?');//ex ['/member/s/home', 'id=9234']
		var locs = params[0].split('/'); //ex [ ,member,s,home]
		
		var pageRef = locs[locs.length-1];//ex home
        ////console.log('pageRef: ' + pageRef);
		if(pageRef == null){
			component.set('v.currPage', pageRef);
			component.set('v.currTab', '');
		}else{
			pageRef = pageRef.toLowerCase();
			component.set('v.currPage', pageRef);
			
			if(pageRef == 'member-eligibility' || pageRef == 'member-intervention' || pageRef == 'broken-appointment' || pageRef == 'panel-roster' || pageRef == 'broken-appointment-list'){
				component.set('v.currTab', 'member');
			} else if(pageRef == 'claim-entry' || pageRef == 'claim-search' || pageRef == 'claim-drafts' || pageRef == 'claim-confirmation-report' || pageRef == 'claim-detail'){
				component.set('v.currTab', 'claim');
			} else if(pageRef == 'pre-auth-entry' || pageRef == 'pre-auth-search' || pageRef == 'pre-auth-drafts' || pageRef == 'pre-auth-confirmation-report' || pageRef == 'pre-auth-detail'){
				component.set('v.currTab', 'preauth');
			}  else if(pageRef == 'referral-entry' || pageRef == 'referral-search' || pageRef == 'referral-drafts' || pageRef == 'referral-confirmation-report'  || pageRef == 'referral-detail'){
				component.set('v.currTab', 'referral');
			} else if(pageRef == 'eob-search'){
				component.set('v.currTab', 'payment');
			} else if(pageRef == 'practice-management' || pageRef == 'provider-detail' || pageRef == 'service-office-detail' || pageRef == 'business-detail' ||
						pageRef == 'billed-amount' || pageRef == 'billed-amount-detail' || pageRef == 'fee-schedule' || pageRef == 'reports'){
				component.set('v.currTab', 'practice');
			} else if(pageRef == 'find-a-provider'){
				component.set('v.currTab', 'fad');
			} else if(pageRef == 'contact-us' || pageRef == 'help-request' || pageRef == 'help-request-detail'){
				component.set('v.currTab', 'help');			
			} else {
				component.set('v.currTab', '');	
			}
		}
        ////console.log('pageRef2: ' + pageRef);
	},
	/*********** Method for the reinitialize for the page components *********************/
	reInitialize : function(component){
        //consle.log('reinit');
		this.setCurrentPage(component);
	},
	
	loadSessionId : function(component, helper){
		var sessionid = sessionStorage['sessionid'];
		////console.log('sessionid::'+sessionid);
		if(sessionid == undefined){
			var action = component.get('c.retrieveSessionIdApex');
			action.setCallback(this, function(response){
				if(response.getState() == 'SUCCESS'){
					////console.log('sessionid::'+response.getReturnValue());
					sessionStorage['sessionid']= response.getReturnValue();
					helper.loadCache(component, helper);
                    
				}
			});
			$A.enqueueAction(action);
		} else {
			helper.loadCache(component, helper);
		}
	},
	
	/*********** Method to load and store the cache *********************/
	loadCache : function(component, helper){
        ////console.log('load cache');
		//var sessionid = component.get('v.sessionid');
		//check localCache to see if data is pulled. check if the session ids differ
		if(localStorage['isAvailable'] == undefined || sessionStorage['sessionid'] != localStorage['sessionid']){
			////console.log('cache being loaded...');
            localStorage.removeItem('providercache');
			localStorage.removeItem('isAvailable');
            ////console.log(localStorage['providercache']);
			//load the cache data
			var action = component.get('c.getCacheData');
			action.setCallback(this, function(response){
				if(response.getState() == 'SUCCESS'){
                    ////console.log('-----------------------------------------------------------');
                    ////console.log('data retrieved from server');
                    ////console.log('-----------------------------------------------------------');
					var result = response.getReturnValue();
					////console.log('Cache Map::'+result);
					////console.log(JSON.stringify(result));
					
					localStorage['providercache'] = JSON.stringify(result);
					sessionStorage['businessid'] = result.currentBusId;
					localStorage['defaultbusiness'] = result.currentBusId;
					sessionStorage['portalconfig'] = result.currentPortalConfig;
					localStorage['defaultconfig'] = result.currentPortalConfig;
                    if(result.currentPortalConfig!=null && result.currentPortalConfig != undefined){
                        sessionStorage['portalconfig_lob'] = result.currentPortalConfig.RouteId__c;
                    }else {
                        sessionStorage['portalconfig_lob'] = 'GOV';
                    }
					
					//var futureDate = expiration + (4*60*60*1000); 
					//localStorage['expiration'] = new Date(futureDate);
					////console.log(localStorage['expiration']);
					localStorage['sessionid'] = sessionStorage['sessionid'];
					
					//remove some stored cache info that needs to be cleared on cache load
					localStorage.removeItem('showDeleteClaimDraftWarning'); 
					localStorage.removeItem('showDeleteAuthDraftWarning'); 
					localStorage.removeItem('message_read'); 
					localStorage['defaultconfig'] = result.currentPortalConfig;

					
					//create storage of business map
					var ct= 0 ;
					for(var i in result.businessMap){
						localStorage[i] = JSON.stringify(result.businessMap[i]);
						localStorage['param.bus.'+ct] = i;
						localStorage['param.bus.'+i] = ct;
						ct++;
					}
					
					ct= 0 ;
					for(var i in result.portalConfigs){
						localStorage[i] = JSON.stringify(result.portalConfigs[i]);
						localStorage['param.config.'+ct] = i;
						localStorage['param.config.'+i] = ct;
						ct++;
					}
                    ////console.log('RESULT: ' + result.fullyLoaded);
					if(result.fullyLoaded){
						localStorage['isAvailable'] = true;
						////console.log('successfully loaded');
					}
					helper.loadConfigResults(component, helper);
					component.set('v.displayNav', true);
                    
				}
			});
			
			$A.enqueueAction(action);
		} else {
			
			////console.log('cache already loaded...');
			////console.log('cache map::' + localStorage['providercache']);
			//get url params
			var qs = location.search;
	        qs = qs.split('+').join(' ');
	        
	        var params = {},
	            tokens,
	            re = /[?&]?([^=]+)=([^&]*)/g;
	        
	        while (tokens = re.exec(qs)) {
	            params[decodeURIComponent(tokens[1].toLowerCase())] = decodeURIComponent(tokens[2]);
	        }
	        
	        var businessid, portalConfig;
	        //check params for business context
	        if(params['bc'] != undefined){
	        	//set the storage session for business based on translation
	        	var paramValue = params['bc'];
	        	var newBId = localStorage['param.bus.'+paramValue];
	        	////console.log('newBId::'+newBId);
	        	sessionStorage['businessid']=newBId;
	        } else if(sessionStorage['businessid'] == undefined){
	        	////console.log('localStorage[defaultbusiness]::'+localStorage['defaultbusiness']);
	        	sessionStorage['businessid'] = localStorage['defaultbusiness'];
	        }
	        
	        //check params for portal config context
	        if(params['pc'] != undefined){
	        	//set the storage session for portal config based on translation
	        	var paramValue = params['pc'];
	        	var newPC = localStorage['param.config.'+paramValue];
	        	////console.log('newPC::'+newPC);
	        	sessionStorage['portalconfig']=newPC;
	        }else if(sessionStorage['portalconfig'] == undefined){
	        	sessionStorage['portalconfig'] = localStorage['defaultconfig'];
	        }
	               	
	        helper.loadConfigResults(component, helper);
		}
	},
	
	loadConfigResults : function(component, helper){
		////console.log('load config');
		var providercache = JSON.parse(localStorage['providercache']);
		////console.log('providercache::'+providercache);
		var portalConfigName = sessionStorage['portalconfig'];
		//set the static resource
		if(providercache.portalConfigs.hasOwnProperty(portalConfigName)){
            ////console.log('load config has own rId: ' + portalConfigObj.RouteId__c);
			var portalConfigObj = providercache.portalConfigs[portalConfigName];
			
			var staticResourceName =portalConfigObj.Static_Resource_Name__c; 
			sessionStorage['portalconfig_lob'] = portalConfigObj.RouteId__c;
			////console.log(staticResourceName);
			component.set('v.staticResource', staticResourceName);
			component.set('v.staticResourcePicked', true);
		} else {
			//pull in default portal config
			////console.log('loadConfig needs default');
		}
		component.set('v.displayNav', true);
		////console.log('loadConfigResults...');
		helper.checkCache(component);
	},
	
	/****METHOD TO LOAD THE PORTAL CONFIGURATION RECORD **/
	loadStaticResource : function(component){
		var action = component.get('c.getPortalConfiguration');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var portalConfig = response.getReturnValue();
				component.set('v.staticResource', portalConfig.Static_Resource_Name__c);
				component.set('v.staticResourcePicked', true);
			} else {
			}
			this.checkCache(component);
		});
		$A.enqueueAction(action);
	},
	
	checkCache : function(component){
		//console.log('checkCache...');
		var action = component.get('c.getIsAvailable');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var result = response.getReturnValue();
				////console.log('result::'+result);
				if(result){
					//everything is fine, cache is working
					//console.log('cache fine');
					component.set('v.displayPage', true);
					component.set('v.isAvailable', true);
				} else {
                    //console.log('cache not fine');
					component.set('v.isAvailable', false);
					component.set('v.displayPage', true);
					//cache is not working, go to error page and display message
					var redirectEvent = $A.get('e.c:prov_event_Redirect');
					redirectEvent.setParams({
									'pageName' : 'error'
					});
					redirectEvent.fire();
				}
			}
			else {
				component.set('v.isAvailable', false);
				component.set('v.displayPage', true);
				//cache is not working, go to error page and display message
				var redirectEvent = $A.get('e.c:prov_event_Redirect');
				redirectEvent.setParams({
								'pageName' : 'error'
				});
				redirectEvent.fire();
			}
			});
		$A.enqueueAction(action);
	},
})