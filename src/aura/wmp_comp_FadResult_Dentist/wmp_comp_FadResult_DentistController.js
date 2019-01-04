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
	launchSetPCD : function(component, event, helper){
		var memCovIds = component.get('v.memCovIds');
		var dentist = component.get('v.dentist');
		var dentistId = dentist.id;
		var children = dentist.children.slice(0);
		//put all the children in one list (children+moreChildren
		for(var key in dentist.moreChildren){
			children.push(dentist.moreChildren[key]);
		}
		$A.createComponent(
				'c:wmp_comp_MainDentist',
				{
					'memCovIds' : memCovIds,
					'dentistId' : dentistId,
					'stageName' : 'SETLOC',
					'children' : children,
					'dentistName' : dentist.name
				},
				function(newModal, status, errorMessage){
					//Add the new button to the body array
					if (status === "SUCCESS") {
						//push the modal onto the page
						var body = component.get("v.body");
						body.push(newModal);
						component.set('v.body', body);
					}
				}
		);
		children = [];
	},
})