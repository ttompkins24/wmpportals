({
	doInit : function(component, event, helper) {
		helper.initLanguage(component);
		helper.getNotifications(component);
		
		var getNotificationInterval = 
            $A.getCallback(function() {
                helper.getNotifications(component);
            });
        
        window.clearInterval(getNotificationInterval);
        
        window.setInterval(getNotificationInterval, 1000000); 
		
		  
	},
	
	
})