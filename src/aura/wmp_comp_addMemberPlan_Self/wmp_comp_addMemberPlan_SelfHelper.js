{
	//number of years the date picker goes back
	picklistYears : function(component) {
		var currentYear = (new Date()).getFullYear();
		var options = [];
		
		for(var i = 0; i <= 100; i++){
			var obj = {'Label' : currentYear-i, 'Value': currentYear-i};
			options.push( obj );
		}
		
		component.set('v.years', options);
	},
	
	//get the users first name
	getUserFirstName : function(component){
		var action = component.get('c.getUserName');
		action.setCallback(this, function(response){
			if(response.getState() === 'SUCCESS'){
				component.set('v.memberName', response.getReturnValue());
			}
		});
		
		$A.enqueueAction(action);
	},
}