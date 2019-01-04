({
	initializeOptions : function(component) {
		component.set('v.selectedAuthStatus','');
		component.set('v.selectedLocation','');
		component.set('v.selectedProvider','');

		this.initializeAuthStatusOptions(component);
		this.initializeLocationOptions(component);
		this.initializeProviderOptions(component);
		this.initializeSubmittedDates(component);
	},

	searchAuthsRemote : function(component) {
		//console.log('searchAuths start');
		component.set('v.noResults', false);
		component.set('v.showSpinner', true);
		component.set('v.isError', false);
		var authSearchHeader = component.get('v.authSearchHeader');
		var businessId = component.get('v.currentBusinessId');
		
		//create message to send to vf page
		var message = {header: JSON.stringify(authSearchHeader), businessId: businessId};
		//console.log('message ' + message);


		//holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
        //console.log('vfOrigin ' + vfOrigin);

		//get vf page		
        var vfWindow = component.find('vfFrame').getElement().contentWindow;

        //post message to vf page
    	vfWindow.postMessage(message, vfOrigin);
    	//console.log('finished post message searchAuthsRemote');			
        
	},

	repaginate : function(component) {
		var authSearchResults = component.get('v.authSearchResults');
		var pageSize = component.get('v.pageSize');
        var paginationList = [];
		// set start as 0
		component.set('v.startPage',0);
		component.set('v.endPage',pageSize-1);
        component.set('v.currentPage', 1);

        for(var i=0; i< pageSize; i++){
            if(authSearchResults.length > i) {
                paginationList.push(authSearchResults[i]);
            }
        }
        component.set('v.paginationList', paginationList);
	},

	updateAuthRequestHeader : function(component) {
		// update the pre-auth search header to make a new callout
        var authSearchHeader = component.get('v.authSearchHeader');
        authSearchHeader.StatusCategory = component.get('v.selectedAuthStatus');
        authSearchHeader.ReceivedDateStart = component.get('v.startSubmittedDate') || null;
        authSearchHeader.ReceivedDateEnd = component.get('v.endSubmittedDate') || null;
        authSearchHeader.ServiceOfficeGuids = component.get('v.selectedLocation') || null;
        authSearchHeader.TreatingDentistGuids = component.get('v.selectedProvider') || null;

        component.set('v.authSearchHeader', authSearchHeader);
	},

	initializeAuthStatusOptions : function(component) {
		var defaultOptions = component.get('v.authStatusOptionsDefault');
		//console.log('authStatusOptionsDefault start init: '+defaultOptions);

		var selectedAuthStatusFromSearch = component.get('v.selectedAuthStatusFromSearch');
		//console.log('selectedAuthStatusFromSearch: '+selectedAuthStatusFromSearch);

		if(selectedAuthStatusFromSearch == 'All' || selectedAuthStatusFromSearch == '') { 
			var restrictedStatusOptions = defaultOptions;
			var index = restrictedStatusOptions.indexOf('All');
			if(index > -1) {
				restrictedStatusOptions.splice(index,1);
			}

			//console.log('restrictedStatusOptions: '+restrictedStatusOptions);
			component.set('v.authStatusOptions', restrictedStatusOptions);

			//console.log('authStatusOptionsDefault end init: '+component.get('v.authStatusOptionsDefault'));
			//console.log('auth status set to all or left blank');
		}
		else {
			component.set('v.authStatusOptions', selectedAuthStatusFromSearch);
			component.set('v.selectedAuthStatus',selectedAuthStatusFromSearch);
			component.set('v.authStatusOptionsDisabled', true);
			//console.log('auth status is single value');
			//console.log('auth status not set to all');
		}
		//console.log('count of auth statuses selected from search: '+selectedAuthStatusFromSearch.length);
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
		component.set('v.startSubmittedDate', component.get('v.startSubmittedDateFromSearch'));
		component.set('v.endSubmittedDate', component.get('v.endSubmittedDateFromSearch'));
	},

	clearMultiPicklists : function(component ){
		var selectedLocationFromSearch = component.get('v.selectedLocationFromSearch');
		var selectedProviderFromSearch = component.get('v.selectedProviderFromSearch');
		var selectedAuthStatusFromSearch = component.get('v.selectedAuthStatusFromSearch');
        
        if(selectedLocationFromSearch == '' || selectedLocationFromSearch.split(';').length > 1) {
            component.set('v.locationDisplayedValue','');
		}
		
		if(selectedProviderFromSearch == '' || selectedProviderFromSearch.split(';').length > 1) { 
			component.set('v.providerDisplayedValue','');
		}
	}
})