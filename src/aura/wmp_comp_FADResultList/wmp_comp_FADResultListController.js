({
	//initialize funtions
	doInit : function(component, event, helper) {
		//start the spinner
		var spinner = component.find('uploadSpinner');
		console.log('spinner::'+spinner);
		$A.util.toggleClass(spinner, 'slds-hide');
		
		//get the url parameters
		helper.decodeURLParams(component);
		//load the portal config
		helper.helperLoadConfig(component);
		var paramMap = component.get('v.paramMap');
		if(paramMap['show'] == 'office'){
			helper.retrieveProviders_Office(component);
		}else {
			helper.retrieveProviders_Dentist(component);
		}
		
		helper.retrievePagination(component);
		
	},
	
	//change the show by sort functionality
	changeShow : function(component, event, helper){
		var selectItem = event.currentTarget;
		var scName = selectItem.dataset.name;
		if( component.get('v.showSelected') != scName){
			//start the spinner
			var spinner = component.find('uploadSpinner');
			$A.util.toggleClass(spinner, 'slds-hide');
			
			component.set('v.showSelected', scName);
	
			var paramMap = component.get('v.paramMap');
			paramMap['show'] = scName;
			component.set('v.paramMap', paramMap);
			
			if(scName == 'office'){
				helper.retrieveProviders_Office(component);
			}else {
				helper.retrieveProviders_Dentist(component);
			}
			helper.retrievePagination(component);
		}
	},
	
	//change the sort by functionality
	changeSortedBy : function(component, event, helper){
		var selectItem = event.currentTarget;
		var scName = selectItem.dataset.name;
		
		if( component.get('v.sortedBySelected') != scName){
			//start the spinner
			var spinner = component.find('uploadSpinner');
			$A.util.toggleClass(spinner, 'slds-hide');
		
			component.set('v.sortedBySelected', scName);
			
			var paramMap = component.get('v.paramMap');
			paramMap['sortBy'] = scName;
			
			component.set('v.paramMap', paramMap);
			if(paramMap['show'] == 'office'){
				helper.retrieveProviders_Office(component);
			}else {
				helper.retrieveProviders_Dentist(component);
			}
			helper.retrievePagination(component);
		}
	},
	
	//click the next page button, go to the next page and render the next offices/dentists
	nextPageClick : function(component, event, helper){
		//get the spinner and start it
		var spinner = component.find('uploadSpinner');
		$A.util.toggleClass(spinner, 'slds-hide');
		
		//get the current pageNum
		var pageNum = component.get('v.pageNum');
		
		//set the new current page Num
		component.set('v.pageNum', pageNum + 1);
		
		helper.setResultList(component);
		//end and remove the spinner
		$A.util.toggleClass(spinner, 'slds-hide');
		window.scrollTo(0,0);
		
	},
	
	//show the previous page of results
	previousPageClick : function(component, event, helper){
		//get the spinner and start it
		var spinner = component.find('uploadSpinner');
		$A.util.toggleClass(spinner, 'slds-hide');
		
		//get the current pageNum
		var pageNum = component.get('v.pageNum');
		
		//set the new current page Num
		component.set('v.pageNum', pageNum - 1);
		
		helper.setResultList(component);
		//end and remove the spinner
		$A.util.toggleClass(spinner, 'slds-hide');
		window.scrollTo(0,0);
	},
	
	//show the results that were on the first page
	firstPageClick : function(component, event, helper){
		//get the spinner and start it
		var spinner = component.find('uploadSpinner');
		$A.util.toggleClass(spinner, 'slds-hide');
		
		//get the current pageNum
		var pageNum = component.get('v.pageNum');
		
		//set the new current page Num
		component.set('v.pageNum',  1);
		
		helper.setResultList(component);
		//end and remove the spinner
		$A.util.toggleClass(spinner, 'slds-hide');
		window.scrollTo(0,0);
	},
	
	//chanege the show by for the mobile
	changeShowM : function(component, event, helper){
		//start the spinner
		var spinner = component.find('uploadSpinner');
		$A.util.toggleClass(spinner, 'slds-hide');
		
		var scName = component.get('v.showSelected');
		
			//component.set('v.showSelected', scName);
	
		var paramMap = component.get('v.paramMap');
		paramMap['show'] = scName;
		component.set('v.paramMap', paramMap);
		
		if(scName == 'office'){
			helper.retrieveProviders_Office(component);
		}else {
			helper.retrieveProviders_Dentist(component);
		}
		helper.retrievePagination(component);
		
	},
	
	//change the sort by for the mobile
	changeSortedByM : function(component, event, helper){
		//start the spinner
		var spinner = component.find('uploadSpinner');
		$A.util.toggleClass(spinner, 'slds-hide');
		
		var scName = component.get('v.sortedBySelected');
		
		component.set('v.sortedBySelected', scName);
		
		var paramMap = component.get('v.paramMap');
		paramMap['sortBy'] = scName;
		
		component.set('v.paramMap', paramMap);
		if(paramMap['show'] == 'office'){
			helper.retrieveProviders_Office(component);
		}else {
			helper.retrieveProviders_Dentist(component);
		}
		helper.retrievePagination(component);
	},
})