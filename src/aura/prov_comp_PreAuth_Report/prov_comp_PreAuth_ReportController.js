({
	doInit : function(component, event, helper) {
		helper.helperPopulateReport(component,event,helper);
		helper.helperPopulateDateFilter(component,event,helper);

         var labelName = component.get('v.portalConfig.PreAuthorization_Label__c');
        labelValue = $A.getReference('$Label.c.' + labelName);
        
        //console.log('pre auth label: ' + labelValue);

        component.set('v.preAuthLabel', labelValue);
	},

	filterByDate :function(component,event,helper){
        //console.log('filtering by date');
        var reportList = component.get("v.claimDetails");
        var date = component.get('v.filterDate');
        helper.helperFilterByDate(component,event,helper,date);
	},

	updateDate : function(component,event,helper){
        //console.log('updating date filter');
        var selectedDate = component.find("dateFilter").get("v.value");
        component.set("v.filterDate", selectedDate);
        //console.log(component.get("v.filterDate"));
    },

    handleOpenPreAuth : function (component,event,helper) {
        //redirects to the page while passing in member information
        var selectItem = event.currentTarget;

        var Id = selectItem.dataset.preauth;

        //sets page name to route to
        var pageName = "pre-auth-detail";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                "memberProfileGuid" : Id

            });
            redirectEvent.fire();
	},

    searchRedirect :function(component,event,helper){
        var pageName = "pre-auth-search";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName

            });
            redirectEvent.fire();
    },


	handleServiceLineExpand : function (component,event,helper){
        //console.log('here');
		helper.helperExpandServiceLine(component,event,helper);
	},
	
	printList:function(component, event, helper){
		//console.log("print...");
		window.print();
	},

})