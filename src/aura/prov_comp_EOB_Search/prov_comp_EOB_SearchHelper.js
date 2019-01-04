({    
    createEOBSearchHeader : function(component) {
        var eobSearchParamMap = component.get('v.eobSearchParamMap') || {};
        component.set('v.eobSearchParamMap', eobSearchParamMap);
    },

    updateEOBSearchHeader : function(component) {
        console.log('updateEOBSearchHeader start');
        var eobSearchParamMap = component.get('v.eobSearchParamMap');
        eobSearchParamMap = this.createParamMap(component);
        component.set('v.eobSearchParamMap', eobSearchParamMap);
        
        console.log('eobSearchHeader after update: '+JSON.stringify(component.get('v.eobSearchHeader')));
        console.log('updateEOBSearchHeader end');
    },

    createParamMap : function(component) {
        var businessid = component.get('v.currentBusinessId');// gets current business id   
        var providercache = JSON.parse(localStorage['providercache']);//gets the full cache wrapper
        var businessGuid = providercache.businessMap[businessid].windward_guid__c;//gets the guid 
        var routeId = sessionStorage['portalconfig_lob']; 

		var selectedPaymentMethod = component.get('v.selectedPaymentMethod');
		var checkNumber = component.get('v.checkNumber') || null;
		var payerName = component.get('v.payerName') || null;
		var payeeName = component.get('v.payeeName') || null;
		var startReleasedDate = component.get('v.startReleasedDate') || null;
        var endReleasedDate = component.get('v.endReleasedDate') || null;
        var currentPage = component.get('v.currentPage') || '1';

        //updating sortby from CheckOrEftNumber to CheckOrEftReleaseDate
		var paramMap = {
			'BusinessGuid' : businessGuid, 'RouteId' : routeId, 
			'PaymentType' : selectedPaymentMethod, 'CheckOrEftNumber' : checkNumber, 
			'PayerName' : payerName, 'PayeeName' : payeeName, 'Page' : currentPage,
            'StartDate' : startReleasedDate, 'EndDate' : endReleasedDate,
            'SortBy' : 'CheckOrEftReleaseDate', 'SortDirection' : 'Descending'};

		console.log('paramMap: '+JSON.stringify(paramMap));
		
		return paramMap;
	},

    initializePaymentStatusOptions : function(component) {
        var paymentMethodOptions = ["All","Check","EFT"];
        component.set('v.paymentMethodOptions', paymentMethodOptions);
        component.set('v.selectedPaymentMethod', 'All'); 
    }
})