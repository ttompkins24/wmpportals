({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To fetch the necessary information  
     * 											#verfied member plans from cache class
     *										 
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			6th September 2017		Santosh Kumar Sriram		See header - purpose
	 2.0						12th June 2018			West Monroe Partners		To add logic to pass the lat and 
																					long of the current user and fetch 
																					the corrspding zip code from the 
																					zip code table
    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
		component.set("v.bln_isError", false);
		//get all speciality from account object
		helper.fetchSpecialtyPicklist(component);
		helper.fetchLanguagePicklist(component);
		helper.helperLoadConfig(component);

		helper.loadMinMaxAge(component);
		//get all the related plan information
		helper.getRelatedPlanAccountsFromMemberPlans(component);
        
        //setting default values
        component.set('v.distance_value', '10');
        component.find("newPatients").set("v.value",true);
        //speciality
        $('html').not( $('.helpIcon') ).click(function(){
                $('.helpSpecialtyBox').removeClass('in');
        });
		
        /** 
			Member enbancements - West Monroe Partners - Begin
		**/
		if(navigator.geolocation){
			navigator.geolocation.getCurrentPosition(function(position){
				helper.getZipCodeFromLocation(component,position.coords.latitude,position.coords.longitude);
			});
		}
		/** 
			Member enbancements - West Monroe Partners - End
		**/
        
	},
	/**************************************************************************************************************
     * Method Name							: searchMethod
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To get information from page and pass tot the result page
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			7th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	searchMethod : function(component, event, helper){
		component.set('v.planError', false);
		component.set('v.zipCodeError', false);
		component.set('v.minAgeValidate', false);
		
		console.log('search clicked');
		component.set("v.bln_isError", false);
		var isError = false;
		//getting the values from the form
		//plan chosen
		var planId = component.find("chosenPlanId").get("v.value");
		if(planId === $A.get("$Label.c.Select") || planId === undefined){
			component.set('v.planError', true);
			isError = true;
		}
		//handicap accessible
		var handicap = component.find("handicapAccessible").get("v.value");
		//distance
		var distance = component.find("distance").get("v.value");
		if(distance === 0)
			isError = true;
		//location 
		var loc = component.find("cityZipCode").get("v.value");
		if(loc === undefined){
			isError = true;
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
		//special needs
		var special = component.find("specialNeeds").get("v.value");
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
		//sorting
		var show = 'dentist';
		//sort by
		var sortBy = 'distance';
		
		//validate the min age is less than max age
		if(minAge != '' && maxAge != ''){
			if(minAge*1 > maxAge*1){
				component.set('v.minAgeValidate', true);
				isError = true;
			}
		}
		
		if(!isError){
			var resultPageURLstring =	'/find-a-dentist-result?'
									 +	'planId=' +planId
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
			//Page redirection
			var urlEvent = $A.get("e.force:navigateToURL");
		    urlEvent.setParams({
		      "url": resultPageURLstring,
		      "isredirect":"false"
		    });
		    urlEvent.fire();
		}else{
			console.log('error >> ' + planId+ ' - ' + loc + ' -- '+ distance);
			component.set("v.str_errorMsg", $A.get("$Label.c.Error_message"));
			component.set('v.bln_isError', true);
			window.scrollTo(0,0);
		}
	},
	/**************************************************************************************************************
     * Method Name							: clearFilters
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To clear all the information that was entered on the screen
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			7th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	clearFilters : function (component, event, helper){
		//Setting all values to base level data
		//1. plan Id to select
//		component.set('v.distance_value', '10');
		component.find("chosenPlanId").set("v.value",'Select');
		//2. setting all the checkboxes to false
		component.find("handicapAccessible").set("v.value", false);
		component.find("newPatients").set("v.value", true);
		component.find("sedation").set("v.value", false);
		component.find("specialNeeds").set("v.value", false);
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
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To check for the special characters and replacing with blank
     History
     Version#		Sprint#		Date					by  						Comments
	 1.0			1.0			13th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
    checkSpecialCharacters : function (component, event, helper){
        //checking the value of the name of dentist
		console.log('Test');
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
    /**************************************************************************************************************
     * Method Name							: redirectView
     * Developed By							: Santosh Kumar Sriram
     * Purpose								: To get the member id and the plan id to redirect the user to the respective page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			5.0			25th September 2017		Santosh Kumar Sriram		See header - purpose

    ***************************************************************************************************************/
	redirectContactUs : function (component, event, helper){
		//get the member id and plan id
		var pageName = $A.get("$Label.c.help_center_landing");
		var redirectEvent = $A.get('e.c:wmp_event_Redirect');
		redirectEvent.setParams({
		       'pageName' : pageName
		});
		redirectEvent.fire();
	},
	
	changeDistance : function(component, event, helper){
		var scName = component.get('v.distance_value');//component.find("distance").get("v.value");
		console.log('scName::'+scName);
		//component.set('v.distance_value', scName);
		//component.find("distance").set("v.value", "'10'");
	}
})