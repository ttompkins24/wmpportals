({
	initializeOptions : function(component) {
		component.set('v.selectedClaimStatus','');
		component.set('v.selectedLocation','');
		component.set('v.selectedProvider','');

		this.initializeClaimStatusOptions(component);
		this.initializeLocationOptions(component);
		this.initializeProviderOptions(component);
		this.initializeServiceDates(component);
	},

	searchClaimsRemote : function(component) {
		//console.log('claims start');
		component.set('v.noResults', false);
		component.set('v.showSpinner', true);
		component.set('v.isError', false);
		var claimSearchHeader = component.get('v.claimSearchHeader');
		var businessId = component.get('v.currentBusinessId');
		
		//create message to send to vf page
		var message = {header: JSON.stringify(claimSearchHeader), businessId: businessId};
		//console.log('message ' + message);


		//holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
        //console.log('vfOrigin ' + vfOrigin);

		//get vf page		
        var vfWindow = component.find('vfFrame').getElement().contentWindow;

        //post message to vf page
    	vfWindow.postMessage(message, vfOrigin);
    	//console.log('finished post message searchClaimsRemote');			
        
	},

	repaginate : function(component) {
		var claimSearchResults = component.get('v.claimSearchResults');
		var pageSize = component.get('v.pageSize');
        var paginationList = [];
		// set start as 0
		component.set('v.startPage',0);
		component.set('v.endPage',pageSize-1);
        component.set('v.currentPage', 1);

        for(var i=0; i< pageSize; i++){
            if(claimSearchResults.length > i) {
                paginationList.push(claimSearchResults[i]);
            }
        }
        component.set('v.paginationList', paginationList);
	},

	updateClaimRequestHeader : function(component) {
		// update the claim search header to make a new callout
        var claimSearchHeader = component.get('v.claimSearchHeader');
        claimSearchHeader.StatusCategory = component.get('v.selectedClaimStatus');
        claimSearchHeader.DateOfServiceStart = component.get('v.startServiceDate') || null;
        claimSearchHeader.DateOfServiceEnd = component.get('v.endServiceDate') || null;
        claimSearchHeader.ServiceOfficeGuids = component.get('v.selectedLocation') || null;
        claimSearchHeader.TreatingDentistGuids = component.get('v.selectedProvider') || null;

        component.set('v.claimSearchHeader', claimSearchHeader);
	},

	initializeClaimStatusOptions : function(component) {
		var defaultOptions = component.get('v.claimStatusOptionsDefault');
		//console.log('claimStatusOptionsDefault start init: '+defaultOptions);

		var selectedClaimStatusFromSearch = component.get('v.selectedClaimStatusFromSearch');
		//console.log('selectedClaimStatusFromSearch: '+selectedClaimStatusFromSearch);

		if(selectedClaimStatusFromSearch == 'All' || selectedClaimStatusFromSearch == '') { 
			var restrictedStatusOptions = defaultOptions;
			var index = restrictedStatusOptions.indexOf('All');
			if(index > -1) {
				restrictedStatusOptions.splice(index,1);
			}

			//console.log('restrictedStatusOptions: '+restrictedStatusOptions);
			component.set('v.claimStatusOptions', restrictedStatusOptions);

			//console.log('claimStatusOptionsDefault end init: '+component.get('v.claimStatusOptionsDefault'));
			//console.log('claim status set to all or left blank');
		}
		else {
			component.set('v.claimStatusOptions', selectedClaimStatusFromSearch);
			component.set('v.selectedClaimStatus',selectedClaimStatusFromSearch);
			component.set('v.claimStatusOptionsDisabled', true);
			//console.log('claim status is single value');
			//console.log('claim status not set to all');
		}
		//console.log('count of claim statuses selected from search: '+selectedClaimStatusFromSearch.length);
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

	initializeServiceDates : function(component) {
		component.set('v.startServiceDate', component.get('v.startServiceDateFromSearch'));
		component.set('v.endServiceDate', component.get('v.endServiceDateFromSearch'));
	},

	clearMultiPicklists : function(component ){
		var selectedLocationFromSearch = component.get('v.selectedLocationFromSearch');
		var selectedProviderFromSearch = component.get('v.selectedProviderFromSearch');
		var selectedClaimStatusFromSearch = component.get('v.selectedClaimStatusFromSearch');
        
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