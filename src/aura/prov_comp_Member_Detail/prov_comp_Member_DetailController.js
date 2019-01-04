({
    /**
     * Init the method and get the member.
     * The id parameter is required
     */
    init : function(component, event, helper) {
    	var labelName = component.get("v.portalConfig.PreAuthorization_Label__c");
 		labelValue = $A.getReference("$Label.c." + labelName);
 		
 		component.set("v.preAuthLabel", labelValue);
 		
        helper.getMember2(component, 
            component.get('v.params.id'), 
            component.get('v.params.provider'),
            component.get('v.params.location')
        );
        //console.log('fire det');
        //helper.getMemberDet(component,component.get('v.params.id'));
        helper.getMemberAdd(component,component.get('v.params.id'));
        helper.getMemberPhone(component,component.get('v.params.id'));
        
    },

    /**
     * Change the tab step and load a sub component
     */
	changeStep : function (component, event, helper) {    
	    var source = event.target || event.srcElement;

	    $(component.find("path").getElement()).find('li').each(function(){
	      	$(this).removeClass('slds-is-active');
	    });
	    $(source).closest('li').addClass('slds-is-active');
	    var sourceId = $(source).attr('id');

        // check tab name
	    if(sourceId.indexOf('history') > -1) {
	    	component.set('v.selectedTabIndex', 2);
	    } else if(sourceId.indexOf('claims') > -1) {
	    	component.set('v.selectedTabIndex', 1);
	    } else {
	    	component.set('v.selectedTabIndex', 0);
	    }
  	},

    /**
     * Toggle action dropdown
     */
  	toggleDropdown: function(component, event, helper) {
  		$( "#action-dropdown" ).toggleClass( 'slds-is-open' );
  	},

    /**
     * Stubbed methods to be fire a URL event to a new page.
     */
  	/*startClaim : function(component, event, helper) {
  		$( "#action-dropdown" ).toggleClass( 'slds-is-open' );
  	},
  	startPreAuth : function(component, event, helper) {
  		$( "#action-dropdown" ).toggleClass( 'slds-is-open' );
  	},
  	findDentist : function(component, event, helper) {
  		$( "#action-dropdown" ).toggleClass( 'slds-is-open' );
  	} */
  	
  	//pre auth button clicked
	//pre auth button clicked
	startPreAuth : function(component, event, helper) {
		var curTarget = event.currentTarget;
		//console.log('memGuid::'+memGuid);
		var provider = component.get('v.pcdProvider');
		var servLocation = component.get('v.pcdServiceLocation');
		var member = component.get('v.member');
		var serviceDate = component.get('v.activeDate');
		var activePlan = component.get('v.activePlan');
        //console.log('serviceDate::'+serviceDate);
		var coverage = activePlan.coverage;
        //
		
		var memGuid = member.MemberProfileGUID__c;
        //console.log('memGuid::'+memGuid);
		var serviceDateArray = serviceDate.split('T')[0].split('-');
        var servDD = serviceDateArray[2];
        var servMM = serviceDateArray[1];
		var servYY = serviceDateArray[0];
        

        //console.log('dob::'+member.Birthdate__c);
        var birthdateArray = member.Birthdate__c.split('-');
        var birthDD = birthdateArray[2];
        var birthMM = birthdateArray[1];
		var birthYY = birthdateArray[0];
		
		var memCov = {'FirstName__c' : member.FirstName__c, 
					'LastName__c' : member.LastName__c, 
					'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthYY, 
					'SubscriberID__c' : coverage.SubscriberID__c, 
					'serviceDate' : servMM + '/' + servDD + '/'+servYY,
					'planGuid' : activePlan.windward_guid__c,
					'RouteId__c' : member.RouteID__c };
		//console.log('memCov::'+memCov);
		if(provider != undefined && provider != null){
            memCov['providerId'] = provider.Id;
            memCov['serviceLocationId'] = servLocation.Id;
        }
		localStorage[memGuid] = JSON.stringify(memCov);
		
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
		//console.log('memGuid::'+memGuid);
		var provider = component.get('v.pcdProvider');
		var servLocation = component.get('v.pcdServiceLocation');
		var member = component.get('v.member');
		var serviceDate = component.get('v.activeDate');
		var activePlan = component.get('v.activePlan');
		
        //console.log('looping through coverage:'+JSON.stringify(activePlan));
        //console.log('provider : '+provider);
        //console.log('servLocation : '+servLocation);
        var coverage = activePlan.coverage;
		var memGuid = member.MemberProfileGUID__c;
		console.log('memGuid ' + memGuid );
		var serviceDateArray = serviceDate.split('T')[0].split('-');
        //console.log('serviceDateArray::'+serviceDateArray);
        var servDD = serviceDateArray[2];
        var servMM = serviceDateArray[1];
		var servYY = serviceDateArray[0];
		
        var birthdateArray = member.Birthdate__c.split('-')
        var birthDD = birthdateArray[2];
        var birthMM = birthdateArray[1];
		var birthYY = birthdateArray[0];
		
		var memCov = {'FirstName__c' : member.FirstName__c, 
					'LastName__c' : member.LastName__c, 
					'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthYY, 
					'SubscriberID__c' : coverage.SubscriberID__c, 
					'serviceDate' : servMM + '/' + servDD + '/'+servYY,
					'planGuid' : activePlan.windward_guid__c,
					'RouteId__c' : member.RouteID__c };
        if(provider != undefined && provider != null){
            memCov['providerId'] = provider.Id;
            memCov['serviceLocationId'] = servLocation.Id;
        }
		console.log('memCov::'+memCov);
		localStorage[memGuid] = JSON.stringify(memCov);
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
		//console.log('memGuid::'+memGuid);
		var provider = component.get('v.pcdProvider');
		var servLocation = component.get('v.pcdServiceLocation');
		var member = component.get('v.member');
		var serviceDate = component.get('v.activeDate');
		var activePlan = component.get('v.activePlan');
		var coverage = activePlan.coverage;
		
		
		var memGuid = member.MemberProfileGUID__c;

		var memCov = {'FirstName__c' : member.FirstName__c, 
					'LastName__c' : member.LastName__c, 
					'Birthdate__c' : member.Birthdate__c, 
					'SubscriberID__c' : coverage.SubscriberID__c, 
					'serviceDate' : serviceDate,
					'planGuid' : activePlan.windward_guid__c,
					'RouteId__c' : member.RouteID__c };
        if(provider != undefined && provider != null){
            memCov['providerId'] = provider.Id;
            memCov['serviceLocationId'] = servLocation.Id;
        }
		//console.log('memCov::'+memCov);
		localStorage[memGuid] = JSON.stringify(memCov);
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
		//console.log('memGuid::'+memGuid);
		var provider = component.get('v.pcdProvider');
		var servLocation = component.get('v.pcdServiceLocation');
		var member = component.get('v.member');
		var serviceDate = component.get('v.activeDate');
		var activePlan = component.get('v.activePlan');
		var coverage = activePlan.coverage;
		console
		
		var memGuid = member.MemberProfileGUID__c;

		var serviceDateArray = serviceDate.split('T')[0].split('-');
        var servDD = serviceDateArray[2];
        var servMM = serviceDateArray[1];
		var servYY = serviceDateArray[0];
		//var servDD = serviceDate.getUTCDate();
        //var servMM = serviceDate.getUTCMonth() +1;
        //var servYY = serviceDate.getUTCYear();
		

        var birthdateArray = member.Birthdate__c.split('-')
        var birthDD = birthdateArray[2];
        var birthMM = birthdateArray[1];
		var birthYY = birthdateArray[0];
		
		var memCov = {'FirstName__c' : member.FirstName__c, 
					'LastName__c' : member.LastName__c, 
					'Birthdate__c' : birthMM + '/' + birthDD + '/'+birthYY, 
					'SubscriberID__c' : coverage.SubscriberID__c, 
					'serviceDate' : servMM + '/' + servDD + '/'+servYY,
					'planGuid' : activePlan.windward_guid__c,
					'RouteId__c' : member.RouteID__c };
       	if(provider != undefined && provider != null){
            memCov['providerId'] = provider.Id;
            memCov['serviceLocationId'] = servLocation.Id;
        }
		//console.log('memCov::'+memCov);
		localStorage[memGuid] = JSON.stringify(memCov);
		var pageName = 'referral-entry'
		var redirectEvent = $A.get('e.c:prov_event_Redirect');
		redirectEvent.setParams({
			'pageName' : pageName+'?memId='+memGuid,
			newTab : true
		});
		redirectEvent.fire();
	},
	
	printLink: function(component, event, helper) {
		window.print();
	},
})