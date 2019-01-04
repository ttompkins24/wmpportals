({
	chooseLocation : function(component, event, helper) {
		var selectItem = event.currentTarget;
		var officeName = selectItem.dataset.officename;
		var officeId = selectItem.dataset.officeid;
		var address = selectItem.dataset.address;
		
		//set the attributes for the office
		component.set('v.officeName', officeName);
		component.set('v.officeId', officeId);
		component.set('v.addressInfo', address);
		component.set('v.stageName', 'SETMEM');
	}
})