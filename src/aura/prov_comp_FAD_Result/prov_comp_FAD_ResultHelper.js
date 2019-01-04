({
	retrievePagination : function(component){
		var paginate = component.get('c.paginationVariables');
		
		paginate.setCallback(this, function(response){
			var state = response.getState();
			//console.log('state::'+state);
			if(state == 'SUCCESS'){
				var responseList = response.getReturnValue();//first value is totalResults, second value is total pages
				component.set('v.numResults', responseList[0]);
				component.set('v.totalPages', responseList[1]);
				component.set('v.resultsPerPage', responseList[2]);
				
				this.setResultList(component);
				
				//get the spinner and hide it
				////console.log('about to turn off spinner...');
				var spinner = component.find('uploadSpinner_FAD');
				$A.util.toggleClass(spinner, 'slds-hide');
				////console.log(' spinner off...');
			}
		});
		
		$A.enqueueAction(paginate);
	},
	
	
	retrieveProviders_Office : function(component){
		//create the action to retrieve the fad results grouped by office
		var action = component.get('c.retrieveDentists_Office');
		var paramMap = component.get('v.paramMap');

		action.setParams({'paramMap' :paramMap});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				var resList = response.getReturnValue();
				
				component.set('v.fullResultList', resList);
				component.set('v.pageNum', 1);
				
				this.setResultList(component);
				
			}
		});
		
		$A.enqueueAction(action);
	},
	
	retrieveProviders_Dentist : function(component){
		//create the action to retrieve the fad results grouped by dentist
		var action = component.get('c.retrieveDentists_Dentist');
		var paramMap = component.get('v.paramMap');
		action.setParams({'paramMap' : paramMap});
		action.setCallback(this, function(response){
			var state = response.getState();
			////console.log('state::'+state);
			if(state == 'SUCCESS'){
				var resList = response.getReturnValue();
				
				component.set('v.fullResultList', resList);
				component.set('v.pageNum', 1);
				
				//this.setResultList(component);
				
			}
		});
		
		$A.enqueueAction(action);
	},
	
	setResultList : function(component){
		var fullResults = component.get('v.fullResultList');
		var rPerPage = component.get('v.resultsPerPage');
		var resultList = [];
		var pageNum = component.get('v.pageNum');
		
		var numResults = rPerPage * pageNum;
		if(numResults > fullResults.length)
			numResults = fullResults.length;

		for(var i = (pageNum-1)*rPerPage; i < numResults; i++){
			resultList.push(fullResults[i]);
		}
		////console.log('setResultList...'+JSON.stringify(resultList));
		component.set('v.resultList', resultList);
	},
	
	
})