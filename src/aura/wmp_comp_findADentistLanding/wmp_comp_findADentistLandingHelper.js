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
	getRelatedPlanAccountsFromMemberPlans: function(component) {
		//calling an action to the server side controller to fetch the current account plans
		//var action = component.get("c.fetchVerifiedMemberPlansAccounts_friendlyNames");
		var action = component.get("c.retrieveMemberPlans");
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response) {
			var response_state = response.getState();
			var allPlansIds = '';
			//checking if the response is success
			if (response_state === 'SUCCESS') {
				var resMap = response.getReturnValue();
				var memList = [];

				for (var key in resMap) {
					var obj = {
						'Value': key,
						'Label': resMap[key]
					};
					allPlansIds += key + ";";
					memList.push(obj);
				}
				component.set("v.allPlanIds", allPlansIds.substring(0, allPlansIds.length -
					1));
				component.set('v.verifiedPlanAccounts', memList);
				/**
				//check for the number of verified plan returned
				if(response.getReturnValue().length > 0){
					//set the attribute with the value and set the error boolean to false
					var allVerifiedPlanAccounts = response.getReturnValue();
					//"allPlanIds"
					//looping through the list if accounts size is greater than 0
					var allPlansIds = '';
					if(allVerifiedPlanAccounts.length > 0){
						for(var iterating_int = 0; iterating_int < allVerifiedPlanAccounts.length; iterating_int++) {
							allPlansIds += allVerifiedPlanAccounts[iterating_int].Id + ";";
						}
						component.set("v.allPlanIds", allPlansIds.substring(0, allPlansIds.length-1));
					}
					component.set("v.verifiedPlanAccounts",allVerifiedPlanAccounts);
					console.log(response.getReturnValue());

				}else{
					//set the error message and the condition
					component.set("v.bln_isError", true);
					component.set("v.str_errorMsg",$A.get("$Label.c.FAD_LandingError"));
				}
				**/
			} else {
				//toast to display
				//console.log in case we need to track
				console.log('Error');
			}
		});
		$A.enqueueAction(action);
	},
	/**************************************************************************************************************
     * Method Name							: fetchSpecialitiesPicklistValues
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information
     * 											# picklist values from the specialities field on account object
     *
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			6th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	/*fetchSpecialitiesPicklistValues : function(component){
		//calling an action to the server side controller to fetch the current picklist values on the account object
		var action = component.get("c.fetchSpecialitiesPicklistValues");
		//creating a callback that is executed after the server side action is returned
		action.setCallback(this, function(response){
			var response_state = response.getState();

			//checking if the response is success
			if(response_state === 'SUCCESS'){
				//sending the list<string>
				component.set("v.specialitiesFromAccount", response.getReturnValue());
			}else{
				//Error message
			}
		});
		$A.enqueueAction(action);
	},*/

	fetchSpecialtyPicklist: function(component) {
		var action = component.get('c.fetchPicklistValues_Speciality');
		action.setCallback(this, function(response) {
			if (response.getState() == 'SUCCESS') {
				var resMap = response.getReturnValue();
				//init values
				var specialList = [];
				var obj;

				for (var key in resMap) {
					if (resMap[key].Value != undefined) {
						obj = {
							'Value': resMap[key].Value,
							'Label': resMap[key].Label,
							'Description': resMap[key].Description
						};

						specialList.push(obj);
					}
				}
				component.set('v.specialties', specialList);
				//				component.find('specialities_M').set('v.options', specialList);
			}
		});

		$A.enqueueAction(action);
	},

	fetchLanguagePicklist: function(component) {
		var action = component.get('c.fetchPicklistValues_Language');
		action.setCallback(this, function(response) {
			if (response.getState() == 'SUCCESS') {
				var resMap = response.getReturnValue();
				//init values
				var langList = [];
				var obj;


				for (var key in resMap) {
					if (resMap[key].Value != undefined) {
						obj = {
							'Value': resMap[key].Value,
							'Label': resMap[key].Label
						};

						langList.push(obj);
					}
				}
				component.set('v.languages', langList);
				//				component.find('lang_spoken_D').set('v.options', langList);
				//				component.find('lang_spoken_M').set('v.options', langList);
			}
		});

		$A.enqueueAction(action);
	},
	/**************************************************************************************************************
     * Method Name							: helperLoadConfig
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information
     * 											# getting the config value from the custom metadata type
     *
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			19th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	helperLoadConfig: function(component) {
		var action = component.get('c.loadConfiguration');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var pConfig = response.getReturnValue();
				//console.log('pConfig.name::'+pConfig.Label);
				var fadL = pConfig.Dentists_Label__c;
				var imageUrl = pConfig.FADImageURL__c;
				var findAdentistL = pConfig.Find_a_Dentist_Label__c;
				var supportingTextLabel = pConfig.Find_a_dentist_supporting_text_label__c;
				//console.log('fadL::'+fadL);
				if (fadL !== null) {
					component.set('v.dentistL', fadL);

					//findAdentistL = 'Find_a_Provider';

					var fadV = $A.getReference('$Label.c.' + findAdentistL);
					component.set('v.findADentistL', fadV);
					component.set('v.imageUrl', imageUrl);
					//this works only if each possible value of the labels are listed below in comments
					//$Label.c.Find_a_Provider;
					//$Label.c.Find_a_Dentist;
					document.title = $A.get("$Label.c." + findAdentistL);

					var stlV = $A.getReference('$Label.c.' + supportingTextLabel);

					component.set('v.supportingTextL', stlV);
					component.set('v.picklistShowProviderL', $A.getReference('$Label.c.' +
						pConfig.Show_dentists_who_accept_Label__c));
					component.set('v.nameOfDentistOrOfficeL', $A.getReference('$Label.c.' +
						pConfig.Name_of_dentist_or_office_Label__c));
					component.set('v.acceptingNewPatientsL', $A.getReference('$Label.c.' +
						pConfig.Accepting_new_patients_Label__c));
				}
			}

		});
		$A.enqueueAction(action);
	},
	/**************************************************************************************************************
     * Method Name							: getZipCodeFromLocation
     * Developed By							: West Monroe Partners
     * Purpose								: To fetch the necessary information
     * 											# getting the zip code from the zip code object based on the user's
	 * 											 latitude and longtiude
	 * 											# needs users to authenticate
     *
     History
     Version#		Build#		Date					by  						Comments
	 1.0						12th June 2018			West Monroe Partners		To add logic to pass the lat and
																					long of the current user and fetch
																					the corrspding zip code from the
																					zip code table

    ***************************************************************************************************************/
	getZipCodeFromLocation: function(component, lat, long) {

		var place_holder = $A.get("$Label.c.ZipCode_placeholder");
		//console.log('lat >> ' + lat +  ' >> ' + long + ' >> ' +place_holder);
		component.find("cityZipCode").set("v.value", place_holder);
		//calling the controller to make the soql query
		var action = component.get('c.fetchRelatedZipCode');
		//setting parameters
		action.setParams({
			dc_lat: lat,
			dc_long: long
		});

		action.setCallback(this, function(response) {
			//checking if the zip code is returned
			if (response.getState() == 'SUCCESS') {
				var inst_zipCode = response.getReturnValue();
				//checking if there is a return value
				if (inst_zipCode !== '') {
					component.find("cityZipCode").set("v.value", inst_zipCode);
				}
			} else {
				//setting it to null if there is an error
				component.find("cityZipCode").set("v.value", "");
			}
		});
		$A.enqueueAction(action);
	},


	loadMinMaxAge: function(component) {
		var options = [];

		for (var i = 0; i <= 100; i++) {
			options.push('' + i);
		}

		component.set('v.ageRange', options);
	}
})