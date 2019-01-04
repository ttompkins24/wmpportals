({
    params: null, //singleton object containing page parameters from URL
    setParams: function(component) {
    	this.initParams(component);
        component.set("v.params", this.params);
    },    
    
    initializeBusiness : function(component){
        //console.log('init business');
        try{
    	var providercache = JSON.parse(localStorage['providercache']);
        } catch (err){
            //console.log('cache: ' + localStorage['providercache']);
            //console.log(err);
        }
        //console.log('init business parsed');
		if(providercache == undefined){
            //console.log('init business und');
			var action = component.get('c.getDefaultBusinessId');
			action.setCallback(this, function(response){
                //console.log('init business und response ' + response.getReturnValue());
				if(response.getState() == 'SUCCESS'){
					component.set('v.currentBusinessId', response.getReturnValue());
				}
			});
			$A.enqueueAction(action);
		} else {
            //console.log('init business def');
			var businessid = sessionStorage['businessid'];
			
			
			var business = providercache.businessMap[businessid];
            //console.log('busId: ' + businessid);
			component.set('v.currentBusinessId', businessid);
	    	component.set('v.currentBusiness', business);
		}
    },
    getSurfacePicklist: function(component) {
        var values = [
            { Name : 'B' },
            { Name : 'D' },
            { Name : 'F' },
            { Name : 'L' },
            { Name : 'I' },
            { Name : 'M' },
            { Name : 'O' }
            
        ];
        return values;
    },
    initParams: function(component) {
        var qs = location.search;
        qs = qs.split('+').join(' ');
        
        var params = {},
            tokens,
            re = /[?&]?([^=]+)=([^&]*)/g;
        
        while (tokens = re.exec(qs)) {
            params[decodeURIComponent(tokens[1].toLowerCase())] = decodeURIComponent(tokens[2]);
        }
        this.params = params;
        
    } ,

    cache_ServiceLocation : function( component, locId){
        //console.log('locId::'+locId);
        var providercache = JSON.parse(localStorage['providercache']);
        var locationMap = providercache.locationMap;
        if(locId != undefined){
            //console.log('init serv loc');
            locId = locId.substring(0,15);
          
            var location = locationMap[locId];
            return location;
        }
        return undefined;
    },

    cache_Provider : function( component, provId){
        var providercache = JSON.parse(localStorage['providercache']);
        var providerMap = providercache.providerMap;
        
        if(provId != undefined){
            //console.log('init prov id');
            provId = provId.substring(0,15);
            var provider = providerMap[provId];
            return provider;
        }
        return undefined;
    },
    
    setPermissionsHelper : function(component) {
        //console.log('init perm helper');
    	var businessId = component.get('v.currentBusinessId');
    	//var providercache = JSON.parse(localStorage['providercache']);
//    	var permObj = providercache.permissionMap[businessId];
//    	permObj.admin = true;
    	//component.set( 'v.permissions', providercache.permissionMap[businessId] );
    	var action =  component.get('c.getPermissionObj');
    	action.setParams({'businessId':businessId});
    	action.setCallback(this, function(response){
    		if(response.getState() == 'SUCCESS'){
                //console.log('init perm callback');
    			component.set( 'v.permissions', response.getReturnValue() );
    			this.checkAccess4Page(component);
    			//console.log(JSON.stringify(response.getReturnValue()));
    		}
    	});
    	$A.enqueueAction( action );
    },
    
    checkAccess4Page : function(component){
    	//check to see if the user has access to the page
    	var pathname = window.location.pathname;//ex = /member/s/home?id=9234
		var params = pathname.split('?');//ex ['/member/s/home', 'id=9234']
		var locs = params[0].split('/'); //ex [ ,member,s,home]
		var permission = component.get('v.permissions');
		var pageRef = locs[locs.length-1];//ex home
        //console.log('init access: -' + pageRef + '-');
		if(pageRef != '' && pageRef != ''){
			if(permission.memberEligibility == 'none' && pageRef == 'member-eligibility'){
				this.redirect2Error(component);
				
			} else if(permission.brokenAppointment != 'full' && pageRef == 'broken-appointment'){
				this.redirect2Error(component);
			
			} else if(permission.brokenAppointment == 'none' && pageRef == 'broken-appointment-list'){
				this.redirect2Error(component);
			
			} else if(permission.panelRoster == 'none' && pageRef == 'panel-roster'){
				this.redirect2Error(component);
			
			} else if(permission.claims == 'none' && (pageRef == 'claim-confirmation-report' || pageRef == 'claim-search')){
				this.redirect2Error(component);
			
			} else if(permission.claims != 'full' && (pageRef == 'claim-drafts' || pageRef == 'claim-entry')){
				this.redirect2Error(component);
			
			} else if(permission.preAuth == 'none' && (pageRef == 'pre-auth-confirmation-report' || pageRef == 'pre-auth-search')){
				this.redirect2Error(component);
			
			} else if(permission.preAuth != 'full' && (pageRef == 'pre-auth-drafts' || pageRef == 'pre-auth-entry')){
				this.redirect2Error(component);
			
			} else if(permission.referral == 'none' && (pageRef == 'referral-confirmation-report' || pageRef == 'referral-search')){
				this.redirect2Error(component);
			
			} else if(permission.referral != 'full' && pageRef == 'referral-entry'){
				this.redirect2Error(component);
			
			} else if(permission.memberIntervention == 'none' && pageRef == 'member-intervention'){
				this.redirect2Error(component);
			
			} else if(permission.dentistList == 'none' && (pageRef == 'practice-management' || pageRef == 'business-detail' || pageRef == 'provider-detail' || pageRef == 'service-office-detail')){
				this.redirect2Error(component);
			
			} else if(permission.eft != 'full' && pageRef == 'electronic-funds-transfer'){
				this.redirect2Error(component);
			
			} else if(permission.billedAmount == 'none' && pageRef == 'billed-amount' ){
				this.redirect2Error(component);
			
			} else if(permission.billedAmount != 'full' && pageRef == 'billed-amount-detail'){
				this.redirect2Error(component);
			
			} else if(permission.feeSchedule == 'none' && pageRef == 'fee-schedule'){
				this.redirect2Error(component);
			
			} else if(permission.findDentist == 'none' && pageRef == 'find-a-provider'){
				this.redirect2Error(component);
			} 
		}
    },
    
    redirect2Error : function(component){
    	var pageName = 'error';
    	var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : pageName
		});
		//console.log('fire event');
		redirectEvent.fire();
    },
    
    getCurrentPortalConfig : function(component){
        //console.log('init current config');
    	var providercache = JSON.parse(localStorage['providercache']);
    	if(providercache != undefined){
            //console.log('init current config def');
			var portalConfigName = sessionStorage['portalconfig'];
			var portalConfigObj;
			//set the static resource
			if(providercache.portalConfigs.hasOwnProperty(portalConfigName)){
				portalConfigObj = providercache.portalConfigs[portalConfigName];
                //console.log('portalConfig ' + JSON.stringify(portalConfigObj));
				component.set( 'v.portalConfig', portalConfigObj );
			}
		} else{
            //console.log('init current config undef');
	    	var action = component.get('c.getPortalConfiguration');
	    	action.setCallback(this, function(response){
	    		if(response.getState() == 'SUCCESS'){
	    			component.set( 'v.portalConfig', response.getReturnValue() );
	    		}
	    	});
	    	$A.enqueueAction( action );
		} 
    },

    setCurrentContact : function(component){
        //console.log('init current cont');
    	var providercache = JSON.parse(localStorage['providercache']);
    	if(providercache != undefined){
            //console.log('init current cont def');
            //console.log('current cont ' + JSON.stringify(providercache.currentContact));
    		component.set('v.currentContact', providercache.currentContact);
    	} else{
    		//console.log('init current cont und');
	        var action = component.get("c.getContactRec");
	        action.setCallback(this, function(response){
	            if(response.getState() == 'SUCCESS'){
	                component.set('v.currentContact', response.getReturnValue());
	            }
	        });
	        $A.enqueueAction(action);
    	}
    },
    
    fixDate : function(component, event) {
        var selectItem = event.getSource();
        var dateEntered = selectItem.get('v.value');
        //console.log('dateEntered::'+dateEntered);
        if(dateEntered == undefined || dateEntered == null || dateEntered == ''){
            selectItem.set('v.value', '');
        	selectItem.set('v.errors', []);
        	return;
        }
        var newDate = new Date(dateEntered);
        var newDateFullYear = newDate.getFullYear();
        if(newDate == 'Invalid Date' || newDateFullYear == undefined || newDateFullYear > 9999){
            if(dateEntered.length > 6){
        		var year = dateEntered.substr(dateEntered.length-4, dateEntered.length-1);
        		var fullDate = dateEntered.substr(0, dateEntered.length-4);
        	}
        	else{
        		var year = dateEntered.substr(dateEntered.length-2, dateEntered.length-1);
        		var tempDate = new Date();
        		var tempDateYear = tempDate.getUTCFullYear();
        		var tempDateYearSplit = (''+tempDateYear).substr(2);
        		var tempDateYearSplitInt = 1* tempDateYearSplit + 1;
        		//console.log('tempDateYear::'+tempDateYear);
        		if(1*year > tempDateYearSplitInt)
        			year = (1*(''+tempDateYear).substr(0,2) -1) + year;
        		else
        			year = (''+tempDateYear).substr(0,2) + year;
        		//console.log('new year::'+year);
        		var fullDate = dateEntered.substr(0, dateEntered.length-2);
        	}
            //remove leading 0's
            //while(fullDate[0] == 0){
            //	fullDate = fullDate.substr(1);
            //}
//            console.log('fullDate::'+fullDate);
            var month = 1;
            var day = 1;
            if(fullDate.length == 3){
                if(fullDate[0] == 1 ||  fullDate[0] == 0){
	                if(fullDate[1] < 3 && fullDate[2] != 0){//month is 10, 11, 12
                        month = fullDate.substr(0,2);
                        day = '0'+fullDate.substr(2);
                    } else{// month is just 1 since next number is greater than 2
                        month = '1';
            	        day = fullDate.substr(1);                                            
            	    }
                } else {
                    month = fullDate[0];                                        
                    day = fullDate.substr(1);
           	    } 
            }else if(fullDate.length == 2){
                month = '0'+fullDate[0];
                day = '0'+fullDate[1];
    		} else {//length is 4
                month = fullDate.substr(0,2);                                        
                day = fullDate.substr(2);
            }
            
            if(month == undefined || month == null || month =='')
                month = 1;
            if(day == undefined || day == null || day == '')
                day = 1;
            //console.log('month::'+month);
            //console.log('day::'+day);
           
            
            newDate = new Date(year,month-1,day,0,0,0);
            //console.log('newDate ::'+newDate );
            if(newDate == 'Invalid Date' || day.length >2 || day > 31 || month > 12 ){
                selectItem.set('v.errors', [{message:"Input not in right format (MM/DD/YYYY)"}]);
            } else {
                //update the entered date to the right format
                selectItem.set('v.value', (year + '-' + month + '-' + day));
                selectItem.set('v.errors', []);
            }
        } else {
            var mm = newDate.getUTCMonth()+1; 
            if (mm <= 9) {
                mm = '0' + mm;
            }

            var day = newDate.getUTCDate();
            if (day <= 9) {
                day = '0' + day;
            }
            // var tempDate = new Date(year,month,day,0,0,0);
//            console.log((newDate.getUTCFullYear() + '-' + mm + '-' + newDate.getUTCDate()));
        	selectItem.set('v.value', (newDate.getUTCFullYear() + '-' + mm + '-' + day));
            selectItem.set('v.errors', []);
        }
        
    },

    getStatePicklists : function() {
        return [
            {
                "name": "Alabama",
                "abbreviation": "AL"
            },
            {
                "name": "Alaska",
                "abbreviation": "AK"
            },
            {
                "name": "Arizona",
                "abbreviation": "AZ"
            },
            {
                "name": "Arkansas",
                "abbreviation": "AR"
            },
            {
                "name": "California",
                "abbreviation": "CA"
            },
            {
                "name": "Colorado",
                "abbreviation": "CO"
            },
            {
                "name": "Connecticut",
                "abbreviation": "CT"
            },
            {
                "name": "Delaware",
                "abbreviation": "DE"
            },
            {
                "name": "Florida",
                "abbreviation": "FL"
            },
            {
                "name": "Georgia",
                "abbreviation": "GA"
            },
            {
                "name": "Hawaii",
                "abbreviation": "HI"
            },
            {
                "name": "Idaho",
                "abbreviation": "ID"
            },
            {
                "name": "Illinois",
                "abbreviation": "IL"
            },
            {
                "name": "Indiana",
                "abbreviation": "IN"
            },
            {
                "name": "Iowa",
                "abbreviation": "IA"
            },
            {
                "name": "Kansas",
                "abbreviation": "KS"
            },
            {
                "name": "Kentucky",
                "abbreviation": "KY"
            },
            {
                "name": "Louisiana",
                "abbreviation": "LA"
            },
            {
                "name": "Maine",
                "abbreviation": "ME"
            },
            {
                "name": "Maryland",
                "abbreviation": "MD"
            },
            {
                "name": "Massachusetts",
                "abbreviation": "MA"
            },
            {
                "name": "Michigan",
                "abbreviation": "MI"
            },
            {
                "name": "Minnesota",
                "abbreviation": "MN"
            },
            {
                "name": "Mississippi",
                "abbreviation": "MS"
            },
            {
                "name": "Missouri",
                "abbreviation": "MO"
            },
            {
                "name": "Montana",
                "abbreviation": "MT"
            },
            {
                "name": "Nebraska",
                "abbreviation": "NE"
            },
            {
                "name": "Nevada",
                "abbreviation": "NV"
            },
            {
                "name": "New Hampshire",
                "abbreviation": "NH"
            },
            {
                "name": "New Jersey",
                "abbreviation": "NJ"
            },
            {
                "name": "New Mexico",
                "abbreviation": "NM"
            },
            {
                "name": "New York",
                "abbreviation": "NY"
            },
            {
                "name": "North Carolina",
                "abbreviation": "NC"
            },
            {
                "name": "North Dakota",
                "abbreviation": "ND"
            },
            {
                "name": "Ohio",
                "abbreviation": "OH"
            },
            {
                "name": "Oklahoma",
                "abbreviation": "OK"
            },
            {
                "name": "Oregon",
                "abbreviation": "OR"
            },
            {
                "name": "Pennsylvania",
                "abbreviation": "PA"
            },
            {
                "name": "Rhode Island",
                "abbreviation": "RI"
            },
            {
                "name": "South Carolina",
                "abbreviation": "SC"
            },
            {
                "name": "South Dakota",
                "abbreviation": "SD"
            },
            {
                "name": "Tennessee",
                "abbreviation": "TN"
            },
            {
                "name": "Texas",
                "abbreviation": "TX"
            },
            {
                "name": "Utah",
                "abbreviation": "UT"
            },
            {
                "name": "Vermont",
                "abbreviation": "VT"
            },
            {
                "name": "Virginia",
                "abbreviation": "VA"
            },
            {
                "name": "Washington",
                "abbreviation": "WA"
            },
            {
                "name": "West Virginia",
                "abbreviation": "WV"
            },
            {
                "name": "Wisconsin",
                "abbreviation": "WI"
            },
            {
                "name": "Wyoming",
                "abbreviation": "WY"
            }
        ];
    },

    //sets the default tab of the contacts task starter
    setDefaultTab :function (component, tabName) {
        component.set('v.showSpinner', true);
       // console.log('in common helper');

        var action = component.get("c.setContactDefaultTab");
                  
        action.setParams({
            'tabName' : tabName            
        });
        
        //creating a callback that is executed after the server side action is returned
        action.setCallback(this, function(response){
            //checking if the response is success
            if(response.getState() == 'SUCCESS'){       
                var result = response.getReturnValue();
                //console.log('result contact ' + JSON.stringify(result));
                if(result){
                    component.set("v.isSuccess",true);
                    component.set("v.str_successMsg", $A.get("$Label.c.Default_tab_is_updated"));

                    component.set('v.currentContact', result);
                    //console.log('contact starterTask: '+result.Default_Dashboard_Starter_Task__c);
                    
                    this.updateCurrentContact(component, result);
                                
                } else {
                    component.set("v.isError",true);
                    component.set("v.str_errorMsg","Error saving");                                 
                }
                //switching off spinner
                $A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
                component.set('v.showSpinner', false);
            }else{
                //setting the error flag and the message                
                component.set("v.isError",true);
                component.set("v.str_errorMsg","Error saving");
                component.set('v.showSpinner', false);
                $A.util.addClass(component.find("searchSpinnerId"), "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
    
    updateCurrentContact : function(component, con){
    	var providercache = JSON.parse(localStorage['providercache']);
    	providercache.currentContact = con;
    	localStorage['providercache'] = JSON.stringify(providercache);
        //component.set('v.currentContact', providercache.currentContact);
        /*var action = component.get("c.getContactRec");
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                component.set('v.currentContact', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);*/
    },

})