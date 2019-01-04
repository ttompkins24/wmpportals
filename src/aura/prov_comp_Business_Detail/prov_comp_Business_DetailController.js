({
	doInit : function(component, event, helper) {

        var params = component.get('v.params');
        var businessId = params.id;
            component.set('v.business_updates', {});
		helper.retrieveBizList(component, event, helper);
        helper.getProvTypeValues(component,event,helper);
        helper.getExistingCase(component);
	},

	printList:function(component, event, helper){
		//console.log("print...");
		window.print();
	},

	updateColumnSorting: function(component, event, helper){
        //changes sorting based on selected column
        var isAsc = component.get("v.isAsc");
        var tar = event.currentTarget;
        var col = tar.dataset.col;
        var fName = tar.dataset.fieldname;
        var dir = component.get("v.direction");
        var pageNum = component.get("v.page");
        pageNum = 1;

        //changes style if the target is clicked
        if($A.util.hasClass(tar, 'notSorted')){
            $A.util.addClass(tar, 'sortAscend');
            $A.util.addClass(tar, 'sorted');
            $A.util.removeClass(tar, 'notSorted');
            $('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted').removeClass('sorted');
            dir = 'ASC';
            component.set("v.isAsc", true);
        } 

        else if($A.util.hasClass(tar, 'sortAscend')) {
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            $A.util.addClass(tar, 'sorted');
            $('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted').removeClass('sorted');
            dir = 'DESC';
            component.set("v.isAsc", false);
        }
        else {
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
            $A.util.addClass(tar, 'sorted');
            $('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted').removeClass('sorted');
            dir = 'ASC';
            component.set("v.isAsc", true);
        }

        component.set('v.direction', dir);
        component.set('v.sortField', fName);
        //only fire if search is active. this attribute is set to true after the user clicks search.
        //any other time this will prevent the user from clicking the sort buttons and running a search
        helper.getServiceLocations(component,event,helper, pageNum, fName, dir);
        helper.loadPageVariables(component);
        
    },

    servLocationDetail :function (component,event,helper){
        //redirects to the new broken appointments page while passing in member information
        var selectItem = event.currentTarget;
        //gets memberProfile Guid on that specific member
        var locationId = selectItem.dataset.location;

        //console.log('location Id' + locationId);
        //sets page name to route to
        var pageName = "service-office-detail";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                "memberProfileGuid" : locationId
            });
            redirectEvent.fire();
    },

    firstLocPage : function(component, event, helper){
        //get the page variables applicable
        var direction = component.get('v.direction');
        var fieldName = component.get('v.sortField');
        
        helper.getServiceLocations(component, event, helper, 1, fieldName, direction);
        component.set('v.page', 1);
    },

    previousLocPage: function(component, event, helper) {
        var direction = component.get('v.direction');
        var fieldName = component.get('v.sortField');
        var pageNum = component.get('v.page');

        helper.getServiceLocations(component, event, helper, pageNum-1, fieldName, direction);
        component.set('v.page', pageNum-1);
 
   },
 
   nextLocPage: function(component, event, helper) {
        var direction = component.get('v.direction');
        var fieldName = component.get('v.sortField');
        
        var pageNum = component.get('v.page');
        helper.getServiceLocations(component, event,helper, pageNum+1, fieldName, direction);
        component.set('v.page', pageNum+1);
      
   },

   showAllLocations :function(component, event, helper){
        //show all records(up to 10,000)
        component.set("v.maxResults", '10000');
        component.set("v.pages", '1');
        var direction = component.get('v.direction');
        var fieldName = component.get('v.sortField');
       
        helper.getServiceLocations(component,event,helper, 1, fieldName, direction);
    },

    editBusiness : function(component,event,helper){
        component.set('v.editBusiness', true);
    },

    saveBusinessUpdate : function(component,event,helper){
        var businessChanges = component.get("v.business_updates");
        
        var updateJSON = {
            business_updates : (!_.isNull(businessChanges) ? businessChanges : null)
        };
        var changes = JSON.stringify(updateJSON, undefined, 4);
        //console.log(changes);
        helper.saveUpdatedBusinessRecord(component,event,helper, changes);
    },

    editBusinessCancel :function (component,event,helper){
        component.set('v.editBusiness', false);
        window.scroll(0,0);
    },

    fieldChange :function (component,event,helper){
        var newBizMap = component.get("v.business_updates");

        var sourceField = event.getSource();
        var newValue = sourceField.get('v.value');
        var label = sourceField.get('v.label');
        
        newBizMap[label] = newValue;
        for (var key in newBizMap) {
            //console.log("key " + key + " has value " + newBizMap[key]);
        }
        component.set("v.business_updates", newBizMap);
    },
    helpRequestRedirect :function(component,event,helper){

        var pageName = "help-request";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                "newTab" : true
            });
        redirectEvent.fire();
    }
})