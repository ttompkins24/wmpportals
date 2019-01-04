({
	//initialize funtions
	doInit : function(component, event, helper) {
		//start the spinner
		var spinner = component.find('uploadSpinner_FAD');
		// console.log('spinner::'+spinner);
		$A.util.toggleClass(spinner, 'slds-hide');
		//load the portal config
		
		var paramMap = component.get('v.paramMap');
		// console.log('paramMap::'+JSON.stringify(paramMap));
		if(paramMap['show'] == 'office'){
			helper.retrieveProviders_Office(component);
		}else {
			helper.retrieveProviders_Dentist(component);
		}

		if(paramMap['loc'] != undefined){
			component.set('v.locSearched', paramMap['loc']);
		}
		
		if(paramMap['show'] != undefined){
			component.set('v.showSelected', paramMap['show']);
		}
		
		if(paramMap['sortBy'] != undefined){
			component.set('v.sortedBySelected', paramMap['sortBy']);
		}
		helper.retrievePagination(component);
		
	},
	
	//change the show by sort functionality
	changeShow : function(component, event, helper){
		var selectItem = event.currentTarget;
		var scName = selectItem.dataset.name;
		if( component.get('v.showSelected') != scName){
			//start the spinner
			var spinner = component.find('uploadSpinner_FAD');
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
	
	/*updateFilterClick : function(component, event, helper){
		var sortBy = component.find("sortById").get("v.value");
		var showBy = component.find("showById").get("v.value");
		
		if( component.get('v.showSelected') != showBy || component.get('v.sortedBySelected') != sortBy){
			//start spinner
			var spinner = component.find('uploadSpinner_FAD');
			$A.util.toggleClass(spinner, 'slds-hide');
			
			//set show selected
			
			
			//set sort by
		
			
			//component.set('v.sortedBySelected', scName);
		}
	},*/
	
	//change the sort by functionality
	changeSortedBy : function(component, event, helper){
		var selectItem = event.currentTarget;
		var scName = selectItem.dataset.name;
		
		if( component.get('v.sortedBySelected') != scName){
			//start the spinner
			var spinner = component.find('uploadSpinner_FAD');
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
		var spinner = component.find('uploadSpinner_FAD');
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
		var spinner = component.find('uploadSpinner_FAD');
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
		var spinner = component.find('uploadSpinner_FAD');
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
	
	

	backToSearch : function(component, event, helper){
		component.set('v.isSearch', true);
	}
})