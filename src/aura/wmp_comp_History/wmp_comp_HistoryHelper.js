({
	retrieveMemberInfo : function(component) {
		var action = component.get('c.getCurrentMember');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				component.set('v.currMember', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},
	
	retrieveServiceHistory : function(component) {
		var action = component.get('c.retrieveHistory');
		action.setCallback(this, function(response){
			var resultList = [];
			if(response.getState() == 'SUCCESS'){
				var resultMap = response.getReturnValue();
				
				
				for(var newDate in resultMap){
					console.log('newDate::'+newDate);
					var obj = {procedureDate : new Date(newDate), lineItems : []};
					for(var wrap in resultMap[newDate]){
						console.log('wrap::'+wrap);
						console.log('resultMap[newDate][wrap]::'+resultMap[newDate][wrap]);
						console.log('description::'+resultMap[newDate][wrap].description);
						obj.lineItems.push(resultMap[newDate][wrap]);
					}
					resultList.push(obj);
				}
				
				component.set('v.historyFullList', resultList);
				
				
				this.retrievePagination(component);
			} else {
				
				component.set('v.historyFullList', resultList);
				$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
			}
		});
		$A.enqueueAction(action);
	},
	
	retrievePagination : function(component){
		var paginate = component.get('c.paginationVariables');
		
		paginate.setCallback(this, function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				var responseList = response.getReturnValue();//first value is totalResults, second value is total pages
				component.set('v.resultsPerPage', responseList[0]);
				
				var fullResults = component.get('v.historyFullList');
				var numResults = fullResults.length;
				component.set('v.numResults', numResults);
				
				var totalPages = Math.ceil( numResults  / responseList[0]);
				totalPages = totalPages == 0 ? 1 : totalPages;
				component.set('v.totalPages', totalPages);
				
				this.setResultList(component);
			} else{
				component.set('v.resultsPerPage', 5);
				component.set('v.numResults', 0);
				component.set('v.totalPages', 1);
				this.setResultList(component);
			}
			
		});
		
		$A.enqueueAction(paginate);
	},
	
	setResultList : function(component){
		var fullResults = component.get('v.historyFullList');
		var rPerPage = component.get('v.resultsPerPage');
		var resultList = [];
		var pageNum = component.get('v.pageNum');
		var numResults = rPerPage * pageNum;

		if(numResults > fullResults.length)
			numResults = fullResults.length;

		for(var i = (pageNum-1)*rPerPage; i < numResults; i++){
			resultList.push(fullResults[i]);
            console.log(fullResults[i]);
		}
		
		component.set('v.historyList', resultList);
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
	},
})