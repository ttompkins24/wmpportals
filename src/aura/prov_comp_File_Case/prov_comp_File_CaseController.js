({
	doInit : function(component, event, helper) {
		component.set('v.typeChosen', null);
		helper.retrieveCaseFieldValues(component);
		helper.retrieveCaseTypes(component);
		helper.retrieveCaseSettingMap(component);
	},

	changeCurrentCaseSetting : function(component, event, helper) {
		var typeChosen = component.get('v.typeChosen');
		var caseSettingMap = component.get('v.caseSettingMap');
		var singleCaseSetting = caseSettingMap[typeChosen];
		helper.resetFields(component,true);
		//console.log('singleCaseSetting: '+JSON.stringify(singleCaseSetting));
		component.set('v.selectedCaseSetting', singleCaseSetting);
	},

	createDraftCase : function(component, event, helper) {
		component.set('v.showSpinner', true);
		
		var paramMap = helper.createParamMap(component);
		helper.createDraftCase(component, paramMap);		
	},

	saveCase : function(component, event, helper) {
		component.set('v.showSpinner', true);

		helper.resetErrors(component);

		var isError = helper.validateEntry(component);

		if(!isError) {
			var paramMap = helper.createParamMap(component);
			helper.createCase(component, paramMap);
		}
	},
	
	//utility methods
    fixDate : function(component, event, helper) {
        helper.fixDate(component, event, helper);
	},

	fixPhone : function(component) {
		//console.log('fixPhone start');
		var s = component.get('v.phoneNumber');
		//console.log('s: '+s);
		var s2 = (""+s).replace(/\D/g, '');
		//console.log('s2: ' +s2);
		var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
		//console.log('m: '+m);
		var fixedPhone = (!m) ? "" : "(" + m[1] + ") " + m[2] + "-" + m[3];
		component.set('v.phoneNumber', fixedPhone);
		//console.log('fixedPhone: '+fixedPhone);
		//console.log('fixPhone end');
	}
    // end utility methods
})