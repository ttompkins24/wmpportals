({
	doInit : function(component, event, helper) {
        //turn on spinner
		var spinner = component.find('spinnerId');
		$A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
        //get list of service locations for drop down
		helper.getServiceLocations(component, event, helper);
	 },


	updateLocSearch: function (component, event, helper) {
        //update value of location id based on selected location in dropdown
    	helper.getLocId(component, event, helper);
	},

	updateProvSearch: function (component, event, helper) {
        //update value of provider id based on selected provider in dropdown
    	helper.getProvId(component, event, helper);
	},

	memberIntSearch :function(component,event,helper){
		var spinner = component.find('spinnerId');
		$A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
	    //check for errors before searching for members associated with filter criteria
        helper.checkForErrors(component,event,helper);
		
	},

	updateInterventions :function(component,event,helper){
		var spinner = component.find('spinnerId');
		$A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
        helper.updateSelectedInterventions(component,event,helper);
	},


    handleSelectSingleRow :function(component,event,helper){
        helper.verifySelectedInterventions(component,event,helper);
    },

	handleSelectAllInts :function (component,event,helper){

		var checkValue = component.find('selectAll').get('v.value');        
        var checkInt = component.find('checkInt'); 
        //loop through each checkbox and check them off if they are not currently checked
        if(checkValue == true){
            if(!Array.isArray(checkInt)) {
                component.find('checkInt').set('v.value',true);
            } else {
                for(var i=0; i<checkInt.length; i++){
                    checkInt[i].set('v.value',true);
                }
            } 
            //set value of at least one selcted to activate the button to allow users to update intervention actions
            component.set('v.atLeastOneSelected', true);
        }
        //otherwise uncheck the boxes
        else{ 
            if(!Array.isArray(checkInt)) {
                component.find('checkInt').set('v.value',false);
            } else {
                for(var i=0; i<checkInt.length; i++){
                    checkInt[i].set('v.value',false);
                }
            }
            //set value of at least one selcted to deactivate the button to allow users to update intervention actions
            component.set('v.atLeastOneSelected', false);             
        }


    },

     updateColumnSorting: function(component, event, helper){
    	 var spinner = component.find('spinnerId');
		$A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
        //changes sorting based on selected column
        var isAsc = component.get("v.isAsc");

        var pageNum = component.get("v.intPage");
            pageNum = 1;

        var tar = event.currentTarget;
        var col = tar.dataset.col;
        var fName = tar.dataset.fieldname;
        var dir = component.get("v.direction");
        var table = tar.dataset.tableid;

        //changes style if the target is clicked
        if($A.util.hasClass(tar, 'notSorted')){
            $A.util.addClass(tar, 'sortAscend');
            $A.util.addClass(tar, 'sorted');
            $A.util.removeClass(tar, 'notSorted');
            $('#'+table).find('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted').removeClass('sorted');
            dir = 'ASC';
            component.set("v.isAsc", true);
        } 

        else if($A.util.hasClass(tar, 'sortAscend')) {
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            $A.util.addClass(tar, 'sorted');
            $('#'+table).find('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted').removeClass('sorted');
            dir = 'DESC';
            component.set("v.isAsc", false);
        }
        else {
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
            $A.util.addClass(tar, 'sorted');
            $('#'+table).find('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted').removeClass('sorted');
            dir = 'ASC';
            component.set("v.isAsc", true);
        }
        component.set('v.direction', dir);
        component.set('v.sortfield', fName);
        var active = component.get('v.searchActive');
        if(active){
            helper.getMemberInterventions(component,event,helper, pageNum, fName, dir);
            helper.loadPageVariables(component);
        }

    },

    clearSearchFields : function(component, event, helper) {
        var pageName = "member-intervention";

        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({
            'pageName' : pageName
        });
        redirectEvent.fire();
    },

    printList:function(component, event, helper){
        //console.log("print...");
        window.print();
    },

    firstIntPage : function(component, event, helper){
    	 var spinner = component.find('spinnerId');
		$A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
        //get the page variables applicable
        var direction = component.get('v.direction');
        var fieldName = component.get('v.sortfield');
        
        helper.getMemberInterventions(component, event, helper, 1, fieldName, direction);
        component.set('v.intPage', 1);
        helper.loadPageVariables(component);
    },

    previousIntPage: function(component, event, helper) {
    	 var spinner = component.find('spinnerId');
		$A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
        var direction = component.get('v.direction');
        var fieldName = component.get('v.sortfield');
        var pageNum = component.get('v.intPage');

        helper.getMemberInterventions(component, event, helper, pageNum-1, fieldName, direction);
        component.set('v.intPage', pageNum-1);
        helper.loadPageVariables(component);
 
   },
 
   nextIntPage: function(component, event, helper) {
   	 var spinner = component.find('spinnerId');
		$A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
        var direction = component.get('v.direction');
        var fieldName = component.get('v.sortfield');
        
        var pageNum = component.get('v.intPage');
        helper.getMemberInterventions(component, event,helper, pageNum+1, fieldName, direction);
        component.set('v.intPage', pageNum+1);
        helper.loadPageVariables(component);
      
   },

   showAllInts:function(component, event, helper){
   	 var spinner = component.find('spinnerId');
		$A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
        //show all records(up to 10,000)
        component.set("v.maxResults", '10000');
        var direction = component.get('v.direction')
        var fieldName = component.get('v.sortfield')
       
        helper.getMemberInterventions(component,event,helper, 1, fieldName, direction);
        helper.loadPageVariables(component);
    },
    

    fixDate : function(component, event, helper) {
        helper.fixDate(component, event, helper);
    }

})