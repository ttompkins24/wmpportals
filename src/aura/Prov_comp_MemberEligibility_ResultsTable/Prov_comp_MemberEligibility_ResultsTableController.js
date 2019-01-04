({

	doInit : function(component, event, helper){
 		//get Pre Auth label from Portal config
 		var labelName = component.get("v.portalConfig.PreAuthorization_Label__c");
 		labelValue = $A.getReference("$Label.c." + labelName);
 		
 		//console.log('pre auth label: ' + labelValue);

 		component.set("v.preAuthLabel", labelValue);
 	 //console.log('results table::'+JSON.stringify(component.get('v.resultsList')));

	},


	//sorts the column selected
	updateColumnSorting: function(component, event, helper){
		//start the spinner
		var spinner = component.find('spinnerId');
		$A.util.toggleClass(spinner, 'slds-hide');
		
		//get the element clicked
		var tar = event.currentTarget;
		var col = tar.dataset.col; //get column

		//get table Id
		var tableId = tar.dataset.tableid;
		//get the table 
		var table = $('#'+tableId);		

		//is this column not order
		if($A.util.hasClass(tar, 'notSorted')){
			$A.util.removeClass(tar, 'notSorted');
			if(col == 1){
				//default last updated to descend. newest first
				$A.util.addClass(tar, 'sortDescend');
				sortTable(table, col, 'DESC');
			} else {
				$A.util.addClass(tar, 'sortAscend');
				sortTable(table, col, 'ASC');
			}
			$('.sortable').not(tar).removeClass('sortAscend').removeClass('sortDescend').addClass('notSorted');

		} 
		else if($A.util.hasClass(tar, 'sortAscend')) {
			//column is currently sorted by ascending order, switch it
			$A.util.removeClass(tar, 'sortAscend')
			$A.util.addClass(tar, 'sortDescend');
			sortTable(table, col, 'DESC');
		}
		else {//target has sortDescend
			//column is currently sorted by descending order, switch it
			$A.util.addClass(tar, 'sortAscend');
			$A.util.removeClass(tar, 'sortDescend');
			sortTable(table, col, 'ASC');
		}
		
		//hide the spinner
		$A.util.toggleClass(spinner, 'slds-hide');
	},

	//dropdown button clicked
	runDropdown:function(component, event, helper){
		var menu = component.find('actionMenu');
		menu.setAttribute("visible", "true");
		event.stopPropagation();
	},

	//pre auth button clicked
	startPreAuth : function(component, event, helper) {
		var curTarget = event.currentTarget;
		var memGuid = curTarget.dataset.value;
		//console.log('memGuid::'+memGuid);
		
		var results = component.get('v.resultsList');
		for(var i in results){
		 //console.log('i::'+i);
			if(results[i].memberProfileGuid == memGuid){
				var servDate = new Date(results[i].serviceDate);

				 var mm = servDate.getUTCMonth()+1; 
	            if (mm <= 9) {
	                mm = '0' + mm;
	            }

	           var servDD = servDate.getUTCDate(); 
	            if (servDD <= 9) {
	                servDD = '0' + servDD;
	            }

	            var birthDate = new Date(results[i].birthDate);

				 var birthMM = birthDate.getUTCMonth()+1; 
	            if (birthMM <= 9) {
	                birthMM = '0' + birthMM;
	            }
	            var birthDD = birthDate.getUTCDate(); 
	            if (birthDD <= 9) {
	                birthDD = '0' + birthDD;
	            }
				var memCov = {'FirstName__c' : results[i].firstName, 
							'LastName__c' : results[i].lastName, 
							'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthDate.getUTCFullYear(), 
							'SubscriberID__c' : results[i].memberNumber, 
							'providerId' : results[i].providerId,
							'serviceLocationId' : results[i].serviceLocationId,
							'serviceDate' : mm + '/' + servDD + '/'+servDate.getUTCFullYear(),
							'planGuid' : results[i].planGUID };
			 //console.log('memCov::'+memCov);
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
		//console.log('memGuid::'+memGuid);
		
		var results = component.get('v.resultsList');
		for(var i in results){
		 //console.log('i::'+i);
			if(results[i].memberProfileGuid == memGuid){
				var servDate = new Date(results[i].serviceDate);

				 var mm = servDate.getUTCMonth()+1; 
	            if (mm <= 9) {
	                mm = '0' + mm;
	            }
	            
	            var servDD = servDate.getUTCDate(); 
	            if (servDD <= 9) {
	                servDD = '0' + servDD;
	            }

	            var birthDate = new Date(results[i].birthDate);

				 var birthMM = birthDate.getUTCMonth()+1; 
	            if (birthMM <= 9) {
	                birthMM = '0' + birthMM;
	            }
	            var birthDD = birthDate.getUTCDate(); 
	            if (birthDD <= 9) {
	                birthDD = '0' + birthDD;
	            }
				var memCov = {'FirstName__c' : results[i].firstName, 
							'LastName__c' : results[i].lastName, 
							'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthDate.getUTCFullYear(), 
							'SubscriberID__c' : results[i].memberNumber, 
							'providerId' : results[i].providerId,
							'serviceLocationId' : results[i].serviceLocationId,
							'serviceDate' : mm + '/' + servDD + '/'+servDate.getUTCFullYear(),
							'planGuid' : results[i].planGUID,
							'serviceLocationId' : results[i].serviceLocationId
							//'RouteId__c' : results[i].memCov[0].RouteID__c 
							};
			 //console.log('memCov::'+memCov);
				localStorage[memGuid] = JSON.stringify(memCov);
			}
		} 
		// var pageName = 'temp-claims'
		var pageName = 'claim-entry'
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
		//console.log('memGuid::'+memGuid);
		
		var results = component.get('v.resultsList');
		for(var i in results){
		 //console.log('i::'+i);
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
	            
				var memCov = {'FirstName__c' : results[i].firstName, 
							'LastName__c' : results[i].lastName, 
							'Birthdate__c' : birthDate.getUTCFullYear() + '-' + birthMM + '-' + birthDD , 
							'SubscriberID__c' : results[i].memberNumber,
							'planGuid' : results[i].planGUID,
							'providerId' : results[i].providerId,
							'serviceLocationId' : results[i].serviceLocationId,
							'RouteId__c' : sessionStorage["portalconfig_lob"] };
			 //console.log('memCov::'+memCov);
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
	
	//broken appointment button clicked	
	startReferral : function(component, event, helper) {
		var curTarget = event.currentTarget;
		var memGuid = curTarget.dataset.value;
		//console.log('memGuid::'+memGuid);
		
		var results = component.get('v.resultsList');
		for(var i in results){
			if(results[i].memberProfileGuid == memGuid){
				var servDate = new Date(results[i].serviceDate);

				 var mm = servDate.getUTCMonth()+1; 
	            if (mm <= 9) {
	                mm = '0' + mm;
	            }
	            
	            var servDD = servDate.getUTCDate(); 
	            if (servDD <= 9) {
	                servDD = '0' + servDD;
	            }

	            var birthDate = new Date(results[i].birthDate);

				 var birthMM = birthDate.getUTCMonth()+1; 
	            if (birthMM <= 9) {
	                birthMM = '0' + birthMM;
	            }
	            var birthDD = birthDate.getUTCDate(); 
	            if (birthDD <= 9) {
	                birthDD = '0' + birthDD;
	            }
	            
				var memCov = {'FirstName__c' : results[i].firstName, 
							'LastName__c' : results[i].lastName, 
							'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthDate.getUTCFullYear(), 
							'SubscriberID__c' : results[i].memberNumber, 
							'providerId' : results[i].providerId,
							'serviceLocationId' : results[i].serviceLocationId,
							'serviceDate' : mm + '/' + servDD + '/'+servDate.getUTCFullYear(),
							'planGuid' : results[i].planGUID,
							'serviceLocationId' : results[i].serviceLocationId };
			 console.log('memCov::'+JSON.stringify(memCov));
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

	//member named clicked, redirect to member detail page
	redirectUrl : function(component, event, helper){
		var selectItem = event.currentTarget;
		var memberGuid = selectItem.dataset.memberguid;
		var universalGuid = selectItem.dataset.uid;
		var planGuid = selectItem.dataset.planguid;
		var providerId = selectItem.dataset.providerid;
		var slId = selectItem.dataset.slid;
		var serviceDate = selectItem.dataset.servicedate;
		var pageName = "member-detail";
		
		var urlParams = {'pageName' : pageName,
			'memberProfileGuid' :memberGuid,
			'serviceLocationId' : slId,
			'providerId' : providerId,
			'serviceDate' : serviceDate,
			newTab : true};
		if(universalGuid != undefined && universalGuid != ''){
			urlParams['extraParams'] = 'uid='+universalGuid + '&planid='+planGuid;
		} else{
			urlParams['extramsParams'] = 'planid='+planGuid;
		
		}
		
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams( urlParams );
		redirectEvent.fire();
	},
})