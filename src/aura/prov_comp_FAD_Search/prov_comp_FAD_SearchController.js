({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Purpose								: To fetch the necessary information  
     * 											#verfied member plans from cache class
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			6th April 2018			WMP					See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
		component.set("v.bln_isError", false);
		//get all speciality from account object
		helper.fetchPicklistValues(component);
		helper.retrievePlanGroups(component);
		//helper.helperLoadConfig(component);

		helper.loadMinMaxAge(component);
		//get all the related plan information
		//helper.getRelatedPlanAccountsFromMemberPlans(component);
        
        //setting default values
        component.set('v.distance_value', '10');
        component.find("newPatients").set("v.value",true);
        //speciality
        $('html').not( $('.helpIcon') ).click(function(){
                $('.helpSpecialtyBox').removeClass('in');
        });
		
        //check to see if paramMap is populated
        if(component.get('v.paramMap') != undefined){
        	////console.log('paramMap populated...');
        	helper.decodeParams(component);
        } else {
        	//pull info from cache
        	/*if(localStorage['fadSearch'] != undefined){
	        	var lastFAD = JSON.parse(localStorage['fadSearch']);
				//put the params in the variable to be passed to the result
				// //console.log('setting map::'+JSON.stringify(obj));
				component.set('v.paramMap', lastFAD);
				helper.decodeParams(component);			
        	}*/
        }
        
        
	},
	/**************************************************************************************************************
     * Method Name							: searchMethod
     * Purpose								: To get information from page and pass tot the result page
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			7th April 2018			WMP					See header - purpose

    ***************************************************************************************************************/
	searchMethod : function(component, event, helper){
		component.set('v.planError', false);
		component.set('v.zipCodeError', false);
		component.set('v.minAgeValidate', false);
		
		////console.log('search clicked');
		component.set("v.bln_isError", false);
		var isError = false;
		//getting the values from the form
		//plan chosen
		var planId = component.find("chosenplan").get("v.value");
		if(planId === $A.get("$Label.c.Select") || planId === undefined || planId == ''){
			component.set('v.planError', true);
			$('.testScript_selectPlan').focus();
			isError = true;
		}
		//handicap accessible
		var handicap = component.find("handicapAccessible1").get("v.value");
		if(handicap == undefined)
			handicap = false;
		//distance
		var distance = component.find("distance").get("v.value");
		if(distance === 0){
			$('.testScript_distance').focus();
		
			isError = true;
		}
		//location 
		var loc = component.find("cityZipCode").get("v.value");
		////console.log('loc::'+loc);
		if(loc === undefined || loc == ''){
			isError = true;
			$('.testScript_cityState').focus();
			component.set('v.zipCodeError', true);
		}
		//gender
		var gender = component.find("gender").get("v.value");
		if(gender == '0' || gender === undefined)
			gender = '';
		//name
		var name = component.find("nameOfDentist").get("v.value");
		if(name === undefined)
			name='';
		//Specialities
		var specialty = component.find("specialities").get("v.value");
		if(specialty === '0'  || specialty === undefined){
			specialty = '';
		}
		//languages
		var languages = component.find("lang_spoken").get("v.value");
		if(languages === undefined || languages === '0')
			languages='';
		//sedation
		var sedation = component.find("sedation").get("v.value");
		if(sedation == undefined)
			sedation = false;
		//special needs
		var special = component.find("specialNeeds").get("v.value");
		if(special == undefined)
			special = false;
		//min patient age
		var minAge = component.find("minAge").get("v.value");
		if(minAge == 'min' || minAge === undefined)
			minAge = '';
		//max patient age
		var maxAge = component.find("maxAge").get("v.value");
		if(maxAge == 'max' || maxAge === undefined)
			maxAge = '';
		//accepting new patients
		var newPatients = component.find("newPatients").get("v.value");
		if(newPatients == undefined)
			newPatients = false;
		var outOfNetwork = component.find("outOfNetwork").get("v.value");
		if(outOfNetwork == undefined)
			outOfNetwork = false;
		//sorting
		var show = component.get('v.showBy');
		//sort by
		var sortBy = component.get('v.sortBy');
		//validate the min age is less than max age
		if(minAge != '' && maxAge != ''){
			if(minAge*1 > maxAge*1){
				component.set('v.minAgeValidate', true);
				isError = true;
			}
		}
		
		if(!isError){
			//console.log('generating obj...');
			var obj = {'planid' : 		planId,
						'distance': 	distance,
						'gender': 		gender,
						'handicap': 	''+handicap,
						'sedation' : 	''+sedation,
						'special' : 	''+special,
						'newPatients':  ''+newPatients,
						'outOfNetwork':  ''+outOfNetwork,
						'loc': 			loc,
						'name': 		name,
						'specialty' :   specialty,
						'language' :    languages,
						'minAge' : 		minAge,
						'maxAge': 		maxAge,
						'show': 		show,
						'sortBy': 		sortBy};
			/*var resultPageURLstring =	'planId=' +planId
									 +	'&handicap=' +handicap
									 +	'&distance=' +distance
									 +	'&loc=' +loc
									 +	'&gender=' +gender
									 +	'&name=' +name
									 +	'&specialty=' +specialty
									 +	'&language=' +languages
									 +	'&sedation=' +sedation
									 +	'&special=' +special
									 +	'&minAge=' +minAge
									 +	'&maxAge=' +maxAge
									 +	'&newPatients=' +newPatients
									 +	'&show=' +show
									 +	'&sortBy=' +sortBy
									 ;
			 */
			 
			//store the info to pull for next one
			localStorage['fadSearch'] = JSON.stringify(obj);
			//put the params in the variable to be passed to the result
			// //console.log('setting map::'+JSON.stringify(obj));
			component.set('v.paramMap', obj);
			//Page redirection
			component.set('v.isSearch', false);
		}else{
			////console.log('error >> ' + planId+ ' - ' + loc + ' -- '+ distance);
			component.set("v.str_errorMsg", $A.get("$Label.c.Error_message"));
			component.set('v.bln_isError', true);
			//$(".testScript_selectPlan").animate({ scrollTop: 0 }, "fast");
			
			window.scrollTo(0,0);
		}
	},
	/**************************************************************************************************************
     * Method Name							: clearFilters
     * Purpose								: To clear all the information that was entered on the screen
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			4/1/2018				WMP 					See header - purpose

    ***************************************************************************************************************/
	clearFilters : function (component, event, helper){
		//Setting all values to base level data
		//1. plan Id to select
//		component.set('v.distance_value', '10');
		//console.log(component.find("chosenplan").get("v.value"));
		component.find("chosenplan").set("v.value",'Select');
		//console.log(component.find("chosenplan").get("v.value"));
		//2. setting all the checkboxes to false
		component.find("handicapAccessible1").set("v.value", false);
		component.find("newPatients").set("v.value", true);
		component.find("sedation").set("v.value", false);
		component.find("specialNeeds").set("v.value", false);
		component.find("outOfNetwork").set("v.value", false);
		//3. Setting min and max agew
		component.find("maxAge").set("v.value",'max');
		component.find("minAge").set("v.value",'min');
		//4. gender, lang and specialities
		component.find("lang_spoken").set("v.value",'Select');
		component.find("gender").set("v.value",'0');
		component.find("specialities").set("v.value",'0');
		component.find("specialities").set("v.text",'0');
		//5. name, distnance and code
		component.find("distance").set("v.value","10");
		component.find("cityZipCode").set("v.value","");
		component.find("nameOfDentist").set("v.value","");
		window.scrollTo(0,0);
	},
	
	/**************************************************************************************************************
     * Method Name							: checkSpecialCharacters
     * Purpose								: To check for the special characters and replacing with blank
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			4/1/2018				WMP 				See header - purpose

    ***************************************************************************************************************/
    checkSpecialCharacters : function (component, event, helper){
        //checking the value of the name of dentist
        //For dentist name in desktop
        var nameOfDentist = component.find("nameOfDentist").get("v.value");
        if(nameOfDentist != undefined){
            nameOfDentist = nameOfDentist.replace(/[^a-zA-Z0-9-., '']/g,"");
        	component.find("nameOfDentist").set("v.value",nameOfDentist);
        }
        
        //For city/zip code name in desktop
        var cityZipCode = component.find("cityZipCode").get("v.value");
        if(cityZipCode != undefined){
            cityZipCode = cityZipCode.replace(/[^a-zA-Z0-9-., '']/g,'');
        	component.find("cityZipCode").set("v.value",cityZipCode);
        }

    },
    openHelpBox : function(component, event, helper) {
        event.stopPropagation()
        var specialHelp = component.find('helpSpecialtyBoxId');
        $A.util.toggleClass(specialHelp, 'in');
    },
	redirectContactUs : function (component, event, helper){
		//get the member id and plan id
		var pageName = 'contact-us';
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
		       'pageName' : pageName
		});
		redirectEvent.fire();
	},
	
	changeDistance : function(component, event, helper){
		var scName = component.get('v.distance_value');//component.find("distance").get("v.value");
		//console.log('scName::'+scName);
		//component.set('v.distance_value', scName);
		//component.find("distance").set("v.value", "'10'");
	},

	launchModal : function(component, event, helper){
		//var recClick = event.currentTarget;
		//var recId = recClick.dataset.id;
		//var recName = recClick.dataset.name;
		$A.createComponent(
				'c:prov_comp_FAD_Modal',
				{
					"isModal" : "true"
				},
				function(newModal, status, errorMessage){
					//Add the new button to the body array
					if (status === "SUCCESS") {
						//push the modal onto the page for it to be displayed
						var body = component.get("v.body");
						body.push(newModal);
						component.set('v.body', body);
					}
				}
		);
	},
})