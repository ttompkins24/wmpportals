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
	launchSetPCD : function(component, event, helper){
		var memCovIds = component.get('v.memCovIds');
		var office = component.get('v.office');
		var officeAddress = component.get('v.office.address');
		var recClick = event.currentTarget;
		var dentistId = recClick.dataset.id;
		var dentistName = recClick.dataset.name;
		$A.createComponent(
				'c:wmp_comp_MainDentist',
				{
					'memCovIds' : memCovIds,
					'dentistId' : dentistId,
					'dentistName' : dentistName,
					'officeId' : office.id,
					'officeName' : office.name,
					'addressInfo' : officeAddress,
					'stageName' : 'SETMEM'
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
})