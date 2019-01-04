({
	//hide the additional locations
	hideMore : function(component, event, helper){
		var moreDiv = component.find('moreOfficeSectionId');
		var showDiv = component.find('showOfficeDiv');
		var hideDiv = component.find('hideOfficeDiv');
		$A.util.toggleClass(moreDiv, 'showDiv');
		$A.util.toggleClass(showDiv, 'showDiv');
		$A.util.toggleClass(hideDiv, 'showDiv');
	},
	
	//show more of the locations
	showMore : function(component, event, helper){
		var moreDiv = component.find('moreOfficeSectionId');
		var showDiv = component.find('showOfficeDiv');
		var hideDiv = component.find('hideOfficeDiv');
		$A.util.toggleClass(moreDiv, 'showDiv');
		$A.util.toggleClass(showDiv, 'showDiv');
		$A.util.toggleClass(hideDiv, 'showDiv');
	},
	
	//launch the modal containing the info on the element. THis could be for the dentist or a service location
	launchModal : function(component, event, helper){
		var recClick = event.currentTarget;
		var recId = recClick.dataset.id;
		var recName = recClick.dataset.name;
		$A.createComponent(
							'c:WMP_comp_Modal',
							{
								'value' : recId,
								'typeName' : 'RECDETAIL',
								'headerText' : recName
							},
							function(newModal, status, errorMessage){
								//Add the new button to the body array
								if (status === "SUCCESS") {
									var body = component.get("v.body");
									body.push(newModal);
									component.set('v.body', body);
								}
							}
		);
		
	},
	
	//launch the Primary Case Dentist change component. pass the service location and dentist where applicable
	
	
	//launch the primary care dentist component which allows the user to change their PCD
	referralEntry : function(component, event, helper){
		//var memCovIds = component.get('v.memCovIds');
		//console.log('referralEntry...');
		var dentist = component.get('v.dentist');
		var recClick = event.currentTarget;
		var childIndex = recClick.dataset.index;
		//console.log('childIndex::'+childIndex);
		var childObj;
		if(childIndex <= 2){
			childObj = dentist.children[childIndex-1];
		} else {
			childObj = dentist.moreChildren[childIndex-1];
		
		}
		//console.log('childObj.streetAddress::'+JSON.stringify(childObj));
		
		/*
			 <aura:attribute name="firstName" type="String"/>
			  <aura:attribute name="lastName" type="String"/>
			  <aura:attribute name="npi" type="String"/>
			  <aura:attribute name="phone" type="String"/>
			  <aura:attribute name="address" type="String"/>
			  <aura:attribute name="city" type="String"/>
			  <aura:attribute name="state" type="String"/>
			  <aura:attribute name="zip" type="String"/>
			  <aura:attribute name="locationId" type="String"/>
			  <aura:attribute name="providerId" type="String"/>
		 */
        var redirectEvent = $A.get('e.c:prov_event_FAD_Modal');
        redirectEvent.setParams({
        	name : childObj.providerName,
        	npi : childObj.npi,
        	phone : childObj.phone,
        	city : childObj.city,
        	address : childObj.streetAddress,
        	state : childObj.state,
        	zip : childObj.zipcode,
        	locationId : childObj.serviceLocationId,
        	providerId : childObj.providerid,
            routeId : childObj.routeId
            
        });
        redirectEvent.fire();
        
        component.set('v.closeModal', true);
	},
})