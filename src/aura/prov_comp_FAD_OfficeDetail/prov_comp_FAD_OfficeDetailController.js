({
	//hide the more children
	hideMore : function(component, event, helper){
		var moreDiv = component.find('moreDentistsSectionId');
		var showDiv = component.find('showDentistsDiv');
		var hideDiv = component.find('hideDentistsDiv');
		$A.util.toggleClass(moreDiv, 'showDiv');
		$A.util.toggleClass(showDiv, 'showDiv');
		$A.util.toggleClass(hideDiv, 'showDiv');
	},
	
	//show the children in the more children section for the office
	showMore : function(component, event, helper){
		var moreDiv = component.find('moreDentistsSectionId');
		var showDiv = component.find('showDentistsDiv');
		var hideDiv = component.find('hideDentistsDiv');
		$A.util.toggleClass(moreDiv, 'showDiv');
		$A.util.toggleClass(showDiv, 'showDiv');
		$A.util.toggleClass(hideDiv, 'showDiv');
	},
	
	//launch the modal component with the info about a certain dentist or office that was selected
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
						//push the modal onto the page for it to be displayed
						var body = component.get("v.body");
						body.push(newModal);
						component.set('v.body', body);
					}
				}
		);
		
	},
	
	//launch the primary care dentist component which allows the user to change their PCD
	referralEntry : function(component, event, helper){
		var memCovIds = component.get('v.memCovIds');
		var office = component.get('v.office');
		var officeAddress = component.get('v.office.address');
		var recClick = event.currentTarget;
		var childIndex = recClick.dataset.index;
		var childObj;
		if(childIndex <= 2){
			childObj = office.children[childIndex-1];
		} else {
			childObj = office.moreChildren[childIndex-1];
		
		}
		//console.log('childObj.streetAddress::'+childObj.streetAddress);
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