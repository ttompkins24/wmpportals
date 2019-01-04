({
	doInit : function(component, event, helper) {
//        console.log('init');
        var spinner = component.find('spinnerId');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
        //$A.util.removeClass(component.find('spinnerId'), 'slds-hide');
        //$A.util.addClass(component.find('spinnerId'), 'slds-is-fixed');
		helper.retrieveBizList(component, event, helper);
		helper.getServiceLocations(component, event, helper);
		helper.getAllProvList(component,event,helper);
		helper.getServiceLocationsAndProviders(component, event, helper);
	 },

	updateLocSearch: function (component, event, helper) {
    	helper.getLocId(component, event, helper);
	},

	updateProvSearch: function (component, event, helper) {
    	helper.getProvId(component, event, helper);
	},

	dentistSearch : function (component,event, helper){
		var spinner = component.find('spinnerId');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
		helper.getServiceLocationsAndProviders(component, event, helper);
		
	},

    servLocationDetail :function (component,event,helper){
    	var spinner = component.find('spinnerId');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
        //redirects to the page while passing in member information
        var selectItem = event.currentTarget;

        var locationId = selectItem.dataset.location;

        //sets page name to route to
        var pageName = "service-office-detail";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                "memberProfileGuid" : locationId

            });
            redirectEvent.fire();
    },

	businessDetail : function(component,event,helper){
		var spinner = component.find('spinnerId');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
		//calls redirect event to go to Business or Service Location account detail based on Account inputs
        var selectItem = event.currentTarget;
        //gets memberProfile Guid on that specific member
        var businessId = selectItem.dataset.bizid;
        //sets page name to route to
        if(businessId != null){

        	var pageName = "business-detail";
        	var redirectEvent = $A.get('e.c:prov_event_Redirect');
            	redirectEvent.setParams({
                	"pageName" : pageName,
                	"memberProfileGuid" : businessId

            	});
            redirectEvent.fire();
        }
	},

	pslDetail : function(component,event,helper){
		var spinner = component.find('spinnerId');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-is-fixed');
		//calls redirect event to go to Dentist Detail screen based on PSL inputs

		//redirects to the new broken appointments page while passing in member information
        var selectItem = event.currentTarget;
        //gets memberProfile Guid on that specific member
        var dentist = selectItem.dataset.dentistid;
        //sets page name to route to
        var pageName = "provider-detail";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                "memberProfileGuid" : dentist

            });
            redirectEvent.fire();
	},

	firstDentPage : function(component, event, helper){
        component.set('v.pageNumDentist', 1);
    },

    previousDentPage: function(component, event, helper) {
        var pageNum = component.get('v.pageNumDentist');
        component.set('v.pageNumDentist', (pageNum-1));
 
   },
 
   nextDentPage: function(component, event, helper) {
        var pageNum = component.get('v.pageNumDentist');
	   component.set('v.pageNumDentist', (pageNum+1));
      
   },

   showAllDentists:function(component, event, helper){
        //show all records(up to 10,000)
	   component.set("v.pageSizeProv", '10000');
	   component.set("v.pageNumDentist", 1);
        component.set("v.total_pages_dentist", 1);
    },

    firstLocPage : function(component, event, helper){
        //get the page variables applicable
        component.set('v.pageNumLocation', 1);
    },

    previousLocPage: function(component, event, helper) {
        var pageNum = component.get('v.pageNumLocation');
        component.set('v.pageNumLocation', (pageNum-1));
 
   },
 
   nextLocPage: function(component, event, helper) {
	   var pageNum = component.get('v.pageNumLocation');
	   component.set('v.pageNumLocation', (pageNum+1));
   },

   showAllLocations :function(component, event, helper){
        //show all records(up to 10,000)
	   component.set("v.pageSizeLoc", '10000');
	   component.set('v.pageNumLocation', 1);
        component.set("v.total_pages_location", 1);
    },

    updateColumnSorting: function(component, event, helper){
        //changes sorting based on selected column
        var isAsc = component.get("v.isAsc");

        var tar = event.currentTarget;
        var col = tar.dataset.col;
        var fName = tar.dataset.fieldname;
        var dir;
        var table = tar.dataset.tableid;
        var results;
        var pageNum = 1;
        if(table == 'dentist'){
            results = component.get('v.dentistList');
        }
        if(table == 'location'){
        	results = component.get('v.locListPage');
        }

        //changes style if the target is clicked
        if($A.util.hasClass(tar, 'notSorted')){
            $A.util.addClass(tar, 'sortAscend');
            $A.util.addClass(tar, 'sorted');
            $A.util.removeClass(tar, 'notSorted');
            $('#'+table).find('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted').removeClass('sorted');
            dir = 'ASC';
        } 

        else if($A.util.hasClass(tar, 'sortAscend')) {
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            $A.util.addClass(tar, 'sorted');
            $('#'+table).find('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted').removeClass('sorted');
            dir = 'DESC';
        }
        else {
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
            $A.util.addClass(tar, 'sorted');
            $('#'+table).find('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted').removeClass('sorted');
            dir = 'ASC';
        }
        
        results.sort(dynamicSort(fName, dir));

        if(table == 'dentist'){
        	results = component.set('v.dentistList', results);
            results = component.set('v.pageNumDentist', 1);
            component.set('v.directionProv', dir);
            component.set('v.sortFieldProv', fName);
        }

        if(table == 'location'){
        	results = component.set('v.locListPage', results);
        	results = component.set('v.pageNumLocation', 1);
        	component.set('v.directionLoc', dir);
        	component.set('v.sortFieldLoc', fName);
        }
    },

    clearSearchFields : function(component, event, helper) {
        var pageName = "practice-management";

        var redirectEvent = $A.get('e.c:prov_event_Redirect');
        redirectEvent.setParams({
            'pageName' : pageName
        });
        redirectEvent.fire();
    },

    printDocument : function(component, event, helper){
        //console.log('printing document');


        //console.log(component.get('v.locAcctRecId'));
        //console.log(component.get('v.provAcctRecId'));

    	var busAcctRecId = component.get("v.currentBusinessId");
        var locAcctRecId = component.get("v.locAcctRecId");
        var provAcctRecId = component.get("v.provAcctRecId");
        var locDir = component.get('v.directionLoc');
        var locSort = component.get('v.sortFieldLoc');
        var provDir = component.get('v.directionProv');
        var provSort = component.get('v.sortFieldProv');
        var URL = '/apex/prov_vf_Practice_Mgmt_Print?busId='+busAcctRecId;

        if(locAcctRecId != null && locAcctRecId != '' && locAcctRecId != 'Any') {
            URL += '&locId='+locAcctRecId;
        }

        if(provAcctRecId != null && provAcctRecId != '' && provAcctRecId != 'Any') {
            URL += '&provId='+provAcctRecId;
        }
        if(locSort != null && locSort != '') {
            URL += '&locSort='+locSort;
        }
        if(locDir != null && locDir != '') {
            URL += '&locDir='+locDir;
        }
        if(provSort != null && provSort != '') {
            URL += '&provSort='+provSort;
        }
        if(provDir != null && provDir != '') {
            URL += '&provDir='+provDir;
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": $A.get('$Label.c.SiteVFURL')+URL
        });
        urlEvent.fire(); 

    }

})