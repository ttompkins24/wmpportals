({
	doInit : function(component, event, helper) {
        //console.log('doInit');
		//get params passed in from a redirect event    
    	var params = component.get('v.params');
    	var servLocId = params.id;
        component.set('v.servOfficeHours',{});

    	//console.log('servLocId: '+servLocId);
        helper.getCurrentServiceLocation(component, event, helper, servLocId);
        helper.getExistingCase(component, servLocId);
    },

    refreshLocation: function(component, event, helper) {
        //console.log('refreshLocation');
        component.set('v.locAcctRec', null);
        var params = component.get('v.params');
    	var servLocId = params.id;
		helper.getCurrentServiceLocation(component, event, helper, servLocId);
        helper.getExistingCase(component, servLocId);
    },

    helpRequestRedirect :function(component,event,helper){
        var pageName = "help-request";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                "newTab" : true
            });
            redirectEvent.fire();
    },

	printList:function(component, event, helper){
		//console.log("printing...");
		window.print();
	},
    
    edit : function(component, event, helper) {
        var isEdit = component.get('v.editServiceOffice');
        //console.log('isEdit before: '+isEdit);
        component.set('v.editServiceOffice', !isEdit);
    },

    pslDetail : function(component,event,helper){
        //calls redirect event to go to Dentist Detail screen based on PSL inputs

        //redirects to the new broken appointments page while passing in member information
        var selectItem = event.currentTarget;
        //gets memberProfile Guid on that specific member
        var dentist = selectItem.dataset.dentistid;
        //console.log(dentist);
        //sets page name to route to
        var pageName = "provider-detail";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                "memberProfileGuid" : dentist

            });
            redirectEvent.fire();
    },

	//column sort methods
    //sorts the column selected
    updateColumnSorting: function(component, event, helper){
        //get the element clicked
        var tar = event.currentTarget;
        var col = tar.dataset.col; //get column
        var fieldName = tar.dataset.fieldname;
        //console.log('target and column found');

        // sort direction for dynamicSort
        // if null, dynamicSort will sort ascending
        var sortDirection = '';

        // resort the table
        var dentistList = component.get('v.dentistList');
       
        if($A.util.hasClass(tar, 'notSorted')){
            //console.log('not sorted');
            $A.util.removeClass(tar, 'notSorted');
            if(col == 0){
                //default last updated to descend. newest first
                $A.util.addClass(tar, 'sortDescend');
                sortDirection = 'desc';
            } else {
                $A.util.addClass(tar, 'sortAscend');
            }
            $('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');

        } else if($A.util.hasClass(tar, 'sortAscend')) {
            //console.log('asc');
            //column is currently sorted by ascending order, switch it
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            sortDirection = 'desc';
            //console.log('end of sort asc');
        } else {//target has sortDescend
            //column is currently sorted by descending order, switch it
            //console.log('dsc');
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
        }   

        dentistList.sort(dynamicSort(fieldName,sortDirection));
        component.set('v.dentistList', dentistList);
        
        //console.log('end of sort method');
    }
    //end column sort methods
})