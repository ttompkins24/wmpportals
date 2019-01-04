({
    doInit : function(component, event, helper){
        //remove spaces from field label
        cleanedLabel = component.get('v.fieldLabel').replace(/\s/g, '');
        component.set('v.cleanedFieldLabel',cleanedLabel);
        //console.log('cleanedFieldLabel: '+component.get('v.cleanedFieldLabel'));
        component.set('v.actionString','inputAction'+cleanedLabel + component.get('v.classList'));
        // helper.addCheckmark(component, event);    
    },

    updateCheckmark : function(component, event, helper) {
        helper.addCheckmark(component, event);    
        helper.clearCheckmark(component, event);
    },

	multiClick : function(component, event, helper){
        var currentTarget = event.currentTarget;
        //console.log('currentTarget: '+ JSON.stringify(component));
        var actionstring = component.get('v.actionString');
        var delimiter = component.get('v.delimiter');
        //console.log('action: ' + actionstring);
        $(currentTarget).toggleClass('checked');
        var newText = '';
        var displayValue = '';
        $('.'+actionstring+'.checked').each(function(index){
            newText += $(this).data('value') + delimiter + ' ';
            displayValue += $(this).data('display') + delimiter + ' ';
            console.log('display iterate: ' + displayValue);
            //console.log('value: '+JSON.stringify($(this).data('value')));
        });
        //remove last two characters for readability and usability
        newText = newText.slice(0,-2);
        displayValue = displayValue.slice(0,-2);
        //console.log('label: '+$(currentTarget).data('label'));
        //console.log('displayValue: '+ displayValue);
        
        $('#'+actionstring).val(newText);

        //console.log('actionstring: '+actionstring);
        component.set('v.selectedValue',newText);
        component.set('v.displayValue',displayValue);
        //console.log('finished setting: '+component.get('v.selectedValue'));
    }
})