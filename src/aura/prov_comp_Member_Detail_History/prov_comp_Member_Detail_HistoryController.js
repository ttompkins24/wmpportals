({
    /**
     * Init the history records
     */
	init : function(component, event, helper) {
        helper.getHistory(component, component.get('v.params.id'));
    },

    printList:function(component, event, helper){
        //console.log('printList start');
		var memberGuid = component.get('v.params.id');
        var URL = '/apex/prov_vf_Member_Service_History_Print?';
        URL += 'id='+memberGuid;

		var sortField = component.get('v.fieldNameSorted');
		var sortDirection = component.get('v.sortDirection');

		if(sortField != null && sortField != '') {
			URL += '&sortField='+sortField;
		}
		if(sortDirection != null && sortDirection != '') {
			URL += '&sortDir='+sortDirection;
		}
        //console.log('URL: '+URL);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
        	"url": $A.get('$Label.c.SiteVFURL')+URL
        });
        urlEvent.fire(); 
        //console.log('printList end');
    },
    
    /**
     * Page Next
     */
    nextPageClick : function(component, event, helper) {
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
	    //$A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.addClass(component.find("saving-backdrop"), "slds-is-fixed");
    	var pageNum = component.get('v.pageNum');
    	pageNum++;
    	component.set('v.pageNum', pageNum);
    	helper.getHistory(component, component.get('v.params.id'));
    },
    /**
     * Page Preview
     */
    previousPageClick : function(component, event, helper) {
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
	    $A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.addClass(component.find("saving-backdrop"), "slds-is-fixed");
    	var pageNum = component.get('v.pageNum');
    	pageNum--;
    	component.set('v.pageNum', pageNum);
    	helper.getHistory(component, component.get('v.params.id'));
    }, 
    /**
     * go back to the first page
     */
    firstPageClick : function(component, event, helper) {
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
	    $A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.addClass(component.find("saving-backdrop"), "slds-is-fixed");
    	component.set('v.pageNum', 1);
    	helper.getHistory(component, component.get('v.params.id'));
    }, 
    /**
     * Handle sort by column (field name) and sort direction
     */
    sortTable : function(component, event, helper) {    
        $A.util.removeClass(component.find("saving-backdrop"), "slds-hide");
	        $A.util.addClass(component.find("saving-backdrop"), "slds-show");
        $A.util.addClass(component.find("saving-backdrop"), "slds-is-fixed");
        //get the element clicked
        var tar = event.currentTarget;
        var col = tar.dataset.col; //get column
        var fieldName = tar.dataset.fieldname;
        var direction = 'ASC';
        var pageNum = 1;
    
        //get the table 
        var table = $('#historyTable');
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
    

        helper.getHistory(component, component.get('v.params.id'));
    }
})