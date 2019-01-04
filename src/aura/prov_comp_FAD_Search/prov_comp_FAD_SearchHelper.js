({
	/**************************************************************************************************************
     * Method Name							: getRelatedPlanAccountsFromMemberPlans
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											# verified account plans from the member plans
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			6th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	getRelatedPlanAccountsFromMemberPlans  : function (component){
		//calling an action to the server side controller to fetch the current account plans
		//var action = component.get("c.fetchVerifiedMemberPlansAccounts_friendlyNames");
		var action = component.get("c.retrieveMemberPlans");
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();
			var allPlansIds = '';
			//checking if the response is success
			if(response_state === 'SUCCESS'){
				var resMap = response.getReturnValue();
				var memList = [];
				
				for( var key in resMap){
					var obj = {'Value':key	, 'Label':resMap[key]};
					
					memList.push(obj);
				}
				component.set('v.verifiedPlanAccounts', memList);
				
				if(component.get('v.paramMap') != undefined){
		        	this.decodeParams(component);
		        }
			}else{
				//toast to display
				//console.log in case we need to track
				//console.log('Error');
			}
		});
		$A.enqueueAction(action);
	},

	fetchPicklistValues : function(component){
		var portalConfig = component.get('v.portalConfig');
		var action = component.get('c.loadPicklistValuesApex');
		action.setParams(
		{
			'configName' : portalConfig.MasterLabel
		}
			);
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var resMap = response.getReturnValue();
				//init values
				var specialList = [];
				var languageList = [];
				var obj;
				
				for( var key in resMap){
					if(key == 'specialty'){
						for(var loc in resMap[key]){
							if(resMap[key][loc].Value__c != undefined){
								obj = {'Value':resMap[key][loc].Value__c, 'Label':resMap[key][loc].English_Label__c, 'Description' : resMap[key][loc].English_Description__c};
							
								specialList.push(obj);
							}
							
						}
					} else if(key == 'language'){
						for(var loc in resMap[key]){
							if(resMap[key][loc].Value__c != undefined){
								obj = {'Value':resMap[key][loc].Value__c, 'Label':resMap[key][loc].English_Label__c};
						
								languageList.push(obj);
							}
						}
					}
				}
				component.set('v.specialties', specialList);
				component.set('v.languages', languageList);
//				component.find('specialities_M').set('v.options', specialList);
			}
		});
		
		$A.enqueueAction(action);
	},

	retrievePlanGroups : function(component){

		var businessId = component.get('v.currentBusinessId');
		////console.log('businessId::'+businessId);
		var action = component.get('c.retrievePlanGroupsApex');
		action.setParams(
		{
			'businessId' : businessId
		}
			);
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var resList = response.getReturnValue();
				////console.log('resList::'+JSON.stringify(resList));
				//init values
				var memList = [];
				var obj;
				
				for( var key in resList){
					
					if(resList[key] != undefined){
						obj = {'Value':resList[key], 'Label':resList[key]};
				
						memList.push(obj);
					}
				}
				component.set('v.verifiedPlanAccounts', memList);

				if(component.get('v.paramMap') != undefined){
		        	this.decodeParams(component);
		        }
//				component.find('specialities_M').set('v.options', specialList);
			}
		});
		
		$A.enqueueAction(action);
	},
	
	
	loadMinMaxAge : function(component){
		var options = [];
		
		for(var i = 0; i <= 100; i++){
			options.push( ''+ i );
		}
		
		component.set('v.ageRange', options);
	},

	decodeParams : function(component){
		var paramMap = component.get('v.paramMap');
		
		//create map of param to the component variable
		var param2VarMap = {'planid' : 		'chosenplan',
						'loc': 			'cityZipCode',
						'specialty' :  'specialities',
						'language' :    'lang_spoken',
						'gender': 		'gender',
						'minAge' : 		'minAge',
						'maxAge': 		'maxAge',
						'distance': 	'distance',
						'outOfNetwork' : 'outOfNetwork',
						'name': 		'nameOfDentist',
						'sedation' : 	'sedation',
						'special' : 	'specialNeeds',
						'handicap': 	'handicapAccessible1',
						'newPatients':  'newPatients',
						'show': 		'showBy',
						'sortBy': 		'sortBy'};

		for(var key in paramMap){
			if(paramMap[key] != undefined && paramMap[key] != ''){
				if(key == 'show' || key == 'sortBy'){
					var varName = 'v.'+ param2VarMap[key];
					component.set(varName, paramMap[key]);
				} else if( key == 'newPatients' || key == 'special' || key == 'handicap' || key =='sedation' || key == 'outOfNetwork'){
					component.find(param2VarMap[key]).set("v.value", paramMap[key] == 'true');
				}else {
					////console.log('key::'+key+'  :::value::'+ paramMap[key]);
					 component.find(param2VarMap[key]).set("v.value", paramMap[key]);
				}
			}
		}
	}
})