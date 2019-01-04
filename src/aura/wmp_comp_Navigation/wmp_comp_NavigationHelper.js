({

	retrievePlans : function(component){
		var action = component.get("c.retrieveMemberPlans");
		action.setCallback(this, function(response){
			var state = response.getState();
			var resList = [];
			
			if(state == 'SUCCESS'){
				var returnList = response.getReturnValue();
//				console.log('success');
				var count = 0;
				for(var key in returnList){
//					console.log('key::'+key);
					resList.push(returnList[key]);
					count+= 1;
//					for(var ki in returnList[key]){
//						console.log('inside ki :: '+ki);
//						console.log('value of ki :: '+returnList[key][ki]);
//					}
				}
				component.set('v.showMultiplePlans', count >1);
				component.set('v.memPlans', resList); 
				//component.runMethod();
			} else{
			
				component.set('v.showMultiplePlans', false);
				component.set('v.memPlans', resList); 
			}
		});
//		console.log('fire...');
		$A.enqueueAction(action);
	},
	
	
	
	helperLoadConfig : function(component){
		var action= component.get('c.loadConfiguration');
		
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var pConfig = response.getReturnValue();
				//console.log('pConfig.name::'+pConfig.Label);
				var fadL = pConfig.Find_a_Dentist_Label__c;
				var idCardFunctionality = pConfig.ID_card_functionality__c;
				component.set('v.hasIDCard', idCardFunctionality);
				//console.log('fadL::'+fadL);
				
				if(fadL != null){
					var fadV = $A.getReference('$Label.c.'+ fadL);
					component.set('v.findadentistL', fadV);
//					component.runMethod();
				}
			}
		});
		
		$A.enqueueAction(action);
	},
	
	
})