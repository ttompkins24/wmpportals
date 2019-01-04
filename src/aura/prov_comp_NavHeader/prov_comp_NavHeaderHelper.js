({

    //this function gets the businesses a user has access to from the cache
    getBusinesses : function(component, event, helper){
    	var opts = [];
        var providercache = JSON.parse(localStorage['providercache']);
        
        for(var i in providercache.businessMap){
        	var acc = providercache.businessMap[i];
        	//var bTin = acc.tax_id_number__c;
        	//if(bTin != undefined){
        		//bTin = bTin.substring(bTin.length-4);
        	//}
        	var labelName = acc.Name ;
        	//if(bTin != undefined){
        	//	labelName = labelName;// + ' - '+ bTin;//class:"picklistOption",
        	//}
            opts.push({label:labelName, value:acc.Id });//class:"picklistOption", 
        }
        //component.find("businessAccts").set("v.options", opts);
        component.set('v.businessList', opts);
        //console.log('business set');
        //get the current business
        helper.getCurrentBusiness(component, event, helper, opts);
       
    },
    
    //gets the current business in context from the cache
    getCurrentBusiness : function(component, event, helper, accounts){
    	var params = component.get('v.params');
    	var businessid = sessionStorage['businessid'];
    	
    	if( params['bc'] != undefined){
    		var paramValue = params['bc'];
    		businessid = localStorage['param.bus.'+paramValue];
    	}
    	//console.log('businessid::'+businessid);
    	//console.log('accounts::'+accounts);
    	
    	var providercache = JSON.parse(localStorage['providercache']);
    	
    	if(providercache.businessMap.hasOwnProperty(businessid)){
			
			//var business = providercache.businessMap[businessid];
			for(var i in accounts){
				//console.log(businessid);
            	//console.log(accounts[i].value);
            	//console.log(accounts[i].value.includes(businessid)); 
            	if(accounts[i].value.includes(businessid)){
            		var accLabel = accounts[i].label;
            		
            		//console.log(accLabel);
            		//$('.businessDropdownSelected').text(accLabel);
            		component.set('v.selectedBusiness', accLabel);
            	}
            }
		}
    },

    //sets the current business context in the cache for the logged in user
    setBusinessContext : function(component, event, helper){
    	var currentTarget = event.currentTarget;
    	var accId = currentTarget.dataset.value;
    	var accLabel = currentTarget.dataset.label;
    	//var selectedBusiness = component.find("businessAccts").get("v.value");
    	
    	var action = component.get("c.setCurrentBusinessId");
    	
    	action.setParams({
    		"newId" : accId
    	});
    	
    	action.setCallback(this, function(response){
    		if(response.getState() == 'SUCCESS'){
    			//console.log('Business Context changed');
    			$('.businessDropdownSelected').text(accLabel);
    			helper.redirectUrl('');
    			$A.util.removeClass(component.find("saving-backdrop"), "slds-show");
    			$A.util.addClass(component.find("saving-backdrop"), "slds-hide");
    		}
    	});
    	$A.enqueueAction(action);
    },
    
    //sets the current business context in the cache for the logged in user
    hasMessages: function(component, event, helper){
    	var accId = component.get('v.currentBusinessId');
        //var selectedBusiness = component.find("businessAccts").get("v.value");

        var action = component.get("c.hasMessagesApex");

        action.setParams({
            "currentBusinessId" : accId
        });

        action.setCallback(this, function(response){
        	console.log('hasMessages::'+response.getReturnValue());
            if(response.getState() == 'SUCCESS'){
                //console.log('Business Context changed');
                var numRecs = response.getReturnValue();
                if(numRecs > 0){
	                if((localStorage['message_read'] == undefined || localStorage['message_read'] == false) || 
	                		localStorage['total_messages'] == undefined || localStorage['total_messages'] != numRecs){
	                	component.set('v.hasOpenNotification', true);
	                	localStorage['total_messages'] = numRecs;
	                }
                }
            }
        });
        $A.enqueueAction(action);
    },

    //reloads the page after the business context is changed
    redirectUrl : function(pageName){
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({
            'pageName' : pageName
        });
        redirectEvent.fire();
    },
    
    retrieveLabels : function(component){
    	var portalConfig = component.get('v.portalConfig');
    	//console.log('pconfig::'+JSON.stringify(portalConfig));
    	var authL = portalConfig.PreAuthorization_Label__c;

		if(authL != null){
			var authV = $A.getReference('$Label.c.'+ authL);
			component.set('v.authLabel', authV);
		}
    },
})