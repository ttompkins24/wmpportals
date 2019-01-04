({
	// Your renderer method overrides go here
    rerender : function(component, helper){
        console.log('Homepage ReRender');
        var ts = component.get('v.taskStarter');
        //console.log('ts: ' + ts);
        if(ts==undefined){
    		this.superRerender();
    	 	helper.setDefaultTaskStarter(component);
            helper.retrieveBanner(component);
            helper.recentMessages(component);
            helper.recentEvents(component);
        }
	}
})