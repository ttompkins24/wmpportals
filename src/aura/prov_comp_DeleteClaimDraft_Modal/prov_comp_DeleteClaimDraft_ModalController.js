({
	doInit : function(component, event, helper) {
		helper.countDrafts(component, event, helper);
		if(component.get('v.submitInProgress')) { 
			//console.log(('submit in process');
			helper.submitDrafts(component);
			// window.setTimeout(
			// 	$A.getCallback(function() {
			// 		component.set('v.submitInProgress', false);
			// 		helper.closeModal(component, event, helper);
			// 	}), 5000
			// );
		}
		//console.log(('claim show at delete modal init: '+ localStorage['showDeleteClaimDraftWarning']);
		//console.log(('auth show at delete modal init: '+ localStorage['showDeleteAuthDraftWarning']);
	},

	closeModal: function(component, event, helper) {
		helper.setSuppressWarning(component, event, helper);
		helper.closeModal(component, event, helper);
	},

	confirmDelete: function(component, event, helper) {
		helper.deleteDrafts(component, event, helper);
	}
})