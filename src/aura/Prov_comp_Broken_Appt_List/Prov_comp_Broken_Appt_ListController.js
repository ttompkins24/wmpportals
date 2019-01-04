({
	doInit : function(component, event, helper) {
		helper.retrieveBizList(component, event, helper);
	 },

	updateBizSearch: function (component, event, helper) {
        //get business ID
    	helper.getBizId(component, event, helper);
	},

	updateLocSearch: function (component, event, helper) {
        //get selected service location ID
    	helper.getLocId(component, event, helper);
	},

	updateProvSearch: function (component, event, helper) {
        //get selected provider
    	helper.getProvId(component, event, helper);
	},
	printList:function(component, event, helper){
		//console.log("print...");
		window.print();
	},

    showAll:function(component, event, helper){
        //show all records(up to 10,000)
        component.set("v.maxResults", '10000');
        var direction = component.get('v.direction');
        var fieldName = component.get('v.sortField');
        //call broken appointments helper while setting page number to 1
        helper.getBrokenAppts(component,event,helper, 1, fieldName, direction);
        helper.loadPageVariables(component);
    },

	downloadList: function(component,event,helper){
		var data = component.get('v.apptList');
		var csv = helper.downloadCsv(component, data);
//		//console.log(csv);
        if (csv == null){return;} 
        
        if (navigator.msSaveBlob){ // if IE 10+ 
        	navigator.msSaveBlob(new Blob([csv], { type: 'text/csv;charset=utf-8;' }), "BrokenAppointments.csv"); 
		} else {
	        // find a hidden temp. <a> html tag [link tag] for download the CSV file--####     
		    var hiddenElement = document.getElementById('hiddenDownloadLink');
	        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
	        hiddenElement.target = '_self'; // 
	        hiddenElement.download = 'BrokenAppointments.csv';  
	    	hiddenElement.click(); // using click() js function to download csv file
    	}
	},

    firstPage : function(component, event, helper){
        //get the page variables applicable
        var direction = component.get('v.direction');
        var fieldName = component.get('v.sortField');
        
        helper.getBrokenAppts(component, event, helper, 1, fieldName, direction);
        component.set('v.page', 1);
    },

    previousPage: function(component, event, helper) {
        var direction = component.get('v.direction');
        var fieldName = component.get('v.sortField');
        var pageNum = component.get('v.page');

        helper.getBrokenAppts(component, event, helper, pageNum-1, fieldName, direction);
        component.set('v.page', pageNum-1);
 
   },
 
   nextPage: function(component, event, helper) {
        var direction = component.get('v.direction');
        var fieldName = component.get('v.sortField');
        
        var pageNum = component.get('v.page');
        helper.getBrokenAppts(component, event,helper, pageNum+1, fieldName, direction);
        component.set('v.page', pageNum+1);
      
   },

	brokenApptSearch : function(component,event,helper){
        component.set("v.maxResults", null);
        component.set("v.locationError", false);
        helper.checkForErrors(component,event,helper);

        var locationError = component.get("v.locationError");
        if(!locationError){
            //console.log("no errors, searching");
            helper.getBrokenAppts(component,event,helper, 1);
            helper.loadPageVariables(component);
        }
	},

    updateColumnSorting: function(component, event, helper){
        //changes sorting based on selected column

        var table = $('.brokenApptTable');
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
        //checks if the search is active.
        var search = component.get("v.searchActive");

        component.set('v.direction', dir);
        component.set('v.sortField', fName);
        //only fire if search is active. this attribute is set to true after the user clicks search.
        //any other time this will prevent the user from clicking the sort buttons and running a search
        if(search === true){
        helper.getBrokenAppts(component,event,helper, pageNum, fName, dir);
        helper.loadPageVariables(component);
        }
    },

    startBrokenAppt : function (component, event, helper){
        //redirects to the new broken appointments page while passing in member information
        var curTarget = event.currentTarget;
		var caseId = curTarget.dataset.value;
		var servLoc = component.get('v.locAcctRecId');
		////console.log('memGuid::'+memGuid);
		var provAcctId = component.find("provAccts").get("v.value");
        if(provAcctId == undefined || provAcctId == 'Any')
        	provAcctId = '';
		var results = component.get('v.apptList');
		for(var i in results){
			if(results[i].Id == caseId){
				memGuid = results[i].Member_Profile_Guid__c;
	            var birthDate = new Date(results[i].Member_DOB__c);

				 var birthMM = birthDate.getUTCMonth()+1; 
	            if (birthMM <= 9) {
	                birthMM = '0' + birthMM;
	            }
	            var birthDD = birthDate.getUTCDate(); 
	            if (birthDD <= 9) {
	                birthDD = '0' + birthDD;
	            }
				var memCov = {'FirstName__c' : results[i].Provider_Portal_Member_First_Name__c, 
							'LastName__c' : results[i].Provider_Portal_Member_Last_Name__c, 
							'Birthdate__c' : birthDate.getUTCFullYear() + '-' + birthMM + '-' + birthDD ,
							'SubscriberID__c' : results[i].Member_ID__c, 
							'providerId' : provAcctId,
							'serviceLocationId' : servLoc
							//'planGuid' : results[i].PlanGuid,
							//'MemberProfileGuid' : results[i].Member_Profile_Guid__c
							 };
				////console.log('memCov::'+memCov);
				localStorage[memGuid] = JSON.stringify(memCov);
			}
		} 
        //sets page name to route to
        var pageName = "broken-appointment";
        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                "memberProfileGuid" : memGuid,
                "serviceLocationId" : servLoc,
                "providerId" : provAcctId,
                newTab : true
            });
            redirectEvent.fire();
    },
    
    //referral button  clicked	
	startReferral : function(component, event, helper) {
		var curTarget = event.currentTarget;
		var caseId = curTarget.dataset.value;
		var servLoc = component.get('v.locAcctRecId');
		////console.log('memGuid::'+memGuid);
		var provAcctId = component.find("provAccts").get("v.value");
        if(provAcctId == undefined || provAcctId == 'Any')
        	provAcctId = '';
		var results = component.get('v.apptList');
		for(var i in results){
			if(results[i].Id == caseId){
				memGuid = results[i].Member_Profile_Guid__c;
	            var birthDate = new Date(results[i].Member_DOB__c);

				 var birthMM = birthDate.getUTCMonth()+1; 
	            if (birthMM <= 9) {
	                birthMM = '0' + birthMM;
	            }
	            var birthDD = birthDate.getUTCDate(); 
	            if (birthDD <= 9) {
	                birthDD = '0' + birthDD;
	            }
	             var servDate = new Date();
	             var mm = servDate.getUTCMonth()+1; 
	            if (mm <= 9) {
	                mm = '0' + mm;
	            }
	            
	            var servDD = servDate.getUTCDate(); 
	            if (servDD <= 9) {
	                servDD = '0' + servDD;
	            }
				var memCov = {'FirstName__c' : results[i].Provider_Portal_Member_First_Name__c, 
							'LastName__c' : results[i].Provider_Portal_Member_Last_Name__c, 
							'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthDate.getUTCFullYear(), 
							'SubscriberID__c' : results[i].Member_ID__c, 
							'providerId' : provAcctId,
							'serviceDate' : mm + '/' + servDD + '/'+servDate.getUTCFullYear(),
							'serviceLocationId' : servLoc
							//'planGuid' : results[i].PlanGuid,
							//'MemberProfileGuid' : results[i].Member_Profile_Guid__c
							 };
				////console.log('memCov::'+memCov);
				localStorage[memGuid] = JSON.stringify(memCov);
			}
		} 
		var pageName = 'referral-entry'
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : pageName+'?memId='+memGuid,
			newTab : true
		});
		redirectEvent.fire();
	},
	
	//referral button  clicked	
	startClaim : function(component, event, helper) {
		var curTarget = event.currentTarget;
		var caseId = curTarget.dataset.value;
		var servLoc = component.get('v.locAcctRecId');
		////console.log('memGuid::'+memGuid);
		var provAcctId = component.find("provAccts").get("v.value");
        if(provAcctId == undefined || provAcctId == 'Any')
        	provAcctId = '';
		var results = component.get('v.apptList');
		for(var i in results){
			if(results[i].Id == caseId){
				memGuid = results[i].Member_Profile_Guid__c;
	            var birthDate = new Date(results[i].Member_DOB__c);

				 var birthMM = birthDate.getUTCMonth()+1; 
	            if (birthMM <= 9) {
	                birthMM = '0' + birthMM;
	            }
	            var birthDD = birthDate.getUTCDate(); 
	            if (birthDD <= 9) {
	                birthDD = '0' + birthDD;
	            }
	             var servDate = new Date();
	             var mm = servDate.getUTCMonth()+1; 
	            if (mm <= 9) {
	                mm = '0' + mm;
	            }
	            
	            var servDD = servDate.getUTCDate(); 
	            if (servDD <= 9) {
	                servDD = '0' + servDD;
	            }
				var memCov = {'FirstName__c' : results[i].Provider_Portal_Member_First_Name__c, 
							'LastName__c' : results[i].Provider_Portal_Member_Last_Name__c, 
							'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthDate.getUTCFullYear(), 
							'SubscriberID__c' : results[i].Member_ID__c, 
							'providerId' : provAcctId,
							'serviceDate' : mm + '/' + servDD + '/'+servDate.getUTCFullYear(),
							'serviceLocationId' : servLoc
							//'planGuid' : results[i].PlanGuid,
							//'MemberProfileGuid' : results[i].Member_Profile_Guid__c
							 };
				//console.log('memCov::'+JSON.stringify(memCov));
				localStorage[memGuid] = JSON.stringify(memCov);
			}
		} 
		var pageName = 'claim-entry'
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : pageName+'?memId='+memGuid,
			newTab : true
		});
		redirectEvent.fire();
	},
	
	//referral button  clicked	
	startPreAuth : function(component, event, helper) {
		var curTarget = event.currentTarget;
		var caseId = curTarget.dataset.value;
		var servLoc = component.get('v.locAcctRecId');
		var memGuid;
		////console.log('memGuid::'+memGuid);
		var provAcctId = component.find("provAccts").get("v.value");
        if(provAcctId == undefined || provAcctId == 'Any')
        	provAcctId = '';
		var results = component.get('v.apptList');
		for(var i in results){
			if(results[i].Id == caseId){
				memGuid = results[i].Member_Profile_Guid__c;
	            var birthDate = new Date(results[i].Member_DOB__c);

				 var birthMM = birthDate.getUTCMonth()+1; 
	            if (birthMM <= 9) {
	                birthMM = '0' + birthMM;
	            }
	            var birthDD = birthDate.getUTCDate(); 
	            if (birthDD <= 9) {
	                birthDD = '0' + birthDD;
	            }
	            
	            var servDate = new Date();

				 var mm = servDate.getUTCMonth()+1; 
	            if (mm <= 9) {
	                mm = '0' + mm;
	            }
	            
	            var servDD = servDate.getUTCDate(); 
	            if (servDD <= 9) {
	                servDD = '0' + servDD;
	            }
				var memCov = {'FirstName__c' : results[i].Provider_Portal_Member_First_Name__c, 
							'LastName__c' : results[i].Provider_Portal_Member_Last_Name__c, 
							'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthDate.getUTCFullYear(), 
							'SubscriberID__c' : results[i].Member_ID__c, 
							'providerId' : provAcctId,
							'serviceDate' : mm + '/' + servDD + '/'+servDate.getUTCFullYear(),
							'serviceLocationId' : servLoc
							//'planGuid' : results[i].PlanGuid,
							//'MemberProfileGuid' : results[i].Member_Profile_Guid__c
							 };
				////console.log('memCov::'+memCov);
				localStorage[memGuid] = JSON.stringify(memCov);
			}
		} 
		var pageName = 'pre-auth-entry'
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : pageName+'?memId='+memGuid,
			newTab : true
		});
		redirectEvent.fire();
	},
})