({
	initialzeFilterFields : function(component) {
		component.set('v.startReleasedDate', component.get('v.startReleasedDateFromSearch'));
		component.set('v.endReleasedDate', component.get('v.endReleasedDateFromSearch'));
		component.set('v.selectedPaymentMethod', component.get('v.selectedPaymentMethodFromSearch'));
		component.set('v.checkNumber', component.get('v.checkNumberFromSearch'));
		component.set('v.payerName', component.get('v.payerNameFromSearch'));
	},

	downloadPDFRemote : function(component, event, helper) {
        console.log('downloadPDF1');
		//turn on spinner
		component.set('v.showSpinner', true);

		//get the EOBLink to Download
        var index = event.getSource().get('v.name');
		var eobList = component.get('v.eobSearchResults');
		console.log('index: '+index);
		console.log('selected EOB: '+JSON.stringify(eobList[index]));
		var downloadLink = eobList[index].EobLink;
		var name = eobList[index].EobId;
		
		//create message to send to vf page
		var message = {type: "eob", str: downloadLink, name:name};
		console.log('message ' + message);

		//holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
        console.log('vfOrigin ' + vfOrigin);

		//get vf page		
        var vfWindow = component.find('vfFrame').getElement().contentWindow;

        //post message to vf page
    	vfWindow.postMessage(message, vfOrigin);
    	console.log('finished post message downloadPDFRemote');			
	},

	searchEOBs : function(component) {
		console.log('searchEOBs Remote start');
		component.set('v.noResults', false);
		component.set('v.showSpinner', true);
		component.set('v.isError', false);

		var eobSearchParamMap = component.get('v.eobSearchParamMap');
		var jsonStr = JSON.stringify(eobSearchParamMap);
		var message = {type: "eobList", str: jsonStr};
		console.log('message ' + message);

		//holds the origin of the message originating from the Visual Force page
        var vfOrigin = $A.get('$Label.c.Member_Eligibility_VF_URL') + '/Provider/';
        console.log('vfOrigin ' + vfOrigin);
		window.scrollTo(0,0);

        var vfWindow = component.find('vfFrame').getElement().contentWindow;

    	vfWindow.postMessage(message, vfOrigin);
    	console.log('finished post message');			

	},

	updateEOBSearchParamMap : function(component) {
		console.log('updateEOBSearchParamMap start');
        var eobSearchParamMap = component.get('v.eobSearchParamMap');
        eobSearchParamMap['PaymentType'] = component.get('v.selectedPaymentMethod');
        eobSearchParamMap['StartDate'] = component.get('v.startReleasedDate') || null;
        eobSearchParamMap['EndDate'] = component.get('v.endReleasedDate') || null;
        eobSearchParamMap['PayerName'] = component.get('v.payerName') || null;
		eobSearchParamMap['CheckOrEftNumber'] = component.get('v.checkNumber') || null;
		
		eobSearchParamMap.SortBy = 'updateEOBSearchParamMap';
		eobSearchParamMap.SortDirection = 'Descending';

		component.set('v.eobSearchParamMap', eobSearchParamMap);
		console.log('updateEOBSearchParamMap: '+JSON.stringify(eobSearchParamMap));

		$('.sortable').removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');
		$('.testScript_checkNumberSort').addClass('sortDescend').addClass('sorted');
		
		console.log('updateEOBSearchParamMap end');
	},

	clearFilterFields : function(component) {
		component.set('v.selectedPaymentMethod', 'All');
		component.set('v.checkNumber', null);
		component.set('v.payerName', null);
		component.set('v.startReleasedDate', null);
		component.set('v.endReleasedDate', null);
	},

	initializeQuickActions : function(component) {
		var quickActions = [
			{label: "Download Original PDF", value: "download"}];
		component.set('v.quickActions', quickActions);
		console.log('quickActions: '+JSON.stringify(component.get('v.quickActions')));
	}
})