({
	clearCheckmark : function(component, event) {
		var actionstring = component.get('v.actionString');
		var selectedValue = component.get('v.selectedValue');
		console.log('selectedValue uncheck: '+selectedValue);
		$('.'+actionstring+'.checked').each(function(index){
			console.log('checkmark uncheck loop');
			if(!selectedValue) {
				$(this).removeClass('checked');
				console.log('unchecking');
			} 
		});
	},

	addCheckmark : function(component, event) {
		var actionstring = component.get('v.actionString');
		var selectedValue = component.get('v.selectedValue');
		console.log('selectedValue check: '+selectedValue.value);
		var actionstring2 = $('.'+actionstring);
		// console.log('actionstring2: '+JSON.stringify(actionstring2));
		$('.'+actionstring).each(function(index){
			console.log('checkmark check loop');
			if(selectedValue) {
				if($(this).data('value') == selectedValue) {
					$(this).addClass('checked');
					console.log('checking');
				}
			} 
		});
	}
})