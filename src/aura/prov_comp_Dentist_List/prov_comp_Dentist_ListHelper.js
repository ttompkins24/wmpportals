({
	NUM_RESULTS : 10,
	//reteives list of businesses 
	retrieveBizList: function(component, event, helper){
		//console.log('START retrieveBizList...');
		var busId = component.get('v.currentBusinessId');
		var lob = sessionStorage['portalconfig_lob'];
		var action = component.get("c.getAllBusinessesDentistList"); 
		action.setParams({'businessId' : busId, 'routeId' : lob});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === "SUCCESS"){
				
				component.set("v.bizAcctRec", response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
		
	},
    //get list of service locations based on B
    getServiceLocations : function (component, event, helper){

        var acctRecId = component.get("v.currentBusinessId");
        var action1 = component.get("c.getAllLocationsDentistList");

        action1.setParams({
            "bizAcctId" : acctRecId
        
        });

        action1.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
  
                component.set("v.locList", res.getReturnValue());

                if(res.getReturnValue().length === 1){
	                component.find("locAccts").set("v.value", res.getReturnValue()[0]);
	                helper.getLocId(component, event, helper);
                }
            }

        });



    $A.enqueueAction(action1);

    },
    
    //get list of service locations based on B
    getServiceLocationsAndProviders : function (component, event, helper){
    	//console.log('START getServiceLocationsAndProviders...');
        var acctRecId = component.get("v.currentBusinessId");
        var locAcctId = component.get("v.locAcctRecId");
    	var provAcctId = component.get("v.provAcctRecId");
    	
    	if(provAcctId == 'Any' || provAcctId == ''){
    		provAcctId = null;
    	}
    	
    	if(locAcctId == 'Any' || locAcctId == ''){
    		locAcctId = null;
    	}
        var action1 = component.get("c.getLocationsAndProviders");
        //sets number of results to return page (set to max results if max is not null)

        action1.setParams({
            "bizAcctId" : acctRecId,
            "locAcctId" : locAcctId,
            "provAcctId" : provAcctId
        });

        action1.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
            	var resultMap = res.getReturnValue();
            	
            	var locations = resultMap['locations'];
            	var providers = resultMap['providers'];
            	
            	component.set('v.locListPage', locations);
            	component.set('v.total_num_location', locations.length);
            	component.set('v.total_pages_location', Math.ceil(locations.length / component.get('v.pageSizeLoc') ) );
            	
            	component.set('v.dentistList', providers);
            	component.set('v.total_num_dentist', providers.length);
            	component.set('v.total_pages_dentist', Math.ceil(providers.length / component.get('v.pageSizeProv') ) );
            	
            	
            }
            var spinner = component.find('spinnerId');
	        $A.util.addClass(spinner, 'slds-hide');
	        $A.util.removeClass(spinner, 'slds-is-fixed');

        });



    $A.enqueueAction(action1);

    },


    
    //retrieves selected location ID
    getLocId: function(component, event, helper) {

        var selectedLocRec = component.find("locAccts").get("v.value");
        var bizAcctId = component.get("v.currentBusinessId");
         if(selectedLocRec != 'Any'){
            component.set("v.locAcctRecId", selectedLocRec);
            component.set("v.provAcctRecId", 'Any');
        }else{

            component.set("v.locAcctRecId", null);
            component.set("v.provAcctRecId", 'Any');
 
        }

        var action2 = component.get("c.getAllProvDentistList");
                action2.setParams({
                    "bizAcctId" : bizAcctId,
                    "locAcctId" : selectedLocRec
                });
        action2.setCallback(this,function(response){

            component.set("v.provList", response.getReturnValue());

//            console.log(response.getReturnValue());
//            component.set("v.maxResults", null);
//            component.set("v.searchActive", true);

        });
        $A.enqueueAction(action2);
        
        
    },

    getAllProvList : function(component,event,helper){
    	//console.log('START getAllProvList...');
    	var bizAcctId = component.get("v.currentBusinessId");
    	var action2 = component.get("c.getAllProvDentistListBiz");
    	action2.setParams({
    		"bizAcctId" : bizAcctId
    	});
    	action2.setCallback(this,function(response){
    		
    		component.set("v.provList", response.getReturnValue());
    		//component.set("v.maxResults", null);
    		//component.set("v.searchActive", true);
    		//helper.getDentists(component,event,helper,1);
    		//var dentist = "dentist";
    		//helper.loadPageVariables(component, dentist);
    		
    	});
    	$A.enqueueAction(action2);
    	
    },

    //retrieves selected provider ID
    getProvId: function(component, event, helper) {
        var acctRecId = component.find("provAccts").get("v.value");
        if(acctRecId == 'Any'){
            component.set("v.provAcctRecId", 'Any');
        }
        if(acctRecId != 'Any'){
            component.set("v.provAcctRecId", acctRecId);
        }else{
        	component.set("v.provAcctRecId", null);
        }
    },

})