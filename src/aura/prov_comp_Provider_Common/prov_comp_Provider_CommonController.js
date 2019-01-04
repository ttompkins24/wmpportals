({
    commonInit: function(component, event, helper) {
        //console.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        //console.log('common init -- This is a child component.');
        //console.log('comp: ' + JSON.stringify(component));
        
        //If the local storage exists, just initialize
        if(localStorage['providercache']!=undefined){
            helper.initializeBusiness(component);
            helper.setParams(component);
            helper.setPermissionsHelper(component);
            helper.getCurrentPortalConfig(component);
            helper.setCurrentContact(component);   
        } else {
           // console.log('no cache');
        }
  		
    },
})