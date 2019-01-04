({
	doInit : function(component, event, helper) {
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
		helper.retrieveMemberInfo(component);
		helper.retrieveServiceHistory(component);
	},

	launchDetail : function(component, event, helper){
		var recClick = event.currentTarget;
		var procedureCode = recClick.dataset.procedurecode;
		var partOfMouth = recClick.dataset.partofmouth;
		var claimNumber = recClick.dataset.claimnumber;
		var eobName = recClick.dataset.eobname;
		var eobUrl = recClick.dataset.eoburl;
		var claimStatus = recClick.dataset.claimstatus;
		var planName = recClick.dataset.planname;
		var totalCost = recClick.dataset.totalcost;
		var planPay = recClick.dataset.planpay;
		var youPay = recClick.dataset.youpay;
		var description = recClick.dataset.description;
		var provider = recClick.dataset.provider;
		var appDate = recClick.dataset.appdate;
		$A.createComponent(
				'c:wmp_comp_History_Detail',
				{
					'procedureCode' : procedureCode,
					'partOfMouth' : partOfMouth,
					'claimNumber' : claimNumber,
					'eobName' : eobName,
					'eobUrl' : eobUrl,
					'claimStatus' : claimStatus,
					'planName' : planName,
					'totalCost' : totalCost,
					'planPay' : planPay,
					'youPay' : youPay,
					'description' : description,
					'provider' : provider,
					'appDate' : appDate
					
				},
				function(newModal, status, errorMessage){
					//Add the new button to the body array
					if (status == "SUCCESS") {
						var body = component.get("v.body");
						body.push(newModal);
						component.set('v.body', body);
					}
				}
		);
	},
	
	nextPageClick : function(component, event, helper){
		//get the spinner and start it
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
		
		//get the current pageNum
		var pageNum = component.get('v.pageNum');
		
		//set the new current page Num
		component.set('v.pageNum', pageNum + 1);
		
		helper.setResultList(component);
		//end and remove the spinner
		window.scrollTo(0,0);
		
	},
	
	previousPageClick : function(component, event, helper){
		//get the spinner and start it
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
		
		//get the current pageNum
		var pageNum = component.get('v.pageNum');
		
		//set the new current page Num
		component.set('v.pageNum', pageNum - 1);
		
		helper.setResultList(component);
		//end and remove the spinner
		window.scrollTo(0,0);
	},
	
	firstPageClick : function(component, event, helper){
		//get the spinner and start it
		$A.util.toggleClass(component.find("loadingSpinner"), "slds-hide");
		
		//get the current pageNum
		var pageNum = component.get('v.pageNum');
		
		//set the new current page Num
		component.set('v.pageNum',  1);
		
		helper.setResultList(component);
		//end and remove the spinner
		window.scrollTo(0,0);
	},
	
	printScreen : function(component, event, helper){
		console.log('print screen 1');
		window.print();
		console.log('print screen 2');
	},
})