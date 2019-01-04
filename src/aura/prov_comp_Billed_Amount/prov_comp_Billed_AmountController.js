({
    init : function(component, event, helper) {
    	//console.log('billed amount init');
    	var fieldName = component.get('v.fieldNameSorted');
    	var sortDirection = component.get('v.sortDirection');
        helper.getBilledAmount(component, '1', fieldName, sortDirection);
        helper.loadPageVariables(component);
    },  
    addBilledAmount: function(component, event, helper) {        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":"/billed-amount-detail"
        });
        urlEvent.fire();
    },
   
    viewBilledAmount : function(component, event, helper) {
        var billedAmountId = event.currentTarget.dataset.billed;
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":"/billed-amount-detail?id=" + billedAmountId
        });
        urlEvent.fire();
    },
    
    deleteClick : function(component,event, helper){
	    if( window.confirm('Are you sure you want to delete this billed amount?')){
	    	var tar = event.currentTarget;
	
			$(tar).parent().parent().remove();
			
	    	var billedAmountId = tar.dataset.billed;
	    	helper.handleDelete(component, billedAmountId);
    	}
    },
    
    updateColumnSorting : function(component, event, helper){
    	//start the spinner
		 $A.util.addClass(component.find("saving-backdrop"), "slds-show");
         $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
		
		//get the element clicked
		var tar = event.currentTarget;
		var col = tar.dataset.col; //get column
		var fieldName = tar.dataset.fieldname;
		var direction = 'ASC';
		var pageNum = 1;

		//get the table 
		var table = $('#billedAmountTableId');		

		//is this column not order
		if($A.util.hasClass(tar, 'notSorted')){
			$A.util.removeClass(tar, 'notSorted');
			direction='ASC';
			$A.util.addClass(tar, 'sortAscend');
			$('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');

		} 
		else if($A.util.hasClass(tar, 'sortAscend')) {
			//column is currently sorted by ascending order, switch it
			$A.util.removeClass(tar, 'sortAscend')
			$A.util.addClass(tar, 'sortDescend');
			direction='DESC';
		}
		else {//target has sortDescend
			//column is currently sorted by descending order, switch it
			$A.util.addClass(tar, 'sortAscend');
			$A.util.removeClass(tar, 'sortDescend');
			direction='ASC';
		}
		
		component.set('v.sortDirection', direction);
		component.set('v.fieldNameSorted', fieldName);
		component.set('v.pageNum', pageNum);
		
		helper.getBilledAmount(component, pageNum, fieldName, direction);
		//hide the spinner
		 $A.util.addClass(component.find("saving-backdrop"), "slds-hide");
         $A.util.removeClass(component.find("saving-backdrop"), "slds-show");
    },
    
    /***
		METHOD TO GET FIRST PAGE OF RESULTS
	 ***/
	firstPageClick : function(component, event, helper){
		//start the spinner
		var spinner = component.find('spinnerId');
		$A.util.toggleClass(spinner, 'slds-hide');
		
		//get the page variables applicable
		var direction = component.get('v.sortDirection');
		var fieldName = component.get('v.fieldNameSorted');
		
		//load the search criteria resultss
		helper.getBilledAmount(component, 1, fieldName, direction);
		component.set('v.pageNum', 1);
	},
	/***
		METHOD TO GET PREVIOUS PAGE OF RESULTS
	 ***/
	previousPageClick : function(component, event, helper){
		//start the spinner
		var spinner = component.find('spinnerId');
		$A.util.toggleClass(spinner, 'slds-hide');
		
		//get the page variables applicable
		var direction = component.get('v.sortDirection');
		var fieldName = component.get('v.fieldNameSorted');
		var pageNum = component.get('v.pageNum');
		
		//load the search criteria results
		helper.getBilledAmount(component, pageNum-1, fieldName, direction);
		
		//set the page to the previous number
		component.set('v.pageNum', pageNum-1);
		
		//no need to hide spinner since loadSearchCriteria will do that
	},
	
	/***
		METHOD TO GET NEXT PAGE OF RESULTS
	 ***/
	nextPageClick : function(component, event, helper){
		//start the spinner
		var spinner = component.find('spinnerId');
		$A.util.toggleClass(spinner, 'slds-hide');
		
		//get the page variables applicable
		var direction = component.get('v.sortDirection');
		var fieldName = component.get('v.fieldNameSorted');
		var pageNum = component.get('v.pageNum');
		
		//load the search criteria results
		helper.getBilledAmount(component, pageNum+1, fieldName, direction);
		
		//set the new page number
		component.set('v.pageNum', pageNum+1);
		
		//no need to hide spinner since loadSearchCriteria will do that
	},
})