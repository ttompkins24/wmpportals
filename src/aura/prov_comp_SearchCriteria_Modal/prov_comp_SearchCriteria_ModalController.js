({
	/*INITIALIZE THE COMPONENT*/
	doInit : function(component, event, helper) {
		//start the spinner
		var spinner = component.find('spinnerIdModal');
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.addClass(spinner, 'slds-is-fixed');
		
		
		helper.loadSearchCriteria(component, 1,'LastModifiedDate', 'DESC');
		helper.loadPageVariables(component);
	},
	
	/* UPDATE THE SORTING COLUMNS*/
	updateColumnSorting: function(component, event, helper){
		//start the spinner
		var spinner = component.find('spinnerIdModal');
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.addClass(spinner, 'slds-is-fixed');
		
		//get the element clicked
		var tar = event.currentTarget;
		var col = tar.dataset.col; //get column
		var fieldName = tar.dataset.fieldname;
		var direction = 'ASC';
		var pageNum = 1;
	
		//get the table 
		var table = $('#searchCriteriaTableId');
		//is this column not order
		if($A.util.hasClass(tar, 'notSorted')){
			$A.util.removeClass(tar, 'notSorted');
			if(col == 1){
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
		
		helper.loadSearchCriteria(component, pageNum, fieldName, direction);
		
	},
	
	defaultClose : function(component, event, helper){
        component.destroy();
    },
    
    redirectUrl : function(component, event, helper){

        var redirectEvent = $A.get('e.c:prov_event_Redirect');

		var selectItem = event.currentTarget;
		var location = selectItem.dataset.loc;
		var pageName = "member-eligibility";
		
		redirectEvent.setParams({
			'pageName' : pageName,
			'searchCriteriaId' : location
		});
		redirectEvent.fire();
		component.destroy();
    },
    
    firstPageClick : function(component, event, helper){
		//start the spinner
		var spinner = component.find('spinnerIdModal');
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.addClass(spinner, 'slds-is-fixed');
		
		//get the page variables applicable
		var direction = component.get('v.sortDirection');
		var fieldName = component.get('v.fieldNameSorted');
		
		//load the search criteria resultss
		helper.loadSearchCriteria(component, 1, fieldName, direction);
	},
	previousPageClick : function(component, event, helper){
		//start the spinner
		var spinner = component.find('spinnerIdModal');
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.addClass(spinner, 'slds-is-fixed');
		
		//get the page variables applicable
		var direction = component.get('v.sortDirection');
		var fieldName = component.get('v.fieldNameSorted');
		var pageNum = component.get('v.pageNum');
		
		//load the search criteria results
		helper.loadSearchCriteria(component, pageNum-1, fieldName, direction);
		
		component.set('v.pageNum', pageNum-1);
	},
	nextPageClick : function(component, event, helper){
		//start the spinner
		var spinner = component.find('spinnerIdModal');
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.addClass(spinner, 'slds-is-fixed');
		
		//get the page variables applicable
		var direction = component.get('v.sortDirection');
		var fieldName = component.get('v.fieldNameSorted');
		var pageNum = component.get('v.pageNum');
		
		//load the search criteria results
		helper.loadSearchCriteria(component, pageNum+1, fieldName, direction);
		
		component.set('v.pageNum', pageNum+1);
	},
	
})