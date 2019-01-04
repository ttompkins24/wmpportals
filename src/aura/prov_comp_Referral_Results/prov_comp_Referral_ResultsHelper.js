({
	initializeOptions : function(component) {
		component.set('v.selectedReferralStatus','');
		component.set('v.selectedLocation','');
		component.set('v.selectedProvider','');

		this.initializeReferralStatusOptions(component);
		this.initializeLocationOptions(component);
		this.initializeProviderOptions(component);
		this.initializeSubmittedDates(component);
	},

	/*searchReferrals2 : function(component) {
		//console.log('searchReferrals start');
		component.set('v.noResults', false);
		component.set('v.showSpinner', true);
		component.set('v.isError', false);
		var referralSearchHeader = component.get('v.referralSearchHeader');
		var getReferrals = component.get('c.getReferralHeaders');

		//console.log('searchReferrals early');
        getReferrals.setParams({
			"json" : JSON.stringify(referralSearchHeader),
			"businessId" : component.get('v.currentBusinessId')			
        });
        
		//console.log('searchReferrals middle: '+JSON.stringify(referralSearchHeader));
        getReferrals.setCallback(this,function(response){
            var state = response.getState();
            var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log('Error message: ' +
								 errors[0].message);
						component.set('v.isError', true);
						component.set('v.str_errorMsg','Search unavailable at this time. Please try again later.');
                    }
                } else {
                    //console.log('Unknown error');
                }
				component.set('v.showSpinner', false);
            //console.log('state: '+state);
            if(state === 'SUCCESS') {
				var result = response.getReturnValue();
				var returnValue = [];
				if(result['calloutSuccess']) {
					returnValue = result['calloutSuccess'];
				} else {
					returnValue = result['calloutError'];
					component.set('v.isError', true);
					component.set('v.str_errorMsg','External system is currently unavailable; please try again later. Displaying submitted referrals only.');
				}				
				//console.log('returnValue: '+JSON.stringify(returnValue));
				if(returnValue.length == 0) {
					component.set('v.noResults', true);
					component.set('v.paginationList', null);
					component.set('v.referralSearchResults', null);
					component.set('v.startPage',0);
					component.set('v.endPage',1);
					component.set('v.currentPage', 1);
				} else {
					var pageSize = component.get('v.pageSize');
					// hold all the records into an attribute named "referralSearchResults"
					var referralSearchResults = returnValue;
					referralSearchResults.sort(dynamicSort('ClaimNumber','desc'));
					
					component.set('v.referralSearchResults', referralSearchResults);
					// get size of all the records and then hold into an attribute "totalRecords"
					component.set('v.totalRecords', component.get('v.referralSearchResults').length);
					//console.log('totalRecords: '+component.get('v.totalRecords'));
					
					component.set('v.totalPages', Math.ceil(referralSearchResults.length / pageSize));
					this.repaginate(component);
					// //console.log('referralSearchResults: '+JSON.stringify(response.getReturnValue()));
				}
            }
			component.set('v.showSpinner', false);
			//console.log('searchReferrals end');
        });
		$A.enqueueAction(getReferrals);		
	},*/
	
	searchReferrals : function(component) {
		component.set('v.noResults', false);
		component.set('v.showSpinner', true);
		component.set('v.isError', false);
		var referralSearchHeader = component.get('v.referralSearchHeader');

        var obj = {};
        obj.searchParam = referralSearchHeader;
        obj.bid = component.get('v.currentBusinessId');//'90729872-d291-4514-81b4-2dd64c43f000';
        var tempList = JSON.stringify(obj);


		//holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';

    	// var vfOrigin = "https://dev1-greatdentalplans-community.cs13.force.com/Provider/";
		window.scrollTo(0,0);			

    	var vfWindow = component.find("vfFrame").getElement().contentWindow;
    	vfWindow.postMessage(tempList, vfOrigin);
        
		/*//console.log('searchReferrals middle: '+JSON.stringify(referralSearchHeader));
        getReferrals.setCallback(this,function(response){
            var state = response.getState();
            var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log('Error message: ' +
								 errors[0].message);
						component.set('v.isError', true);
						component.set('v.str_errorMsg','Search unavailable at this time. Please try again later.');
                    }
                } else {
                    //console.log('Unknown error');
                }
				component.set('v.showSpinner', false);
            //console.log('state: '+state);
            if(state === 'SUCCESS') {
				var result = response.getReturnValue();
				var returnValue = [];
				if(result['calloutSuccess']) {
					returnValue = result['calloutSuccess'];
				} else {
					returnValue = result['calloutError'];
					component.set('v.isError', true);
					component.set('v.str_errorMsg','External system is currently unavailable; please try again later. Displaying submitted referrals only.');
				}				
				//console.log('returnValue: '+JSON.stringify(returnValue));
				if(returnValue.length == 0) {
					component.set('v.noResults', true);
					component.set('v.paginationList', null);
					component.set('v.referralSearchResults', null);
					component.set('v.startPage',0);
					component.set('v.endPage',1);
					component.set('v.currentPage', 1);
				} else {
					var pageSize = component.get('v.pageSize');
					// hold all the records into an attribute named "referralSearchResults"
					var referralSearchResults = returnValue;
					referralSearchResults.sort(dynamicSort('ClaimNumber','desc'));
					
					component.set('v.referralSearchResults', referralSearchResults);
					// get size of all the records and then hold into an attribute "totalRecords"
					component.set('v.totalRecords', component.get('v.referralSearchResults').length);
					//console.log('totalRecords: '+component.get('v.totalRecords'));
					
					component.set('v.totalPages', Math.ceil(referralSearchResults.length / pageSize));
					this.repaginate(component);
					// //console.log('referralSearchResults: '+JSON.stringify(response.getReturnValue()));
				}
            }
			component.set('v.showSpinner', false);
			//console.log('searchReferrals end');
        });
		$A.enqueueAction(getReferrals);		
		 */
	},

	repaginate : function(component) {
		var referralSearchResults = component.get('v.referralSearchResults');
		var pageSize = component.get('v.pageSize');
        var paginationList = [];
		// set start as 0
		component.set('v.startPage',0);
		component.set('v.endPage',pageSize-1);
        component.set('v.currentPage', 1);

        for(var i=0; i< pageSize; i++){
            if(referralSearchResults.length > i) {
                paginationList.push(referralSearchResults[i]);
            }
        }
        component.set('v.paginationList', paginationList);
	},

	updateReferralRequestHeader : function(component) {
		// update the referral search header to make a new callout
        var referralSearchHeader = component.get('v.referralSearchHeader');
        referralSearchHeader.RequestStatus = (component.get('v.selectedReferralStatus') == 'Select' ? null : component.get('v.selectedReferralStatus'));
        referralSearchHeader.SubmittedDateStart = component.get('v.startReceivedDate') || null;
        referralSearchHeader.SubmittedDateEnd = component.get('v.endReceivedDate') || null;
        referralSearchHeader.ServiceOfficeGuids = component.get('v.selectedLocation') || null;
        referralSearchHeader.SubmittingDentistGuids = component.get('v.selectedProvider') || null;

        component.set('v.referralSearchHeader', referralSearchHeader);
	},

	initializeReferralStatusOptions : function(component) {
		var defaultOptions = component.get('v.referralStatusOptionsDefault');
		//console.log('referralStatusOptionsDefault start init: '+defaultOptions);

		var selectedReferralStatusFromSearch = component.get('v.selectedReferralStatusFromSearch');
		//console.log('selectedReferralStatusFromSearch: '+selectedReferralStatusFromSearch);

		if(selectedReferralStatusFromSearch == 'All' || selectedReferralStatusFromSearch == '') { 
			var restrictedStatusOptions = defaultOptions;
			var index = restrictedStatusOptions.indexOf('All');
			if(index > -1) {
				restrictedStatusOptions.splice(index,1);
			}

			//console.log('restrictedStatusOptions: '+restrictedStatusOptions);
			component.set('v.referralStatusOptions', restrictedStatusOptions);

			//console.log('referralStatusOptionsDefault end init: '+component.get('v.referralStatusOptionsDefault'));
			//console.log('referral status set to all or left blank');
		}
		else {
			component.set('v.referralStatusOptions', selectedReferralStatusFromSearch);
			component.set('v.selectedReferralStatus',selectedReferralStatusFromSearch);
			component.set('v.referralStatusOptionsDisabled', true);
			//console.log('referral status is single value');
			//console.log('referral status not set to all');
		}
		//console.log('count of referral statuses selected from search: '+selectedReferralStatusFromSearch.length);
	},

	initializeLocationOptions : function(component) {
		var defaultOptions = component.get('v.locationOptionsDefault');
		//console.log('locationOptionsDefault start init: '+defaultOptions);

		var selectedLocationFromSearch = component.get('v.selectedLocationFromSearch');
		//console.log('selectedLocationFromSearch: '+selectedLocationFromSearch);

		if(selectedLocationFromSearch == '') { 
			var restrictedStatusOptions = defaultOptions;

			//console.log('restrictedStatusOptions: '+restrictedStatusOptions);
			component.set('v.locationOptions', restrictedStatusOptions);

			//console.log('locationOptionsDefault end init: '+component.get('v.locationOptionsDefault'));
			//console.log('location set to all or left blank');
		}
		else {
			var locationOptions = [];
			var availableLocationMap = defaultOptions.reduce(function(map, obj) {
				map[obj.windward_guid__c] = obj;
				return map;
			}, {});
			// //console.log('map: '+JSON.stringify(availableLocationMap));
			// use forEach because IE11 doesn't support for...of
			selectedLocationFromSearch.split('; ').forEach(function(item) {
				locationOptions.push(availableLocationMap[item])
			});
			// just in case IE11 is retired...
			// for(var key of selectedLocationFromSearch.split('; ')) {
			// 	locationOptions.push(availableLocationMap[key]);
			// }
			component.set('v.locationOptions', locationOptions);
			if(selectedLocationFromSearch.split(';').length == 1) {
				component.set('v.selectedLocation',selectedLocationFromSearch);
				component.set('v.locationOptionsDisabled', true);
				//console.log('location is single value');
			}
			//console.log('location not set to all');
		}
		//console.log('count of locations selected from search : '+selectedLocationFromSearch.split(';').length);
	},
	
	initializeProviderOptions : function(component) {
		var defaultOptions = component.get('v.providerOptionsDefault');
		//console.log('providerOptionsDefault start init: '+defaultOptions);

		var selectedProviderFromSearch = component.get('v.selectedProviderFromSearch');
		//console.log('selectedProviderFromSearch: '+selectedProviderFromSearch);

		if(selectedProviderFromSearch == '') { 
			var restrictedStatusOptions = defaultOptions;

			//console.log('restrictedStatusOptions: '+restrictedStatusOptions);
			component.set('v.providerOptions', restrictedStatusOptions);

			//console.log('providerOptionsDefault end init: '+component.get('v.providerOptionsDefault'));
			//console.log('provider set to all or left blank');
		}
		else {
			var providerOptions = [];
			var availableProviderMap = defaultOptions.reduce(function(map, obj) {
				map[obj.windward_guid__c] = obj;
				return map;
			}, {});
			// //console.log('map: '+JSON.stringify(availableProviderMap));
			// use forEach because IE11 doesn't support for...of
			selectedProviderFromSearch.split('; ').forEach(function(item) {
				providerOptions.push(availableProviderMap[item])
			});
			// just in case IE11 is retired...
			// for(var key of selectedProviderFromSearch.split('; ')) {
			// 	providerOptions.push(availableProviderMap[key]);
			// }
			component.set('v.providerOptions', providerOptions);
			// //console.log('new provideroptions: '+JSON.stringify(providerOptions));
			if(selectedProviderFromSearch.split(';').length == 1) {
				component.set('v.selectedProvider',selectedProviderFromSearch);
				component.set('v.providerOptionsDisabled', true);
				//console.log('provider is single value');
			}
			//console.log('provider not set to all');
		}
		//console.log('count of providers selected from search: '+selectedProviderFromSearch.split(';').length);
	},

	initializeSubmittedDates : function(component) {
		component.set('v.startReceivedDate', component.get('v.startReceivedDateFromSearch'));
		component.set('v.endReceivedDate', component.get('v.endReceivedDateFromSearch'));
	},

	clearMultiPicklists : function(component ){
		var selectedLocationFromSearch = component.get('v.selectedLocationFromSearch');
		var selectedProviderFromSearch = component.get('v.selectedProviderFromSearch');
		var selectedReferralStatusFromSearch = component.get('v.selectedReferralStatusFromSearch');
        
        if(selectedLocationFromSearch == '' || selectedLocationFromSearch.split(';').length > 1) {
            component.set('v.locationDisplayedValue','');
		}
		
		if(selectedProviderFromSearch == '' || selectedProviderFromSearch.split(';').length > 1) { 
			component.set('v.providerDisplayedValue','');
		}
		component.set('v.selectedProvider', selectedProviderFromSearch);
		//console.log('selectedProvider 44: ',component.get('v.selectedProvider'));
	}
})