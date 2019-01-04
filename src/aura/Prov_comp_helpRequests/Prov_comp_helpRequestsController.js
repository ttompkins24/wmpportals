({
	/**************************************************************************************************************
     * Method Name							: doInit
     * Developed By							: West Monroe Partners
     * Purpose								: To fetch the necessary information  
     * 											# Other information that needs to be displayed on the page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			1			January 2018		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	doInit : function(component, event, helper) {
		$A.util.removeClass(component.find("loadingSpinner"), "slds-hide");
		//starting spinner
		//started automatically
		//to get the total number
		//helper.fetchTotalCaseCount(component, helper);
		//to get the offset number of cases
		var sortField = component.get('v.fieldNameSorted');
		var sortDirection = component.get('v.sortDirection');
		helper.fetchRelatedCases(component, 1, sortField, sortDirection);
		helper.loadPageVariables(component);

	},
	
	fixDate : function(component, event, helper){
		helper.fixDate(component, event);
	},
	
	filterSearch : function(component, event, helper){
		$A.util.removeClass(component.find("loadingSpinner"), "slds-hide");
		var sortField = component.get('v.fieldNameSorted');
		var sortDirection = component.get('v.sortDirection');
		component.set('v.bln_isError', false);
		helper.fetchRelatedCases(component, 1, sortField, sortDirection);
		helper.loadPageVariables(component);
		
	},
	
	showHideFilter : function(component, event, helper){
		component.set('v.expandFilter', !component.get('v.expandFilter'));
	},
	
	clearFilters : function(component, event, helper){
		component.set('v.caseNumber', '');
		component.set('v.claimAuthNum', '');
		component.set('v.subscriberId', '');
		component.set('v.startServiceDate', null);
		component.set('v.endServiceDate', null);
	},
	/**************************************************************************************************************
     * Method Name							: redirectView
     * Developed By							: West Monroe Partners
     * Purpose								: To get the member id and the plan id to redirect the user to the respective page
     *										 
     History
     Version#		Build#		Date					by  						Comments
	 1.0			1			January 2018		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	redirectContactUs : function (component, event, helper){
		//get the member id and plan id
		var pageName = 'contact-us';
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
		       'pageName' : pageName
		});
		redirectEvent.fire();
	},
	
	/**************************************************************************************************************
     * Method Name							: clickNext
     * Developed By							: West Monroe Partners
     * Purpose								: To increase the page number by 1 and also call the server side call
     History
     Version#		Build#		Date					by  						Comments
	 1.0			1			January 2018		West Monroe Partners		See header - purpose

    ***************************************************************************************************************/
	clickNext : function (component, event, helper){
		//Switching on the spinner
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
		//setting the present page number
		var presentPageNumber = component.get("v.pageNum");
		presentPageNumber = presentPageNumber + 1;
		//added the present page number as 1 more
		component.set("v.pageNum", presentPageNumber);
		var sortField = component.get('v.fieldNameSorted');
		var sortDirection = component.get('v.sortDirection');
		//now calling the helper method to get related cases
		helper.fetchRelatedCases(component, presentPageNumber, sortField, sortDirection);
		window.scrollTo(0,0);
	},
	/**************************************************************************************************************
	 * Method Name							: clickPrevious
	 * Developed By							: West Monroe Partners
	 * Purpose								: To decrease the page number by 1 and also call the server side call
	 History
	 Version#		Build#		Date					by  						Comments
	 1.0			1			January 2018		West Monroe Partners		See header - purpose
	
	***************************************************************************************************************/
	clickPrevious : function (component, event, helper){
		//Switching on the spinner
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
		//setting the present page number
		var presentPageNumber = component.get("v.pageNum");
		presentPageNumber = presentPageNumber - 1;
		//added the present page number as 1 more
		component.set("v.pageNum", presentPageNumber);
		var sortField = component.get('v.fieldNameSorted');
		var sortDirection = component.get('v.sortDirection');
		//now calling the helper method to get related cases
		helper.fetchRelatedCases(component, presentPageNumber, sortField, sortDirection);
		window.scrollTo(0,0);
	},
	/**************************************************************************************************************
	 * Method Name							: clickFirst
	 * Developed By							: West Monroe Partners
	 * Purpose								: To set the page number to 1 and also call the server side call
	 History
	 Version#		Build#		Date					by  						Comments
	 1.0			1			January 2018		West Monroe Partners		See header - purpose
	
	***************************************************************************************************************/
	clickFirst : function (component, event, helper){
		//Switching on the spinner
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
		//setting the present page number
		var presentPageNumber = component.get("v.pageNum");
		presentPageNumber = 1;
		//added the present page number as 1 more
		component.set("v.pageNum", presentPageNumber);
		var sortField = component.get('v.fieldNameSorted');
		var sortDirection = component.get('v.sortDirection');
		//now calling the helper method to get related cases
		helper.fetchRelatedCases(component, presentPageNumber, sortField, sortDirection);
		window.scrollTo(0,0);
	},
	/**************************************************************************************************************
	 * Method Name							: redirectToCreateNewHelpRequest
	 * Developed By							: West Monroe Partners
	 * Purpose								: To redirect to create new help request page
	 History
	 Version#		Build#		Date					by  						Comments
	 1.0			1			January 2018		West Monroe Partners		See header - purpose
	
	***************************************************************************************************************/
	redirectToCreateNewHelpRequest : function(component, event, helper) {
		var selectItem = event.currentTarget;
		var pageName = selectItem.dataset.loc;
		//calling the redirectEvent
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
						'pageName' : pageName
		});
		redirectEvent.fire(); 
	},
	/**************************************************************************************************************
	 * Method Name							: redirectToDetailPage
	 * Developed By							: West Monroe Partners
	 * Purpose								: To redirect to create help request detail page
	 History
	 Version#		Build#		Date					by  						Comments
	 1.0			1			January 2018		West Monroe Partners		See header - purpose
	***************************************************************************************************************/
	redirectToDetailPage : function(component, event, helper){
		var caseid = event.currentTarget.dataset.caseid;
		
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
						'pageName' : "help-request-detail",
						'memberProfileGuid' : caseid
		});
		redirectEvent.fire();
		
	},
	
	/* UPDATE THE SORTING COLUMNS*/
	updateColumnSorting: function(component, event, helper){
		//start the spinner
		var spinner = component.find('loadingSpinner');
		$A.util.toggleClass(spinner, 'slds-hide');
		
		//get the element clicked
		var tar = event.currentTarget;
		var col = tar.dataset.col; //get column
		var fieldName = tar.dataset.fieldname;
		var direction = 'ASC';
		var pageNum = 1;
	
		//get the table 
		var table = $('#helpRequestTable');
		//is this column not order
		if($A.util.hasClass(tar, 'notSorted')){
			$A.util.removeClass(tar, 'notSorted');
			if(col == 3){
				//default last updated to descend. newest first
				$A.util.addClass(tar, 'sortDescend');
				//sortTable(table, col, 'DESC');
				direction = 'DESC';
			} else {
				$A.util.addClass(tar, 'sortAscend');
				//sortTable(table, col, 'ASC');
				direction = 'ASC';
			}
			$('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');

		} 
		else if($A.util.hasClass(tar, 'sortAscend')) {
			//column is currently sorted by ascending order, switch it
			$A.util.removeClass(tar, 'sortAscend')
			$A.util.addClass(tar, 'sortDescend');
			//sortTable(table, col, 'DESC');
			direction = 'DESC';
		}
		else {//target has sortDescend
			//column is currently sorted by descending order, switch it
			$A.util.addClass(tar, 'sortAscend');
			$A.util.removeClass(tar, 'sortDescend');
			//sortTable(table, col, 'ASC');
			direction = 'ASC';
		}
		component.set('v.sortDirection', direction);
		component.set('v.fieldNameSorted', fieldName);
		
		helper.fetchRelatedCases(component, pageNum, fieldName, direction);
		
		//hide the spinner - dont need since load search criteria will do it
		//$A.util.toggleClass(spinner, 'slds-hide');
	},
})