({
	retrievePagination : function(component){
		var paginate = component.get('c.paginationVariables');
		
		paginate.setCallback(this, function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				var responseList = response.getReturnValue();//first value is totalResults, second value is total pages
				component.set('v.numResults', responseList[0]);
				component.set('v.totalPages', responseList[1]);
				component.set('v.resultsPerPage', responseList[2]);
				
				this.setResultList(component);
				
				//get the spinner and hide it
				var spinner = component.find('uploadSpinner');
				$A.util.toggleClass(spinner, 'slds-hide');
			}
		});
		
		$A.enqueueAction(paginate);
	},
	decodeURLParams : function(component){
		var paramMap = {'show' : 'dentist', 'sortBy' : 'distance', 'loc' : 'Chicago'};
		if(window.location.search.substring(1) != null){
			var pageSearchParams = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
	        var urlVariables = pageSearchParams.split('&'); //Split by & so that you get the key value pairs separately in a list
	        var paramCombo;
	
	        //map the variables to the key to the value
	        for (var i = 0; i < urlVariables.length; i++) {
	        	paramCombo = urlVariables[i].split('\=');
	
	        	
	        	if(paramCombo[0] == 'show'){
	        		if(paramCombo[1] == 'dentist' || paramCombo[1] == 'office'){
	        			paramMap[paramCombo[0]]= paramCombo[1];
	        		}
	        	} else if(paramCombo[0] == 'loc'){
	        		paramMap[paramCombo[0]]= decodeURIComponent(escape(paramCombo[1] ) ).replace(/\+/g, ' ');
	        	} else if(paramCombo[0] == 'sortBy'){
	        		if(paramCombo[1] == 'name' || paramCombo[1] == 'distance'){
	        			paramMap[paramCombo[0]]= paramCombo[1];
	        		}
	        	} else {
	        		paramMap[paramCombo[0]]= paramCombo[1];
	        	}
	        	
	        	if(paramCombo[0] == 'planId'){
	        		var memCovS = decodeURIComponent(paramCombo[1]).replace(/\+/g, ' ');
	        		var memCovList = [];
	        		if(memCovS != '' && memCovS != undefined){
	        			var memCovA = memCovS.split(';');
	        			console.log('memCovA::'+memCovA);
	        			if(memCovA.length > 1){
		        			for(var memCovGuid in memCovA){
		        				memCovList.push(memCovGuid);
		        			}
		        		} else {
		        			memCovList.push(memCovA);
		        		}
	        		}
	        		console.log('memCovList::'+memCovList);
	        		component.set('v.memCovIds' , memCovList);
	        	}
	        }
	    }
		component.set('v.sortedBySelected', paramMap['sortBy']);
		component.set('v.locSearched',  paramMap['loc']);
		component.set('v.showSelected', paramMap['show']);
        component.set('v.paramMap', paramMap);
        
	},
	
	retrieveProviders_Office : function(component){
		//create the action to retrieve the fad results grouped by office
		var action = component.get('c.retrieveDentists_Office');
		var paramMap = component.get('v.paramMap');

		action.setParams({'paramMap' : component.get('v.paramMap')});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				var resList = response.getReturnValue();
				
				component.set('v.fullResultList', resList);
				component.set('v.pageNum', 1);
			}
		});
		
		$A.enqueueAction(action);
	},
	
	retrieveProviders_Dentist : function(component){
		//create the action to retrieve the fad results grouped by dentist
		var action = component.get('c.retrieveDentists_Dentist');
		var paramMap = component.get('v.paramMap');
		action.setParams({'paramMap' : component.get('v.paramMap')});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				var resList = response.getReturnValue();
				
				component.set('v.fullResultList', resList);
				component.set('v.pageNum', 1);
			}
		});
		
		$A.enqueueAction(action);
	},
	
	setResultList : function(component){
		var fullResults = component.get('v.fullResultList');
		var rPerPage = component.get('v.resultsPerPage');
		var resultList = [];
		var pageNum = component.get('v.pageNum');
		
		var numResults = rPerPage * pageNum;
		if(numResults > fullResults.length)
			numResults = fullResults.length;

		for(var i = (pageNum-1)*rPerPage; i < numResults; i++){
			resultList.push(fullResults[i]);
		}
		
		component.set('v.resultList', resultList);
	},
	
	helperLoadConfig : function(component){
		var action= component.get('c.loadConfiguration');
		
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var pConfig = response.getReturnValue();
				var dentistL = pConfig.Dentists_Label__c;
				var notAcceptL = pConfig.FAD_Not_Accepting_New_Patients_Label__c;
                var findAdentistL = pConfig.Find_a_Dentist_Label__c;
				
				if(dentistL != null){
					var dentistV = $A.getReference('$Label.c.'+ dentistL);
					console.log('dentistV::'+dentistV);
					component.set('v.dentistsL', dentistV);

                    //this works only if each possible value of the labels are listed below in comments
                    //$Label.c.Find_a_Provider;
                    //$Label.c.Find_a_Dentist;
                    document.title = $A.get("$Label.c." + findAdentistL);
                    
				}
				if(notAcceptL != null){
					var notAcceptV = $A.getReference('$Label.c.'+ notAcceptL);
					
					component.set('v.notAcceptingNewPatientsL', notAcceptV);
				}
				component.set('v.mainDentistCanBeSet', pConfig.Allow_Setting_Main_Dentist__c);
			}
		});
		
		$A.enqueueAction(action);
	},
})