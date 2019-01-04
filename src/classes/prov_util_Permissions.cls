public without sharing class prov_util_Permissions {
	
	/*************************************************************************************************
	**************************************INSTANCE VARIABLES *****************************************
	*************************************************************************************************/
	@AuraEnabled 
    public String memberEligibility {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String claims {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String preAuth {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String memberIntervention {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String userManagement {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String feeSchedule {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String panelRoster {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String brokenAppointment {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String findDentist {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String outOfNetwork {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String referral {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String eob {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String payments {get;set;} //possible values: 'none', 'read' and 'full'
    
    //dentist list functionality. Also called Practice Management
    @AuraEnabled 
    public String dentistList {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String eft {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String billedAmount {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String reports {get;set;} //possible values: 'none', 'read' and 'full'
    @AuraEnabled 
    public String tierAccess {get;set;} //possible values: '1', '2' and '3'
    @AuraEnabled 
    public Boolean admin {get;set;} //possible values: 'none', 'read' and 'full'
    
    /***************************************************************************************
	**************************************Constructor***************************************
	***************************************************************************************/
    public List<String> permissionList_Notification(){
    	List<String> permissionList = new List<String>();
		if(memberEligibility != 'none'){
			permissionList.add('Member Eligibility');
		}
		
		if(claims != 'none'){
			permissionList.add('Claim');
		}
		
		if(preAuth != 'none'){
			permissionList.add('PreAuthorization');
		}
		
		if(memberIntervention != 'none'){
			permissionList.add('Member Intervention');
		}
		
		if(userManagement != 'none'){
			permissionList.add('User Management');
		}
		
		if(feeSchedule != 'none'){
			permissionList.add('Fee Schedule');
		}
		
		if(panelRoster != 'none'){
			permissionList.add('PCD');
		}
		
		if(brokenAppointment != 'Broken Appointment'){
			permissionList.add('Claim');
		}
		
		if(referral != 'none'){
			permissionList.add('Referral');
		}
		
		if(eob != 'none'){
			permissionList.add('EOB');
		}
		
		if(payments != 'none'){
			permissionList.add('Payment');
		}
		
		if(dentistList != 'none'){
			permissionList.add('Practice Management');
		}
		
		if(eft != 'none'){
			permissionList.add('EFT');
		}
		
		if(billedAmount != 'none'){
			permissionList.add('Billed Amount');
		}
		
		if(reports != 'none'){
			permissionList.add('Report');
		}
		
		return permissionList;
    }
    
    public prov_util_Permissions(Provider_Portal_Configuration__mdt config, List<String> permissionSet, Account business, Provider_Business_Permission__c permission){
    	//create temp variables to hold the results from all of the plan configurations. Set all to false 
    	System.debug('inti...');
    	//initialize the variables. These values will hold the AND statement from the permission object and portal config
    	Boolean memberEligibilityEnabled = false;
    	Boolean claimsEnabled= false;
    	Boolean feeScheduleEnabled= false;
    	Boolean panelRosterEnabled=false;
    	Boolean brokenAppointmentEnabled= false;
    	Boolean preAuthEnabled= false;
    	Boolean findDentistEnabled= false;
    	Boolean outOfNetworkEnabled= false;
    	Boolean referralEnabled= false;
    	Boolean eobEnabled= false;
    	Boolean paymentsEnabled= false;
    	Boolean dentistListEnabled= false;
    	Boolean eftEnabled= false;
    	Boolean billedAmountEnabled= false;
    	Boolean reportsEnabled= false;
    	Boolean memberInterventionEnabled= false;
    	
    	//intialize all features to none
		panelRoster = 'none';
		brokenAppointment = 'none';
		memberIntervention = 'none';
		memberEligibility = 'none';
		claims = 'none';
		preAuth = 'none';
		billedAmount = 'none';
		feeSchedule = 'none';
		referral = 'none';
		dentistList = 'none';
		eft = 'none';
		reports = 'none';
		eob = 'none';
		payments = 'none';
		findDentist = 'none';
		outOfNetwork = 'none';
    	userManagement = 'none';
    	if(permission == null) return;
/*Enable_Member_Intervention__c
		(SELECT Business__c, Enable_Billed_Amount__c, Enable_EFT__c, Enable_EOB__c, Enable_FAD__c, Enable_Member_Eligibility__c, 
		Enable_Practice_Management__c, Enable_FAD_OON__c, Enable_Fee_Schedule__c, Enable_Member_Intervention__c, 
		Enable_Panel_Roster__c, Enable_Referrals__c, Enable_Reports__c, Id, Enable_Broken_Appointment__c
		FROM Provider_Business_Permissions__r)     	 
    	*/
    	try{ 
	    	//Provider_Business_Permission__c permission = business.Provider_Business_Permissions__r[0];
	    	System.debug('permission::'+permission);
	    	//do an AND operation comparing the results from the plan config with the provider portal config fields (meaning if it is turned off at the portal level then no access is given. )
	    	// if it is true on the portal config then at least one of the plans need to be true in order to access the field
	    	memberEligibilityEnabled=	 		permission.Enable_Member_Eligibility__c 	&& config.Member_Eligibility_Access__c;
	    	claimsEnabled= 						permission.Enable_Claim_PreAuth__c		 	&& config.Claims_Access__c;
	    	feeScheduleEnabled= 				permission.Enable_Fee_Schedule__c 			&& config.Fee_Schedule_Access__c;
	    	panelRosterEnabled= 				permission.Enable_Panel_Roster__c 			&& config.Panel_Roster_Access__c;
	    	brokenAppointmentEnabled= 			permission.Enable_Broken_Appointment__c 	&& config.Broken_Appointment_Access__c;
	    	preAuthEnabled= 					permission.Enable_Claim_PreAuth__c		 	&& config.Pre_Authorization_Access__c;
	    	findDentistEnabled= 				permission.Enable_FAD__c 					&& config.Find_a_Dentist_Access__c;
	    	outOfNetworkEnabled =				permission.Enable_FAD_OON__c 				&& config.Allow_out_of_network__c;
	    	referralEnabled= 					permission.Enable_Referrals__c	 			&& config.Referral_Access__c;
	    	eobEnabled= 						permission.Enable_EOB__c 					&& config.EOB_Access__c;
	    	paymentsEnabled= 					permission.Enable_Payment__c			 	&& config.Payment_Access__c;
	    	dentistListEnabled= 				permission.Enable_Practice_Management__c 	&& config.Dentist_List_Access__c;
	    	eftEnabled= 						permission.Enable_EFT__c 					&& config.EFT_Access__c;
	    	billedAmountEnabled= 				permission.Enable_Billed_Amount__c 			&& config.Billed_Amount_Access__c;
	    	reportsEnabled= 					permission.Enable_Reports__c 				&& config.Report_Access__c;
	    	memberInterventionEnabled= 			permission.Enable_Member_Intervention__c	&& config.Member_Intervention_Access__c;
	    	
	    	//set the user management from the business verification. ignore 
	    	this.admin = false;
	    	
	    	System.debug('permissionSet::'+permissionSet);
	    	for(String perm : permissionSet){
	    		String accessLevel = ''; 
				String feature;
				//see if the permission is all
				if(perm.equalsIgnoreCase('ALL')){
					accessLevel = 'full';
					feature = 'ALL';
				} else if(perm.equalsIgnoreCase('None')){
					feature = 'ALL';
					accessLevel = 'none';
				}else{
		    		String[] permList = perm.split('_');
					feature = permList[0];
					
					if(permList[1].equalsIgnoreCase('F'))  {
						accessLevel = 'full';
					} else if(permList[1].equalsIgnoreCase('R')){
						accessLevel = 'read';
					} else {
						accessLevel = 'none';
					}
				}
				System.debug('feature::'+feature);
				System.debug('accessLevel::'+accessLevel);
				
				if(feature.toLowercase() == 'mec' || feature == 'ALL'){
					//should they have member eligibility enabled
			    	if(memberEligibilityEnabled){
			    		memberEligibility = accessLevel;
			    	} else {
			    		memberEligibility = 'none';
			    	}
	
					//should they have access to member intervention
			    	if(memberInterventionEnabled){
			    		memberIntervention = accessLevel;
			    	} else {
			    		memberIntervention = 'none';
			    	}
			    	
			    	//broken appointment access
			    	if(brokenAppointmentEnabled ){
			    		brokenAppointment = accessLevel;
			    	} else {
			    		brokenAppointment = 'none';
			    	}
			    	
			    	//panel roster access
			    	if(panelRosterEnabled ){
			    		panelRoster = accessLevel;
			    	} else {
			    		panelRoster = 'none';
			    	}
				} 
				if(feature.toLowercase() == 'cp' || feature == 'ALL'){
					//should claims be enabled
			    	if(claimsEnabled){
			    		claims = accessLevel;
			    	} else {
			    		claims = 'none';
			    	}
			    	
					//should preAuth be enabled
			    	if(preAuthEnabled){
			    		preAuth = accessLevel;
			    	} else {
			    		preAuth = 'none';
			    	}
			    	
			    	//billed amount access
			    	if(billedAmountEnabled){
			    		billedAmount = accessLevel;
			    	} else {
			    		billedAmount = 'none';
			    	}
			    	
			    	//fee schedule access
			    	if(feeScheduleEnabled){
			    		feeSchedule = accessLevel;
			    	} else {
			    		feeSchedule = 'none';
			    	}
			    	
			    	//referral access
			    	if(referralEnabled ){
			    		referral = accessLevel;
			    	} else {
			    		referral = 'none';
			    	}
	    	
				} 
				if(feature.toLowercase() == 'um' || feature == 'ALL'){
			    	userManagement = accessLevel;
				} 
				
				if(feature.toLowercase() == 'dl' || feature == 'ALL'){
			    	//dentistList access
			    	if(dentistListEnabled){
			    		dentistList = accessLevel;
			    	} else {
			    		dentistList = 'none';
			    	}
				} 
				
				if(feature.toLowercase() == 'eft' || feature == 'ALL'){
			    	//eft access
			    	if(eftEnabled ){
			    		eft = accessLevel;
			    	} else {
			    		eft = 'none';
			    	}
				} 
				
				if(feature.toLowercase() == 'rep' || feature == 'ALL'){
			    	//report access
			    	if(reportsEnabled ){
			    		reports = accessLevel;
			    	} else {
			    		reports = 'none';
			    	}
				} 
				
				if(feature.toLowercase() == 'eob' || feature == 'ALL'){
			    	//eob access
			    	if(eobEnabled){
			    		eob = accessLevel;
			    	} else {
			    		eob = 'none';
			    	}
			    	
			    	//payment access
			    	if(paymentsEnabled){
			    		payments = accessLevel;
			    	} else {
			    		payments = 'none';
			    	}
				}
	    	} 
	    	
	    	//find a dentist access
	    	if(findDentistEnabled ){
	    		findDentist = 'full';
	    	} else {
	    		findDentist = 'none';
	    	}
	    	
	    	//find a dentist access
	    	if(outOfNetworkEnabled ){
	    		outOfNetwork = 'full';
	    	} else {
	    		outOfNetwork = 'none';
	    	}
    		System.debug('user permission::'+this);
    	} catch (Exception ex){
    		System.debug('************************************');
    		System.debug('Error::'+ex.getMessage());
    		System.debug('LN::'+ex.getLineNumber());
    		System.debug('stackTrace::'+ex.getStackTraceString());
    		System.debug('***********************************');
    	}
    }
}