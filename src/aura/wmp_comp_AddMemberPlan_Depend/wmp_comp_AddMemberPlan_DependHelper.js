({
	/* GET THE PICKLIST values for the year the person was born*/
	picklistYears : function(component) {
		var currentYear = (new Date()).getFullYear();
		var options = [];
		
		for(var i = 0; i <= 100; i++){
			var obj = {'Label' : currentYear-i, 'Value': currentYear-i};
			options.push( obj );
		}
		
		component.set('v.years', options);
	},
	
	
})