({
	/**
	 * Find the selected plan and query for the over view information
	 */
	init : function(component, event, helper) {
		var coverageId;
		var plans = component.get('v.plans');
		if(plans && plans.length > 0) {
			coverageId = plans[0].coverage.MemberCoverageGUID__c;
			component.set('v.selectedPlan', plans[0]);
		} else {
			component.set('v.selectedPlan', {});
		}
		////console.log('### selectedPlan: ' + JSON.stringify(plans[0]));
        helper.getMemberOverview(component, component.get('v.params.id'), coverageId);
    },
    /**
     * If there are multiple plans, allow the user to switch through the plan
     */
    changePlan : function(component, event, helper) {
    	var planCoverage = component.find("planselect");
    	var planCoverageId = planCoverage.get('v.value');
    	var coverageId;
		var plans = component.get('v.plans');
		console.log('planCoverageId::'+planCoverageId);
		// find the plan from the selected id
		if(plans && plans.length > 0) {
			plans.forEach(function(entry) {
				if(entry.coverage.MemberCoverageGuid__c == planCoverageId) {
					console.log('coverage::'+JSON.stringify(entry.coverage));
					coverageId = entry.coverage.MemberCoverageGuid__c;
					component.set('v.selectedPlan', entry);
				}
			});
		}

		component.set('v.isLoading', true);
		//$A.util.addClass(component.find("saving-backdrop"), "slds-show");
        //$A.util.removeClass(component.find("saving-backdrop"), "slds-hide");

        // re-query for the member overview information
    	helper.getMemberOverview(component, component.get('v.params.id'), coverageId);
    },
    /**
     * Client side table sort
     */
    sortTable : function(component, event, helper) {
    	//console.log('### sorting table...');
		//get the element clicked
		var tar = event.currentTarget;
		var col = tar.dataset.col; //get column

		//get table Id
		var tableId = tar.dataset.tableid;
		//console.log('table id ' + tableId);
		//get the table 
		var table = $('#'+tableId);
		//console.log('table element ' + JSON.stringify(table));
		

		//is this column not order
		if($A.util.hasClass(tar, 'notSorted')){
			//console.log('not sorted');
			$A.util.removeClass(tar, 'notSorted');
			if(col == 0){
				//default last updated to descend. newest first
				$A.util.addClass(tar, 'sortDescend');
				sortTable(table, col, 'DESC');
			} else {
				$A.util.addClass(tar, 'sortAscend');
				sortTable(table, col, 'ASC');
			}
			$('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');

		} else if($A.util.hasClass(tar, 'sortAscend')) {
			//console.log('asc');
			//column is currently sorted by ascending order, switch it
			$A.util.removeClass(tar, 'sortAscend')
			$A.util.addClass(tar, 'sortDescend');
			sortTable(table, col, 'DESC');
		} else {//target has sortDescend
			//column is currently sorted by descending order, switch it
			//console.log('dsc');
			$A.util.addClass(tar, 'sortAscend');
			$A.util.removeClass(tar, 'sortDescend');
			sortTable(table, col, 'ASC');
		}
		
		//hide the spinner
		//$A.util.toggleClass(spinner, 'slds-hide');


    }
})