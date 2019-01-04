({
	loadMemberInfo : function(component) {
		var action = component.get('c.retrieveAllMemberCoverageInfo');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var resultMap = response.getReturnValue();
				var memSuccessMap = component.get('v.memSuccessMap');
				var successList = [];
				var failList = [];
				var openList = [];
				var obj = {};
				var memCovList = [];
				
				for(var memCovId in memSuccessMap){
					obj = {'memCovId' : memCovId, 'mName' : resultMap[memCovId].name, 'planName' : resultMap[memCovId].planName};
					if(memSuccessMap[memCovId] == 'error'){
						failList.push(obj);
					} else if(memSuccessMap[memCovId] == 'open') {
						openList.push(obj);
					}else {
						successList.push(obj);
						memCovList.push(memCovId);
					}
				}
				
				component.set('v.successList', successList);
				component.set('v.openList', openList);
				component.set('v.failList', failList);
				component.set('v.successMemCovIds', memCovList);
			}
		});
		$A.enqueueAction(action);
		
	},
})