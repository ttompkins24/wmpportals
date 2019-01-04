({
	doInit : function(component, event, helper) {
		//console.log('### doing init...');
        helper.getMessages(component, component.get('v.pageNum'), component.get('v.fieldNameSorted'), component.get('v.sortDirection'));
	},

    clickNext: function(component, event, helper) {
        var pageNum = component.get('v.pageNum');
        pageNum = pageNum + 1;
        component.set('v.pageNum', pageNum);
        helper.getMessages(component, pageNum, component.get('v.fieldNameSorted'), component.get('v.sortDirection'));
    },

    clickPrevious : function(component, event, helper) {
        var pageNum = component.get('v.pageNum');
        pageNum = pageNum - 1;
        component.set('v.pageNum', pageNum);
        helper.getMessages(component, pageNum, component.get('v.fieldNameSorted'), component.get('v.sortDirection'));
    },

    clickFirst : function(component, event, helper) {
        component.set('v.pageNum', 1);
        helper.getMessages(component, 1, component.get('v.fieldNameSorted'), component.get('v.sortDirection'));
    },

    redirectToDetailPage : function(component, event, helper){
        var pageName = event.currentTarget.dataset.targetid;
        
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({ 'pageName' : pageName });
        redirectEvent.fire();
    },

    redirectToCase : function(component, event, helper){
        var targetid = event.currentTarget.dataset.targetid;        
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({ 'pageName' : "help-request-detail?id=" + targetid });
        redirectEvent.fire();
    },

    redirectToReports : function(component, event, helper){
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({ 'pageName' : "reports" });
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
        
        helper.getMessages(component, pageNum, fieldName, direction);
    },
})