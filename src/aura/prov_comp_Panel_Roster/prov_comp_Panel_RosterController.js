({

	doInit : function(component, event, helper) {
		var spinner = component.find('spinnerId');
        $A.util.removeClass(spinner, 'slds-hide');

    	var labelName = component.get("v.portalConfig.PreAuthorization_Label__c");
 		labelValue = $A.getReference("$Label.c." + labelName);
 		
 		//console.log('pre auth label: ' + labelValue);

 		component.set("v.preAuthLabel", labelValue);
		helper.getServiceLocations(component, event, helper);
		helper.getProviders(component,event,helper);
		var listener = function(event) {
    		var origin = $A.get('$Label.c.Member_Eligibility_VF_URL');

    		if(event.origin !== origin) {
    			//not the expected origin. reject results
    			console.log('origins did not match');
    			return;
    		}

    		//Handle the message
    		var results = event.data;
    		
    		if(results == 'pageLoaded'){
    			// console.log('vf page loaded...');
            	component.set('v.checkButtonDisabled', false);
            	return;
            }

//    		console.log('results ' + results);
//    		console.log('results ' + JSON.stringify(results));
//    		console.log('results ' + typeof results);
//			console.log('time out in search page' + results.hasOwnProperty('timeout'));

			if(results.hasOwnProperty('timeout')){
				// console.log('timeout');
				component.set("v.isError",true);
				component.set("v.str_errorMsg",$A.get("$Label.c.Server_No_Response_Error"));
				$A.util.addClass(component.find("spinnerId"), "slds-hide");

            } else if(results.indexOf('download') != -1){
                var totalResults = JSON.parse(results);
                var totalResultList = totalResults.PanelRosterRecords;
               var csv = helper.downloadCsv(component, totalResultList);
                if (csv == null){return;}
                //var todayDate = new Date( 
               if (navigator.msSaveBlob){ // if IE 10+ 
                    navigator.msSaveBlob(new Blob([csv], { type: 'text/csv;charset=utf-8;' }), "PanelRoster.csv"); 
                } else {
                    // create a temp. <a> html tag [link tag] for download the CSV file--####     
                    var hiddenElement = document.createElement('a');
                    hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
                    hiddenElement.target = '_self'; // 
                    hiddenElement.download = 'PanelRoster.csv';  
                    hiddenElement.click(); // using click() js function to download csv file
                } 
                $A.util.addClass(component.find("spinnerId"), "slds-hide");
				$A.util.removeClass(component.find("spinnerId"), "slds-is-fixed");
            } else {
				//success - update list and push results
				//console.log('success');
				//console.log('result String..'+results);
				var totalResults = JSON.parse(results);
				//console.log('totalResults..'+totalResults);
				
				var Total = totalResults.Total;
				//console.log('total::'+Total);
				var TotalPages = totalResults.TotalPages;
				//console.log('TotalPages::'+TotalPages);
				var PageNumber = totalResults.PageNumber;
				//console.log('PageNumber::'+PageNumber);
				//console.log('records' +JSON.stringify(totalResults.PanelRosterRecords));
	            component.set('v.memberList', totalResults.PanelRosterRecords);
	            if(Total == 0){
	                component.set('v.noResults', true);
	            }else{
	                component.set('v.noResults', false);
	            }
	            // console.log('checked the total');
	            //set pagination vars
	            component.set('v.pages', TotalPages);
                component.set('v.total', Total);
                component.set('v.page', PageNumber);
	            //console.log('done setting variables');
	            $A.util.addClass(component.find("spinnerId"), "slds-hide");
				$A.util.removeClass(component.find("spinnerId"), "slds-is-fixed");
				
			}
		}
		
		if(window.addEventListener !== undefined) {
			// console.log('adding listener');
			window.addEventListener("message", listener, false);
		} else {
			// console.log('attaching event');
			attachEvent("onmessage", listener);
		}	
	 },


	updateLocSearch: function (component, event, helper) {
		// console.log('updateLocSearch');
    	helper.getLocId(component, event, helper);
	},

	updateProvSearch: function (component, event, helper) {
    	helper.getProvId(component, event, helper);
	},

	firstPage : function(component, event, helper){
		window.scrollTo(0, 0);
        var spinner = component.find('spinnerId');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(component.find("spinnerId"), "slds-is-fixed");
		component.set('v.memberList', null);
		var sortField = component.get('v.sortField');
		var sortDirection = component.get('v.direction');
		var pageNum = component.set('v.page', 1);
		helper.queryMembers(component, event, helper, sortDirection, 1, sortField);
	},

	previousPage: function(component, event, helper) {
		window.scrollTo(0, 0);
        var spinner = component.find('spinnerId');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(component.find("spinnerId"), "slds-is-fixed");
		component.set('v.memberList', null);
        var sortField = component.get('v.sortField');
		var sortDirection = component.get('v.direction');
		var pageNum = component.get('v.page') -1;
		helper.queryMembers(component, event, helper, sortDirection, pageNum, sortField);
		var pageNum = component.set('v.page',pageNum);
   },
 
   nextPage: function(component, event, helper) {
	   window.scrollTo(0, 0);
       var spinner = component.find('spinnerId');
        $A.util.removeClass(spinner, 'slds-hide'); 
        $A.util.addClass(component.find("spinnerId"), "slds-is-fixed");
		component.set('v.memberList', null);
       var sortField = component.get('v.sortField');
		var sortDirection = component.get('v.direction');
		var pageNum = component.get('v.page') +1;
		helper.queryMembers(component, event, helper, sortDirection, pageNum, sortField);
		var pageNum = component.set('v.page',pageNum);
      
   },
	panelRosterSearch: function (component, event, helper){
		//turn off spinner
		var spinner = component.find('spinnerId');
		$A.util.toggleClass(spinner, 'slds-hide');
		$A.util.addClass(component.find("spinnerId"), "slds-is-fixed");
		//turn off error message
		component.set('v.isSuccess', false);
		component.set('v.isError', false);
		$('.errorMessageWrap').removeClass('hide');
		$('.successMessageWrap').removeClass('hide');


		component.set('v.memberList', null);
		var locId = component.get('v.locAcctRecId');
		var provId = component.get('v.provAcctRecId');
		// console.log('locId:: '+locId);
		// console.log('provId:: '+provId); 

		if(locId == undefined || locId == '' || locId == null || locId == 'Any'){
			if(provId == undefined || provId == '' || provId == null || provId == 'Any'){
				helper.generateMessage(component, 'error', 'Please choose a location or provider.');
				//console.log('message generated and return');
				$A.util.toggleClass(spinner, 'slds-hide');
				return;
			}
		}
		//console.log('query records');
		// console.log('calling query members');
		var sortField = component.get('v.sortField');
		var sortDirection = component.get('v.direction');
		var pageNum = component.set('v.page', 1);
		helper.queryMembers(component, event, helper, sortDirection, 1, sortField);
	},

	updateColumnSorting: function(component, event, helper){
		window.scrollTo(0,0);
		var spinner = component.find('spinnerId');
		$A.util.removeClass(spinner, 'slds-hide');
		$A.util.addClass(component.find("spinnerId"), "slds-is-fixed");
		var tar = event.currentTarget;
        var col = tar.dataset.col; //get column
        var fieldName = tar.dataset.fieldname;
        //console.log('target and column found');

        // sort direction for dynamicSort
        // if null, dynamicSort will sort ascending
        var sortDirection = '';
       
        if($A.util.hasClass(tar, 'notSorted')){
            $A.util.removeClass(tar, 'notSorted');
            
            $A.util.addClass(tar, 'sortAscend');
            sortDirection = 'ASC';
            
            $('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');

        } else if($A.util.hasClass(tar, 'sortAscend')) {
            // console.log('asc');
            //column is currently sorted by ascending order, switch it
            $A.util.removeClass(tar, 'sortAscend')
            $A.util.addClass(tar, 'sortDescend');
            sortDirection = 'DESC';
        } else {//target has sortDescend
            //column is currently sorted by descending order, switch it
            $A.util.addClass(tar, 'sortAscend');
            $A.util.removeClass(tar, 'sortDescend');
            sortDirection = 'ASC';
        }   
        // console.log('sortDirection::'+sortDirection);
        component.set('v.page', 1);
		component.set('v.direction', sortDirection);
		component.set('v.sortField', fieldName);
		helper.queryMembers(component, event, helper, sortDirection, 1, fieldName);
        // call repaginate function to re-do the pagniation
        
	},

	printList:function(component, event, helper){
		var locAcctRecId = 'locId=' + component.get("v.locAcctRecId");
		var provAcctRecId = component.get("v.provAcctRecId");
		var fName = component.find("firstNameInput").get("v.value");
		var lName = component.find("lastNameInput").get("v.value");
		var sortField = component.get('v.sortField');
		var sortDirection = component.get('v.direction');
        var routeId = sessionStorage['portalconfig_lob'];
		var URL = '/apex/prov_vf_Panel_Roster_Print?';

		if(locAcctRecId != null && locAcctRecId != ''){
			URL += locAcctRecId;
		}

		if(provAcctRecId != null && provAcctRecId != '') {
			URL += '&provId='+provAcctRecId;
		}
		if(fName != null && fName != '') {
			URL += '&fName='+fName;
		}
		if(lName != null && lName != '') {
			URL += '&lName='+lName;
		}
		if(sortField != null && sortField != '') {
			URL += '&sortField='+sortField;
		}
		if(sortDirection != null && sortDirection != '') {
			URL += '&sortDir='+sortDirection;
		}
        if(routeId != null && routeId != '') {
            URL += '&routeId='+routeId;
        }
        URL += '&bId='+component.get('v.currentBusinessId');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
        	"url": $A.get('$Label.c.SiteVFURL')+URL
        });
        urlEvent.fire(); 
	},

	downloadList: function(component,event,helper){
		//get the sortField
		var sortField = component.get('v.sortField');
		var sortDirection = component.get('v.direction');
		var spinner = component.find('spinnerId');
        	$A.util.removeClass(spinner, 'slds-hide');
        	$A.util.addClass(component.find("spinnerId"), "slds-is-fixed");
		//query for all the members with the given search criteria
		helper.downloadMembers(component, event, helper, sortDirection, 1, sortField);
	},

	memberDetail : function (component, event, helper){

		var selectItem = event.target;
        var uniGuid = selectItem.dataset.unimemguid;
        var memberGuid = selectItem.dataset.memberguid;
        var pageName = "member-detail?id="+memberGuid+'&uid='+uniGuid;

        var redirectEvent = $A.get('e.c:prov_event_Redirect');
            redirectEvent.setParams({
                "pageName" : pageName,
                newTab : true
            });
            redirectEvent.fire();
	},

	//pre auth button clicked
	startPreAuth : function(component, event, helper) {
		var curTarget = event.currentTarget;
		var memGuid = curTarget.dataset.value;
		var servLoc = component.get('v.locAcctRecId');
        var provAcctId = component.find("provAccts").get("v.value");
        if(provAcctId == undefined || provAcctId == 'Any')
        	provAcctId = '';
//		console.log('memGuid::'+memGuid);
		
		var results = component.get('v.memberList');
		for(var i in results){
//			console.log('i::'+JSON.stringify(results[i]));
			if(results[i].memberProfileGuid == memGuid){
				

	            var birthDate = new Date(results[i].birthDate);

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
				var memCov = {'FirstName__c' : results[i].firstName, 
							'LastName__c' : results[i].lastName, 
							'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthDate.getUTCFullYear(), 
							'SubscriberID__c' : results[i].memberNumber, 
							'providerId' : provAcctId,
							'serviceDate' : mm + '/' + servDD + '/'+servDate.getUTCFullYear(),
							'MemberProfileGuid' : results[i].memberProfileGuid,
							'serviceLocationId' : servLoc,
							'planGuid' : results[i].PlanGUID,
							'RouteId__c' : results[i].RouteID };
				//console.log('memCov::'+JSON.stringify(memCov));
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
	//claim button  clicked	
	startClaim : function(component, event, helper) {
		var curTarget = event.currentTarget;
		var memGuid = curTarget.dataset.value;
		var servLoc = component.get('v.locAcctRecId');
		//console.log('memGuid::'+memGuid);
		var provAcctId = component.find("provAccts").get("v.value");
        if(provAcctId == undefined || provAcctId == 'Any')
        	provAcctId = '';
		var results = component.get('v.memberList');
		for(var i in results){
//			console.log('i::'+i);
			if(results[i].memberProfileGuid == memGuid){
                //console.log('result::'+JSON.stringify(results[i]));
	            var birthDate = new Date(results[i].birthDate);

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
				var memCov = {'FirstName__c' : results[i].firstName, 
							'LastName__c' : results[i].lastName, 
							'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthDate.getUTCFullYear(), 
							'SubscriberID__c' : results[i].memberNumber, 
							'providerId' : provAcctId,
							'serviceDate' : mm + '/' + servDD + '/'+servDate.getUTCFullYear(),
							'planGuid' : results[i].PlanGuid,
							'MemberProfileGuid' : results[i].memberProfileGuid,
							'serviceLocationId' : servLoc,
							'RouteId__c' : results[i].RouteID };
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
	startReferral : function(component, event, helper) {
		var curTarget = event.currentTarget;
		var memGuid = curTarget.dataset.value;
		var servLoc = component.get('v.locAcctRecId');
		//console.log('memGuid::'+memGuid);
		var provAcctId = component.find("provAccts").get("v.value");
        if(provAcctId == undefined || provAcctId == 'Any')
        	provAcctId = '';
		var results = component.get('v.memberList');
		for(var i in results){
			if(results[i].memberProfileGuid == memGuid){
				
	            var birthDate = new Date(results[i].birthDate);

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
				var memCov = {'FirstName__c' : results[i].firstName, 
							'LastName__c' : results[i].lastName, 
							'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthDate.getUTCFullYear(), 
							'SubscriberID__c' : results[i].memberNumber, 
							'providerId' : provAcctId,
							'serviceDate' : mm + '/' + servDD + '/'+servDate.getUTCFullYear(),
							'planGuid' : results[i].PlanGuid,
							'MemberProfileGuid' : results[i].memberProfileGuid,
							'serviceLocationId' : servLoc,
							'RouteId__c' : results[i].RouteID };
				//console.log('memCov::'+JSON.stringify(memCov));
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
	//broken appointment button clicked	
	startBrokenAppt : function(component, event, helper) {
		var curTarget = event.currentTarget;
		var memGuid = curTarget.dataset.value;
		var servLoc = component.get('v.locAcctRecId');
		//console.log('memGuid::'+memGuid);
		var provAcctId = component.find("provAccts").get("v.value");
        if(provAcctId == undefined)
        	provAcctId = '';
		var results = component.get('v.memberList');
		for(var i in results){
			console.log('i::'+i);
			if(results[i].memberProfileGuid == memGuid){
				var birthDate = new Date(results[i].birthDate);
                
                var birthDay = birthDate.getUTCDate();
                
                if (birthDay <= 9) {
	                birthDay = '0' + birthDay;
	            }

				 var birthMM = birthDate.getUTCMonth()+1; 
	            if (birthMM <= 9) {
	                birthMM = '0' + birthMM;
	            }
				var memCov = {'FirstName__c' : results[i].firstName, 
							'LastName__c' : results[i].lastName, 
							'Birthdate__c' : birthDate.getUTCFullYear() + '-'+ birthMM + '-' + birthDay, 
							'SubscriberID__c' : results[i].memberNumber, 
							'providerId' : provAcctId,
							'MemberProfileGuid' : results[i].memberProfileGuid,
							'serviceLocationId' : servLoc,
							'RouteId__c' : results[i].RouteId };
//				console.log('memCov::'+memCov);
				localStorage[memGuid] = JSON.stringify(memCov);
			}
		} 
		var pageName = 'broken-appointment'
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : pageName,
			'memberProfileGuid' :memGuid,
			newTab : true
		});
		redirectEvent.fire();
	},

})