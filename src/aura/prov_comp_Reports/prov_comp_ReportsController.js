({
	init : function(component, event, helper) {
        helper.getNotifications(component, component.get('v.pageNum'), component.get('v.fieldNameSorted'), component.get('v.sortDirection'));
	},

    downloadAttachment : function(component, event, helper) {
        var notificationId = event.currentTarget.dataset.value;
        var fileName = 'file';
        var messages = component.get('v.messages');

        for(var i = 0; i < messages.length; i++) {
            if(notificationId == messages[i].Id) {
                if(messages[i].Attachments && messages[i].Attachments.length > 0) {
                    fileName = messages[i].Attachments[0].Name;
                    break;
                }
            }
        }
        helper.fetchAttachment(component, notificationId, fileName);
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
        
        helper.getNotifications(component, pageNum, fieldName, direction);
    },
})