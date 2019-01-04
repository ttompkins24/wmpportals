({
	fetchReasonPicklist : function(component){
		var action = component.get('c.fetchPicklistValues_Reason');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var resMap = response.getReturnValue();
				//init values
				var reasonList = [];
				var obj;
				
				for( var key in resMap){
					if(resMap[key].Value != undefined){
						obj = {'Value':resMap[key].Value, 'Label':resMap[key].Label, 'Description' : resMap[key].Description};
					
						reasonList.push(obj);
					}
				}
				component.set('v.reasonList', reasonList);
//				component.find('specialities_M').set('v.options', specialList);
			}
		});
		
		$A.enqueueAction(action);
	},
})