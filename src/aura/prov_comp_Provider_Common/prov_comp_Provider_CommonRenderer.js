({
    rerender : function(component, helper){
        //console.log('Common ReRender');
    	// do custom rerendering here
        var cbid = component.get('v.currentBusinessId');
        //console.log('cbid: '+ cbid);
    	if(cbid==undefined){
            this.superRerender();
    		helper.initializeBusiness(component);
            helper.setParams(component);
            helper.setPermissionsHelper(component);
            helper.getCurrentPortalConfig(component);
            helper.setCurrentContact(component);  
        }
	}
})