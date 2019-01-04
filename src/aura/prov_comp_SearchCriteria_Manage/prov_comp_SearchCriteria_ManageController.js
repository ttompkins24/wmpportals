({
	
	/*INITIALIZE THE COMPONENT*/
	doInit : function(component, event, helper) {
		//console.log('doInit');
		//load the search criteria items
		helper.loadSearchCriteria(component, 1,'LastModifiedDate', 'DESC');
		helper.loadPageVariables(component);
	},
	
	launchModal : function(component, event, helper){
		$A.createComponent(
			'c:prov_comp_SearchCriteria_Modal',
			{},
			function(newModal, status, errorMessage){
				//Add the new button to the body array
				if (status === "SUCCESS") {
					var body = component.get("v.body");
					body.push(newModal);
					component.set('v.body', body);
				}
			}
		);
	},
	
	updateTriggerLabel: function(cmp, event) {
        var triggerCmp = cmp.find("trigger");
        if (triggerCmp) {
            var source = event.getSource();
            var label = source.get("v.label");
            triggerCmp.set("v.label", label);
        }
    },
	
	
	/* UPDATE THE SORTING COLUMNS*/
	updateColumnSorting: function(component, event, helper){
		//start the spinner
		var spinner = component.find('spinnerId');
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
		
		//hide the spinner - dont need since load search criteria will do it
		//$A.util.toggleClass(spinner, 'slds-hide');
	},
	
	deleteClick : function(component, event, helper){
		//console.log('deleteClick...');
		var confirmSave = confirm('Are you sure you want to delete this record?');
		if(!confirmSave) return;
		//start the spinner
		var spinner = component.find('spinnerId');
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.addClass(spinner, 'slds-is-fixed');
		
		//get the element clicked
		var tar = event.currentTarget;
		var scId = tar.dataset.scid; //get column

		$(tar).parent().parent().remove();
		$A.util.toggleClass(spinner, 'slds-hide');
		helper.generateMessage(component, 'success', 'Record successfully deleted.');
		helper.deleteSearchCriteria(component, scId);

		//DO NOT NEED TO HIDE THE SPINNER SINCE THE LoadSearchCriteria function will do that
	},
	
	/* 
		Edit button is clicked on the row of the table, show the input name for that row.
	 	Hide the edit button and delete button. Show the save and cancel button
	*/
	editClick : function(component, event, helper){
		//console.log('editClick...');
		//start the spinner
		var spinner = component.find('spinnerId');
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.addClass(spinner, 'slds-is-fixed');
		
		//get the element clicked
		var tar = event.currentTarget;
		var scId = tar.dataset.scid; //get column
		
		
		//get the first td of the row to flip the input/ output
		var firstTD = $(tar).parent().siblings()[0];
		//get the value from the input value. 

		//hide the output of the name
		$(firstTD).find('.scNameOutput').addClass('hide');
		var scName = $(firstTD).find('.scNameOutput').text();
		//remove the hide class from the input name
		$(firstTD).find('.scNameInput').val(scName);
		$(firstTD).find('.scNameInput').removeClass('hide');

		//switch the action buttons, hide edit and delete button and show save button
		$(tar).addClass('hide');
		$(tar).parent().find('.deleteLink').addClass('hide');
		$(tar).parent().find('.saveButton').removeClass('hide');
		$(tar).parent().find('.closeButton').removeClass('hide');
		
		//hide the spinner
		$A.util.toggleClass(spinner, 'slds-hide');
	},
	
	
	/***
		METHOD THAT HANDLES THE SAVE BUTTON CLICK WHEN TRYING TO EDIT THE NAME
	 ***/
	saveClick : function(component, event, helper){
		var confirmSave = confirm('Are you sure you want to update this record?');
		if(confirmSave) {
			//start the spinner
			var spinner = component.find('spinnerId');
			$A.util.toggleClass(spinner, 'slds-hide');
			$A.util.addClass(spinner, 'slds-is-fixed');
			
			//get the element clicked
			var tar = event.currentTarget;
			var scId = tar.dataset.scid; //get column
			
			//get the first td of the row to flip the input/ output
			var firstTD = $(tar).parent().siblings()[0];
			var currentTR = $(tar).parent().parent();
			
			//get the value from the input value. 
			var scName = $(firstTD).find('.scNameInput').val();
			//check to see that something is entered
			if(scName == '' || scName == undefined || scName == null){
				var scInputError =  $(firstTD).find('.errorOutput');
				$(scInputError).removeClass('hide');
				//add error class to input element and make sure it shown
				$(firstTD).find('.scNameInput').addClass('errorInputForm').removeClass('hide');
				$(scInputError).text('Please fill this field out');
				//add placeholder text into the input text
				//$(firstTD).find('.scNameInput').attr("placeholder","Please fill out");
	
				//show error message
				helper.generateMessage(component, 'error', 'Error has occured. Please review the errors below.');
				
				//hide the spinner
				$A.util.toggleClass(spinner, 'slds-hide');
				//exit method
				return false;
			} else{
				//console.log('no error');
				scName = scName.trim();
				var oldSCName = $(firstTD).find('.scNameOutput').text();
				
				//change the data value with the new entered value
				$(firstTD).attr('data-value', scName);
				//remove the hide class for the output of the name
				$(firstTD).find('.scNameOutput').text(scName);
				$(firstTD).find('.scNameOutput').removeClass('hide');
				//add the hide class for the input name
				$(firstTD).find('.scNameInput').addClass('hide');
		
				//switch the action buttons, show edit and delete button and hide save button
				$(tar).addClass('hide');
				$(tar).parent().find('.closeButton').addClass('hide');
				$(tar).parent().find('.deleteLink').removeClass('hide');
				$(tar).parent().find('.editLink').removeClass('hide');
				
				//check to see if value has changed, if yes then update the record.
				if(oldSCName == scName){
					helper.generateMessage(component, 'success', 'Record successfully updated.');
				}else {
					//update the search criteria
					helper.updateSearchCriteria(component, scId, scName);
				}
		
				//hide the spinner
				$A.util.toggleClass(spinner, 'slds-hide');
				$A.util.removeClass(spinner, 'slds-is-fixed');
			}
		}
	},
	
	/***
		METHOD THAT HANDLES THE CANCEL/CLOSE BUTTON CLICK WHEN TRYING TO EDIT THE NAME
	 ***/
	closeClick : function(component, event, helper){
		//console.log('closeClick...');
		//start the spinner
		var spinner = component.find('spinnerId');
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.addClass(spinner, 'slds-is-fixed');
		//get the element clicked
		var tar = event.currentTarget;
		var scId = tar.dataset.scid; //get column
		var obj = tar.dataset.scobj; //get column
		//get the first td of the row to flip the input/ output
		var firstTD = $(tar).parent().siblings()[0];
		
		var scInputError =  $(firstTD).find('.errorOutput');
		$(scInputError).addClass('hide');
		$(scInputError).text('');
		
		//remove the hide class for the output of the name
		$(firstTD).find('.scNameOutput').removeClass('hide');
		//add the hide class for the input name
		$(firstTD).find('.scNameInput').addClass('hide').removeClass('errorInputForm');

		//switch the action buttons, show edit and delete button and hide save button
		$(tar).addClass('hide');
		$(tar).parent().find('.saveButton').addClass('hide');
		$(tar).parent().find('.deleteLink').removeClass('hide');
		$(tar).parent().find('.editLink').removeClass('hide');
		

		//hide the spinner
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.removeClass(spinner, 'slds-is-fixed');
	}, 
	
	/***
		METHOD TO GET FIRST PAGE OF RESULTS
	 ***/
	firstPageClick : function(component, event, helper){
		//start the spinner
		var spinner = component.find('spinnerId');
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.addClass(spinner, 'slds-is-fixed');
		
		//get the page variables applicable
		var direction = component.get('v.sortDirection');
		var fieldName = component.get('v.fieldNameSorted');
		
		//load the search criteria resultss
		helper.loadSearchCriteria(component, 1, fieldName, direction);
	},
	/***
		METHOD TO GET PREVIOUS PAGE OF RESULTS
	 ***/
	previousPageClick : function(component, event, helper){
		//start the spinner
		var spinner = component.find('spinnerId');
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.addClass(spinner, 'slds-is-fixed');
		
		//get the page variables applicable
		var direction = component.get('v.sortDirection');
		var fieldName = component.get('v.fieldNameSorted');
		var pageNum = component.get('v.pageNum');
		
		//load the search criteria results
		helper.loadSearchCriteria(component, pageNum-1, fieldName, direction);
		
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
		$A.util.addClass(spinner, 'slds-is-fixed');
		
		//get the page variables applicable
		var direction = component.get('v.sortDirection');
		var fieldName = component.get('v.fieldNameSorted');
		var pageNum = component.get('v.pageNum');
		
		//load the search criteria results
		helper.loadSearchCriteria(component, pageNum+1, fieldName, direction);
		
		//set the new page number
		component.set('v.pageNum', pageNum+1);
		
		//no need to hide spinner since loadSearchCriteria will do that
	},
	
	/***
		METHOD TO FLIP BACK TO THE MEMBER ELIGIBILITY SEARCH
	 ***/
	back2MemEligibility : function(component, event, helper){
		component.set('v.showSearch', true);
		component.set('v.showSearchCriteria', false);
	},
	
	/***
		METHOD POPULATE THE MEMBER ELIGIBILITY SEARCH WITH THE SELECTED SEARCH CRITERIA
	 ***/
	selectSearchCriteria : function(component, event, helper){
		//get the element clicked
		var tar = event.currentTarget;
		var searchCriteriaItem = tar.dataset.scid; //get column
		
		helper.redirectUrl(component, event, helper, searchCriteriaItem);
	},
	
	preventDefault : function(component, event, helper){
		event.preventDefault();
	},
	
	getMenuSelected: function(cmp) {
        var menuItems = cmp.find("checkbox");
        var values = [];
        for (var i = 0; i < menuItems.length; i++) {
            var c = menuItems[i];
            if (c.get("v.selected") === true) {
                values.push(c.get("v.label"));
            }
        }
        //console.log('values::'+values.join(","));
//        var resultCmp = cmp.find("result");
//        resultCmp.set("v.value", values.join(","));
    },
})