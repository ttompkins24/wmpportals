/*******************************************************************************************************
Name 						: Prov_ctrl_MemberEligibility
Purpose						: Apex controller for Member Eligibilty lightning components
								
Created on					: 10 Jan 2018
Developed by				: West Monroe Partners
History
Version#		Sprint#		Date					by  							Comments
1.0				1.0			10 Jan 2018		West Monroe Partners					See header - purpose
 
*******************************************************************************************************/ 
global without sharing class Prov_ctrl_MemberEligibility {

	//https://dev1-greatdentalplans-community.cs13.force.com

	public String portalURL {get;set;}

	private String eligibilityStr;

	public void setEligibilityStr(String str){
		eligibilityStr = str;
	}

	public String getEligibilityStr() {
		return eligibilityStr;
	}

	public Prov_ctrl_MemberEligibility() {
		portalURL = System.Label.Member_Eligibility_VF_URL;
	}


	public static Set<String> availableBusinessPlans {get;set;}

	public static Map<String, Account> acctMap {get;set;}

	public static List<Prov_ctrl_MemberEligibility.MemberWrapper> eligibleList {get;set;}
	public static List<Prov_ctrl_MemberEligibility.MemberWrapper> ineligibleList {get;set;}
	public static List<Prov_ctrl_MemberEligibility.MemberWrapper> notFoundList {get;set;}
	public static List<Prov_ctrl_MemberEligibility.MemberWrapper> outOfNetworkList {get;set;}


	@RemoteAction
	global static object getMemberCoveragesRemote(String str){
		System.debug('Passed in String: ' + str);

		//rehydrate JSON string into Search Wrapper class
		SearchWrapper sw = (SearchWrapper) System.JSON.deserialize(str, SearchWrapper.class);
		System.debug('sw: ' + sw);

		if(sw.memberList == null && sw.member != null){
			 List<Prov_ctrl_MemberEligibility.MemberWrapper> memberList = new  List<Prov_ctrl_MemberEligibility.MemberWrapper>();
			 memberList.add(sw.member);
			 sw.memberList = memberList;
		}

		if(prov_util_MockData.useMockData){
            //we are in test or dev, do not make the callout
            List<mock_MemberCoverage__c> memCovList = prov_util_DAL.getMemberCoverageByNameBirthdateMemberNumber(sw.memberList, sw.business);
            System.debug('memCovList ' + memCovList);
            String eligiblityStr = JSON.serialize(memCovList); 
            System.debug('mem cov results: ' + eligiblityStr);
            return eligiblityStr; 
        } else {

			HTTPRequest request = prov_util_MemberEligibilityCallout.getPayload(sw.memberList, sw.business);
			//Create a continuation for HTTPRequest
	        Continuation con = new Continuation(60);
	        con.state = con.addHttpRequest(request);
	        con.continuationMethod = 'callback';
	        return con;
       } 
	}

    global static object callback(Object state){
        System.debug('in callback');

        HttpResponse res = Continuation.getResponse((String) state);
        System.debug('response ' + res);
        System.debug('response ' + res.getBody());

        if(res.getStatusCode()!=200){
            system.debug('--Member Eligibility Search Request-------------------------------------------------------------------------');
            system.debug('Response failed.');
            system.debug(res.getStatusCode());
            system.debug(res.getBody());
            system.debug('--Member Eligibility Search Request-------------------------------------------------------------------------');
              String str = '[{"FirstName":"Error","LastName":"timeout"}]';
            return (Object) str; 
        } else {
            system.debug('Member Eligibility Body: ' + res.getBody());
	        return res.getBody();
        }
    }

	//recieves the remote action from the Visual force page.  Splits apart the passed in JSON and calls the searchEligibility method
	@RemoteAction
	global static Map<String, List<Prov_ctrl_MemberEligibility.MemberWrapper>> checkEligibilityRemote(String memCovStr, String str){
		System.debug('Passed in String: ' + memCovStr);


		SearchWrapper sw = (SearchWrapper) System.JSON.deserialize(str, SearchWrapper.class);
		System.debug('sw: ' + sw);

		if(sw.memberList == null && sw.member != null){
			 List<Prov_ctrl_MemberEligibility.MemberWrapper> memberList = new  List<Prov_ctrl_MemberEligibility.MemberWrapper>();
			 memberList.add(sw.member);
			 sw.memberList = memberList;
		}

        List<mock_MemberCoverage__c> memCoverageList = new List<mock_MemberCoverage__c>();

		if(prov_util_MockData.useMockData){
			memCoverageList = (List<mock_MemberCoverage__c>) JSON.deserialize(memCovStr, List<mock_MemberCoverage__c>.class);
		} else {
	      	List<prov_util_MemberEligibilityCallout.HTTPResponseWrap> responseList = (List<prov_util_MemberEligibilityCallout.HTTPResponseWrap>) JSON.deserialize(memCovStr, List<prov_util_MemberEligibilityCallout.HTTPResponseWrap>.class);
	        System.debug('responseList::'+responseList);
	            
	        for(prov_util_MemberEligibilityCallout.HTTPResponseWrap respWrap : responseList){
	            memCoverageList.add( respWrap.covertToMemberCoverage() );
	        }			
		}



        System.debug('memCoverageList ' + memCoverageList);

		Map<String, List<Prov_ctrl_MemberEligibility.MemberWrapper>> results = searchEligibility(sw.memberList, memCoverageList, sw.business, sw.serviceLocation, sw.provider, sw.routeId);
        System.debug('results ' + results);

        if(!results.containsKey('timeout')){

	        //used only for Claims Drafts and Pre Auth Drafts
	        //update claim fields
	        List<Claim__c> claimList = new List<Claim__c>();

	        List<Prov_ctrl_MemberEligibility.MemberWrapper> bigList = new List<Prov_ctrl_MemberEligibility.MemberWrapper>();
	        for(String s : results.keySet()){
	        	bigList.addAll(results.get(s));	
	        }

	        for(Prov_ctrl_MemberEligibility.MemberWrapper mem : bigList){
	        	System.debug('mem wrapper ' + mem );
	        	if(mem.claim != null){
	        		Claim__c c = new Claim__c();
	        		c.id = mem.claim;
	        		c.Last_Eligibility_Check__c = Datetime.now();
	        		if(mem.status == 'I'){
	        			c.Last_Eligibility_Status__c = 'Ineligible'; 
	        		} else if(mem.status == 'E'){
	        			c.Last_Eligibility_Status__c = 'Eligible';
	        		} else if(mem.status == 'O'){
	        			c.Last_Eligibility_Status__c = 'Out of Network';
	    			} else if( mem.status == null || mem.status == '' || mem.status == 'NF'){
	        			c.Last_Eligibility_Status__c = 'Not Found';
	        		}
	        		claimList.add(c);
	        	}
	        }
	        System.debug('updated Claims ' + claimList);
	        if(claimList.size() > 0){
	        	update claimList;
	        }
		}
        System.debug('::::Remote Results ' + results);



        return results;
	}


	@AuraEnabled
	public static Map<String, List<Prov_ctrl_MemberEligibility.MemberWrapper>> searchEligibility(List<Prov_ctrl_MemberEligibility.MemberWrapper> criteriaList, List<mock_MemberCoverage__c> memCovResults, String businessId, String serviceLocationId, String providerId, String routeId){
		Map<String, Claim__c> claimMap = new Map<String, Claim__c>();
		for(Prov_ctrl_MemberEligibility.MemberWrapper crit : criteriaList){
			if(crit.claim != null && crit.claim != ''){
				claimMap.put(crit.claim,null);
			}
		}
		if(claimMap.keyset().size() > 0){
			Set<String> claimids = claimMap.keyset();
			claimMap = new Map<String, Claim__c>([SELECT id, Plan__c, plan__r.guid__c FROM Claim__c WHERE Id IN:claimids]);
		}
        System.debug('claimMap::'+claimMap.keyset());
        
		//holds the eligible dates
		Set<Date> eligibleDates = new Set<Date>();

		//holds guids for providers and service locations
		Set<String> SLProviderGUIDs = new Set<String>();

		//holds provider/ServiceLocation GUID to Account
		acctMap = new Map<String, Account>();

		//holds the list of plans that a business/SL/Provider supports for a given date
		Map<Date, Set<String>> dateToPlansMap = new Map<Date, Set<String>>();

		System.debug('criteriaList ' + criteriaList);
		System.debug('businessId ' + businessId);
		System.debug('serviceLocationId ' + serviceLocationId);
		System.debug('providerId ' + providerId);

		//get plans that the passed in business has in network
		availableBusinessPlans = prov_util_cache.getVisibilePlanWWIds(businessId);

		//holds the eligible members to be returned
		eligibleList = new List<Prov_ctrl_MemberEligibility.MemberWrapper>();
		//holds the ineligible members to be returned
		ineligibleList = new List<Prov_ctrl_MemberEligibility.MemberWrapper>();
		//holds the members not found
		notFoundList = new List<Prov_ctrl_MemberEligibility.MemberWrapper>();
		//out of network
		outOfNetworkList = new List<Prov_ctrl_MemberEligibility.MemberWrapper>();

		//get Member Coverage records for the supplied members
		System.debug('*********************************START***********************************');
			
		System.debug('memCov Results Size ' + memCovResults.size());


		//check if any results came back
		if(memCovResults.size() > 0){
			//if its an error, fail out/
			if(memCovResults[0].FirstName__c != 'Error'){
				/******************
					loop through coverage records and criteria list.  
						a record is eligible if the service date falls between the effective and term dates
					populate additional criteria fields need for displaying information on lightning components
				******************/
			for(Integer i=0 ; i < criteriaList.size(); i++){
				Prov_ctrl_MemberEligibility.MemberWrapper c = criteriaList.get(i);
				for(mock_MemberCoverage__c mc : memCovResults){

					System.debug('mc in forloop ' + mc);
					if(mc.RouteId__c.containsIgnoreCase(routeId)){
						//add provider and sl guids to SLProviderGUIDs

							System.debug('**************'+c.claim+ 'criteria in forloop ' + c);
							if(c.claim != '' && c.claim != null){
                                if(claimMap.containsKey(c.claim)){
                                    if(claimMap.get(c.claim).Plan__c != null){
	                                    if(claimMap.get(c.claim).Plan__r.guid__c.toLowercase() != mc.PlanGuid__c.tolowercase()){
	                                        System.debug('member coverage plan is not the same as the one selected on the claim...');
	                                        continue;
	                                    }
                                    }
                                }
                            }
                            
							if(mc.ServiceLocationGUID__c != null){
								SLProviderGUIDs.add(mc.ServiceLocationGUID__c);
							}
							if(mc.ProviderGUID__c != null){
								SLProviderGUIDs.add(mc.ProviderGUID__c);
							}
							SLProviderGUIDs.add(mc.PlanGuid__c.tolowercase());
							//User entered First Name, Last Name, and Member Number
							if(c.firstName != '' && c.firstName != null && c.lastName != '' && c.lastName != null && c.memberNumber != ''  && c.memberNumber != null){
                                
								System.debug('Name & Number Match');
								acctMap.put(mc.PlanGuid__c.tolowercase(), null);
								//check if criteria matches member coverage record
								if(mc.FirstName__c.containsIgnoreCase(c.firstName) && mc.LastName__c.containsIgnoreCase(c.lastName) && (c.memberNumber.equalsIgnoreCase(mc.SubscriberID__c) || c.memberNumber.equalsIgnoreCase(mc.MedicaidID__c)) && c.birthDate == mc.Birthdate__c){

									System.debug('coverage plan: '+mc.PlanGUID__c);
									System.debug('service date: ' + c.serviceDate);
									System.debug('coverage start date: ' + mc.EffectiveDate__c);
									System.debug('coverage end date: ' + mc.TerminationDate__c);						
									//check to see if the memCoveragePlan matches provider plans and the date is in range
									if((c.serviceDate <= mc.TerminationDate__c || mc.TerminationDate__c == null) && mc.EffectiveDate__c <= c.serviceDate){
										if(c.status == 'I'){
											c.termDate = null;
										}
										
										//check to see if the business covers this plan (high level - will get checked at the PSL level later)
										if(availableBusinessPlans.contains(mc.PlanGuid__c.toLowercase())){
											//change status to Eligible, add to eligible list
											system.debug('Eligible');
											if(c.status == 'O'){
												c.memCov = new List<mock_MemberCoverage__c>();
											}
                                            c.status = 'E';
											//add member coverage to criteria member coverage list
											c.memCov.add(mc);
										} else if(c.status != 'E') {
											system.debug('plan not supported by business');
											//out of network
											c.status = 'O';
											c.memCov.add(mc);
										}
									} else {
										//change status to ineligible
										system.debug('Not Eligibile');
										if(c.status != 'E' && c.status != 'O'){
											c.status = 'I';
											c = updateCriteria(c, mc, serviceLocationId, providerId);
											//c.memCov.add(mc);
										}
									} 
								} 
							
							} 

							//user entered first name and last name
							else if(c.firstName != '' && c.lastName != ''  && c.firstName != null && c.lastName != null){
								//check if criteria matches member coverage record
								if(mc.FirstName__c.containsIgnoreCase(c.firstName) && mc.LastName__c.containsIgnoreCase(c.lastName) && c.birthDate == mc.Birthdate__c){

									System.debug('coverage plan: '+mc.PlanGUID__c);
									System.debug('service date: ' + c.serviceDate);
									System.debug('coverage start date: ' + mc.EffectiveDate__c);
									System.debug('coverage end date: ' + mc.TerminationDate__c);						
									//check to see if the memCoveragePlan matches provider plans and the date is in range
									if((c.serviceDate <= mc.TerminationDate__c || mc.TerminationDate__c == null) && mc.EffectiveDate__c <= c.serviceDate){
										if(c.status == 'I'){
											c.termDate = null;
										}
										
										//check to see if the business covers this plan (high level - will get checked at the PSL level later)
										if(availableBusinessPlans.contains(mc.PlanGuid__c.toLowercase())){
											//change status to Eligible, add to eligible list
											system.debug('Eligible');
											if(c.status == 'O'){
												c.memCov = new List<mock_MemberCoverage__c>();
											}
                                            c.status = 'E';
											//add member coverage to criteria member coverage list
											c.memCov.add(mc);
										} else if(c.status != 'E') {
											system.debug('plan not supported by business');
											//out of network
											c.status = 'O';
											c.memCov.add(mc);
										}
									} else {
										//change status to ineligible
										system.debug('Not Eligibile');
										if(c.status != 'E' && c.status != 'O'){
											c.status = 'I';
											c = updateCriteria(c, mc, serviceLocationId, providerId);
											//c.memCov.add(mc);
										}
									}
								} 
							} 

							//user entered member number 
							else if(c.memberNumber != '' && c.memberNumber != null){
								//check if criteria matches member coverage 	record
								if((c.memberNumber.equalsIgnoreCase(mc.SubscriberID__c) || c.memberNumber.equalsIgnoreCase(mc.MedicaidID__c)) && c.birthDate == mc.Birthdate__c){
								
									System.debug('coverage plan: '+mc.PlanGUID__c);
									System.debug('service date: ' + c.serviceDate);
									System.debug('coverage start date: ' + mc.EffectiveDate__c);
									System.debug('coverage end date: ' + mc.TerminationDate__c);						
									//check to see if the memCoveragePlan matches provider plans and the date is in range
									if((c.serviceDate <= mc.TerminationDate__c || mc.TerminationDate__c == null) && mc.EffectiveDate__c <= c.serviceDate){
										if(c.status == 'I'){
											c.termDate = null;
										}
										
										//check to see if the business covers this plan (high level - will get checked at the PSL level later)
										if(availableBusinessPlans.contains(mc.PlanGuid__c.toLowercase())){
											//change status to Eligible, add to eligible list
											system.debug('Eligible');
											if(c.status == 'O'){
												c.memCov = new List<mock_MemberCoverage__c>();
											}
                                            c.status = 'E';
											//add member coverage to criteria member coverage list
											c.memCov.add(mc);
										} else if(c.status != 'E') {
											system.debug('plan not supported by business');
											//out of network
											c.status = 'O';
											c.memCov.add(mc);
										}
                                    } else {
										//change status to ineligible
										system.debug('Not Eligibile');
										if(c.status != 'E' && c.status != 'O'){
											c.status = 'I';
											c = updateCriteria(c, mc, serviceLocationId, providerId);
											//c.memCov.add(mc);
										}
									}
								}
							}
						} //end member coveragefor loop
					}//end if statement
				}//end criteria for loop
				System.debug('acctMap::'+acctMap.keyset());
				//get account ids that match Provider and Service Location Ids in SLProviderGUIDs
				if(SLProviderGUIDs.size() > 0){
					acctMap = prov_util_DAL.getAccountWWMap(SLProviderGUIDs);	
				}

				//loop through search criteria and where status = not found or not eligible, add to correct list 
				//If a criteria is eligible and has multiple memcoverage's move to NOT FOUND
				Set<String> plansWithCriteriaCreated = new Set<String>();
				System.debug('crit list again ' + criteriaList);
				List<Prov_ctrl_MemberEligibility.MemberWrapper> additionalCriteriaList = new List<Prov_ctrl_MemberEligibility.MemberWrapper>();
				for(Prov_ctrl_MemberEligibility.MemberWrapper criteria : criteriaList){

					//clear plansWithCriteriaCreated set for each new Criteria
					plansWithCriteriaCreated = new Set<String>();
					
					//if a criteria has no member coverages, it goes to not found with error message of not found
					if(criteria.memCov.size() == 0 && criteria.status.equalsIgnoreCase('NF')){
						//no member coverages were found
						criteria.errorMessage = System.label.Not_Found_No_Members;
						notFoundList.add(criteria);
					} else if(criteria.memCov.size() == 0 && criteria.status.equalsIgnoreCase('I')){
						ineligibleList.add(criteria);
					} else if(criteria.status == 'MM'){//multiple members found for this criteria
						criteria.status = 'NF';
						criteria.errorMessage = System.label.Not_Found_Multiple_Members;
						notFoundList.add(criteria);
					}//if a criteria has 1 member coverage, put it where the criteria.status dictates
					else if(criteria.memCov.size() == 1){
						System.debug('member coverage size 1...');
						mock_MemberCoverage__c mc = criteria.memCov.get(0);

						criteria = updateCriteria(criteria, mc, serviceLocationId, providerId);

						//add criteria ineligible list if needed
						if(criteria.status == 'I'){
							ineligibleList.add(criteria);
						} else if(criteria.status == 'E'){
							eligibleDates.add(criteria.serviceDate);
						}
					}
					//sort through criteria with multiple coverages
					else if(criteria.memCov.size() > 1){
						//if a criteria has multiple coverages, but all have the same member profile id, check to see if plans are different.  If so, create a new criteria, other wise, it goes to the not found list 

						System.debug('criteria memCovs size ' + criteria.memCov.size());
						
						//check to see if all member coverages have the same 
						Set<String> uniqueIdentifierSet = new Set<String>();
						for(mock_MemberCoverage__c memCov : criteria.memCov){
							uniqueIdentifierSet.add(memCov.SubscriberID__c.toLowerCase() + memCov.FirstName__c.toLowerCase() + memCov.LastName__c.toLowerCase() + memCov.Birthdate__c);
						}	

						//if multiple profile guids, multiple members found, move to not found list
						if(uniqueIdentifierSet.size() > 1){
							criteria.errorMessage = System.label.Not_Found_Multiple_Members;
							notFoundList.add(criteria);
						} else {
							//need create a criteria row for each different plan
							//check against the dates again to make to make sure its eligible
							//check the plan to make check if out of network
							Map<String,mock_MemberCoverage__c> planGuid2MemCovMap = new Map<String, mock_MemberCoverage__c>();
							for(integer i=0; i<criteria.memCov.size(); i++){
								mock_MemberCoverage__c memCov = criteria.memCov.get(i);
								
								//keep the original criteria for the first line
								if(i == 0){
									
									criteria = updateCriteria(criteria, memCov, serviceLocationId, providerId);
									System.debug('updated criteria::'+criteria);
									plansWithCriteriaCreated.add(memCov.PlanGUID__c.tolowercase());
									System.debug('plansWithCriteriaCreated::'+plansWithCriteriaCreated);
									if(criteria.status == 'E'){
										eligibleDates.add(criteria.serviceDate);
									}

									
								} else {
									//create a new criteria for additonal member coverages
									if(!plansWithCriteriaCreated.contains(memCov.PlanGUID__c.tolowercase())){
										//new plan is being added
										plansWithCriteriaCreated.add(memCov.PlanGUID__c.tolowercase());

										Prov_ctrl_MemberEligibility.MemberWrapper tempCriteria = new Prov_ctrl_MemberEligibility.MemberWrapper(criteria.serviceDate,  memCov.Birthdate__c, memCov.SubscriberId__c, memCov.FirstName__c, memCov.LastName__c, null);
										tempCriteria.index = criteria.index;
										tempCriteria.memCov.add(memCov);
										tempCriteria = updateCriteria(tempCriteria, memCov, serviceLocationId, providerId);
										system.debug('tempCriteria ' + tempCriteria);
										if(tempCriteria.status == 'E'){
											eligibleDates.add(tempCriteria.serviceDate);
										}
										additionalCriteriaList.add(tempCriteria);
									} 
									//else {
										//see if the new mem coverage is a better fit for the criteria
										//criteria = updateCriteria(criteria, memCov, serviceLocationId, providerId);
									//}
								}
							}
						}
					}
				}
				criteriaList.addAll(additionalCriteriaList);

				//use eligibleDates set to get plans for provider
				for(Date d : eligibleDates){
					dateToPlansMap.put(d, new Set<String>(prov_util_cache.getPlanGuidsBasedOnBusProvSL(businessId, providerId, serviceLocationId, d)));
				}
				System.debug('dates and plans: ' + dateToPlansMap);

				//RUN FINAL check on eligible list to make sure that service date and PSL support the given plan
				for(integer i=eligibleList.size()-1 ; i>=0; i--){

					Prov_ctrl_MemberEligibility.MemberWrapper temp = eligibleList.get(i);
					if(!dateToPlansMap.get(temp.serviceDate).contains(temp.planGUID.toLowercase())){
						outOfNetworkList.add(temp);
						eligibleList.remove(i);
					}
				}

			} else {
				Map<String, List<Prov_ctrl_MemberEligibility.MemberWrapper>> timeOutMap = new Map<String, List<Prov_ctrl_MemberEligibility.MemberWrapper>>();
				timeOutMap.put('timeout', new List<Prov_ctrl_MemberEligibility.MemberWrapper>());
				return timeOutMap;
			}
		} else {
			//put everything in not found
			notFoundList.addAll(criteriaList);
		}

		//loop through eligible, ineligible, and out of network and update Name and Numbers
		for(Prov_ctrl_MemberEligibility.MemberWrapper wrap : eligibleList){
			wrap.memberNumber = wrap.tempMemberNumber;
			wrap.firstName = wrap.tempMemberFirstName;
			wrap.lastName = wrap.tempMemberLastName;
		}
		for(Prov_ctrl_MemberEligibility.MemberWrapper wrap : ineligibleList){
			wrap.memberNumber = wrap.tempMemberNumber;
			wrap.firstName = wrap.tempMemberFirstName;
			wrap.lastName = wrap.tempMemberLastName;
		}
		for(Prov_ctrl_MemberEligibility.MemberWrapper wrap : outOfNetworkList){
			wrap.memberNumber = wrap.tempMemberNumber;
			wrap.firstName = wrap.tempMemberFirstName;
			wrap.lastName = wrap.tempMemberLastName;
		}



		//build map to return to javascript helper
		Map<String, List<Prov_ctrl_MemberEligibility.MemberWrapper>> results = new Map<String, List<Prov_ctrl_MemberEligibility.MemberWrapper>>();
			results.put('eligible', eligibleList);
			results.put('ineligible', ineligibleList);
			results.put('notFound', notFoundList);
			results.put('outOfNetwork', outOfNetworkList);

        return results;
	}

	public static Prov_ctrl_MemberEligibility.MemberWrapper updateCriteria(Prov_ctrl_MemberEligibility.MemberWrapper crit, mock_MemberCoverage__c mc, String serviceLocationId, String providerId){
		//Copy field information from member coverage record
		//compare criteria termdate to mc termdate,  need to do price is right rule
		if(((crit.tempMemberNumber != null && crit.tempMemberNumber != mc.SubscriberID__c) || 
				(crit.tempMemberFirstName != null && crit.tempMemberFirstName != mc.FirstName__c) || 
				(crit.tempMemberLastName != null && crit.tempMemberLastName != mc.LastName__c) ) && crit.status == 'I'){
				System.debug('multiple members found is true');
				crit.status = 'MM';//multiple members returned
		}else if(crit.status == 'E' || crit.termDate == null || (crit.termDate >= crit.serviceDate && mc.TerminationDate__c <= crit.serviceDate) ){
			System.debug('member coverage record is gettting updated...');
			System.debug('member coverage new record::'+mc);
			System.debug('old member coverage record::'+crit.termDate);
			crit.tempMemberNumber = mc.SubscriberID__c;
			crit.tempMemberFirstName = mc.FirstName__c;
			crit.tempMemberLastName = mc.LastName__c;
			crit.memberProfileGuid = mc.MemberProfileGUID__c;
			crit.UniversalMemberGUID = mc.UniversalMemberGUID__c;
			crit.subscriberProfileGuid = mc.SubscriberProfileGUID__c;
			crit.planType = mc.PlanName__c;
			crit.planGUID = mc.PlanGuid__c;
			crit.termDate = mc.TerminationDate__c;

			//set the service location and provider winward IDs.  These values are passed to the method
			crit.serviceLocationId = serviceLocationId;
			crit.providerId = providerId;
		
			//add either provider Name or Service location name to crit record
			if(acctMap != null && acctMap.size() > 0){

				if(mc.ProviderGUID__c != null){
					crit.pcd = acctMap.get(mc.ProviderGUID__c.toLowerCase()).name;
					crit.pcdid = acctMap.get(mc.ProviderGUID__c.toLowerCase()).Id;
				} else if(mc.ServiceLocationGUID__c != null){
					crit.pcd = acctMap.get(mc.ServiceLocationGUID__c.toLowerCase()).name;
					crit.pcdid = acctMap.get(mc.ServiceLocationGUID__c.toLowerCase()).Id;
				}
				crit.planType = acctMap.get(crit.planGuid.toLowercase()).Name;
			}
				
			if(crit.status != 'I'){	
				if(availableBusinessPlans.contains(mc.PlanGuid__c.toLowercase())){
					if((crit.serviceDate <= mc.TerminationDate__c || mc.TerminationDate__c == null) && mc.EffectiveDate__c <= crit.serviceDate){
						//add to eligible list
						crit.status = 'E';				
						eligibleList.add(crit);
					}
				} else {
					//add to out of network list
					crit.status = 'O';
					outOfNetworkList.add(crit);
				}
			}
		}
	
		return crit;
	}





	/***********************
	*	This is the method for when the Save Search button is clicked.
		This method does the following:
			Creates a Search Criteria object that holds Business, Location, Provider and Title
			Creates a Search Criteria Item for each member search entry in table

	************************/
	@AuraEnabled
	public static Id saveMemberSearch(String searchId, String name, String criteriaStr, Id businessId, Id serviceLocationId, Id  providerId, String routeId){
		System.debug('in save search');
		System.debug('criteriaStr ' + criteriaStr);
		System.debug('businessId ' + businessId);
		System.debug('serviceLocationId ' + serviceLocationId);
		System.debug('providerId ' + providerId);

		//deserialize the criteria passed in to the MemberWrapper
		List<Prov_ctrl_MemberEligibility.MemberWrapper> criteriaList = (List<Prov_ctrl_MemberEligibility.MemberWrapper>)JSON.deserialize(criteriaStr, List<Prov_ctrl_MemberEligibility.MemberWrapper>.class);
		System.debug('criteriaList ' + criteriaList);

		//use serviceLocationId and ProviderId to search for PSL id
		List<Providers_Service_Locations__c> pslList = [select id from Providers_Service_Locations__c where Service_Location__c = :serviceLocationId and Provider__c = :providerId];
		system.debug('psl list: ' + pslList);

		//create search criteria record
		Search_Criteria__c sc = new Search_Criteria__c();
		Map<Id, Search_Criteria_Item__c> id2sciMap = new Map<Id, Search_Criteria_Item__c>();
		Set<Id> searchCriteriaItemIds = new Set<Id>();
		
		if(searchId  != ''){
			sc.id = searchId;
			
			id2sciMap = new Map<Id, Search_Criteria_Item__c> ([SELECT id FROM Search_Criteria_Item__c WHERE Search_Criteria__c =:sc.id]);
			searchCriteriaItemIds= id2sciMap.keyset();
			id2sciMap = null;
		}
		sc.name = name;
		sc.Business__c = businessId;
		sc.Provider_Service_Location__c = pslList.get(0).id;
		sc.Portal_Name__c = prov_util_Cache.ConfigurationName;
		sc.RouteId__c = routeId;
		sc.Created_By_Contact__c = prov_util_Cache.cobj.ContactRec.id;
		upsert sc;
		System.debug('Search criteria record: ' + sc);

		//create a search criteria item record for each member entered
		List<Search_Criteria_Item__c> scItemsList = new List<Search_Criteria_Item__c>();
		for(Prov_ctrl_MemberEligibility.MemberWrapper criteria : criteriaList){
			Search_Criteria_Item__c sci = new Search_Criteria_Item__c();
			sci.Search_Criteria__c = sc.id;
			sci.Service_Date__c = criteria.serviceDate;
			sci.Birthdate__c = criteria.birthDate;
			sci.Member_First_Name__c = criteria.firstName;
			sci.Member_Last_Name__c = criteria.lastName;
			sci.Subscriber_Id__c = criteria.memberNumber;
			if(criteria.searchCriteriaId != ''){
				sci.id = criteria.searchCriteriaId;
				searchCriteriaItemIds.remove(criteria.searchCriteriaId);
			}

			scItemsList.add(sci);
		}
		System.debug('criteria items: ' + scItemsList);

		if(scItemsList.size() > 0){
			upsert scItemsList;
		}

		//check if any search criterias were not found on the page but in the db. delete them
		if(searchCriteriaItemIds.size() > 0){
			//initialize list to hold delete items
			List<Search_Criteria_Item__c> sciDeleteList = new List<Search_Criteria_Item__c>();
			
			//loop through ids and make records for them
			for(Id sciId : searchCriteriaItemIds){
				sciDeleteList.add( new Search_Criteria_Item__c(id=sciId) );
			}
			
			//delete the records
			delete sciDeleteList;
		}
		return sc.id;
	}

	//this method gets the saved search criteria and returns it to the page
	@AuraEnabled
	public static SavedSearchWrapper loadSearchCriteria(String searchCriteriaId){
		SavedSearchWrapper ssWrapper = new SavedSearchWrapper();

		//query for Search Criteria record
		Search_Criteria__c sc = [Select id, name, Created_By_Contact__c, Provider_Service_Location__r.Provider__c, Provider_Service_Location__r.Service_Location__c, Business__c from Search_Criteria__c where id = :searchCriteriaId];
		//query for Search Criteria List records
		List<Search_Criteria_Item__c> scList = [Select id, Member_First_Name__c, Member_Last_Name__c, Subscriber_Id__c, Service_Date__c, Birthdate__c from Search_Criteria_Item__c where Search_Criteria__c = :searchCriteriaId];
		System.debug('sc: ' + sc);
		System.debug('scList: ' + scList);

		List<Prov_ctrl_MemberEligibility.MemberWrapper> memberList = new List<Prov_ctrl_MemberEligibility.MemberWrapper>();
		//create memberWrappers from results
		for(Search_Criteria_Item__c sci : scList){
			memberList.add(new MemberWrapper(sci.Service_Date__c, sci.Birthdate__c, sci.Subscriber_Id__c, sci.Member_First_Name__c, sci.Member_Last_Name__c, sci.id));
		}
		System.debug('memberList: '+ memberList);

		Set<String> accountIds = new Set<String>();
		accountIds.add(sc.Provider_Service_Location__r.Provider__c);
		accountIds.add(sc.Provider_Service_Location__r.Service_Location__c);

		Map<String, Account> accountMap = prov_util_DAL.getAccountSFMap(accountIds);

		//populate wrapper
		ssWrapper.memberList = memberList;
		ssWrapper.title = sc.name;
		ssWrapper.business = sc.Business__c;
		ssWrapper.provider = accountMap.get(sc.Provider_Service_Location__r.Provider__c);
		ssWrapper.serviceLocation = accountMap.get(sc.Provider_Service_Location__r.Service_Location__c);
		ssWrapper.owner = sc.Created_By_Contact__c;
		System.debug('ssWrapper: ' + ssWrapper);

		return ssWrapper;
	}

    //Wrapper class for member eligibility info coming from Member Eligibility Search page
	public class MemberWrapper{
		@AuraEnabled public String index {get; set;}
		@AuraEnabled public Date serviceDate {get; set;}
		@AuraEnabled public Date birthDate {get; set;}
		@AuraEnabled public String memberNumber {get; set;}
		@AuraEnabled public String firstName {get; set;}
		@AuraEnabled public String lastName {get; set;}
		@AuraEnabled public String planType {get; set;}
		@AuraEnabled public String pcd {get; set;}
		@AuraEnabled public String memberProfileGuid {get; set;}
		@AuraEnabled public String UniversalMemberGUID {get; set;}
		@AuraEnabled public String providerId {get; set;}
		@AuraEnabled public String serviceLocationId {get; set;}
		@AuraEnabled public String searchCriteriaId {get; set;}
		@AuraEnabled public String errorMessage {get; set;}
		@AuraEnabled
		public String status {get{
			if(status == null){
				status = 'NF';
			}
			return status;
		} set;}  //possible statuses are {E, I, NF, O}  Eligible, Inelligbile, Not Found, Out of Network 

		@AuraEnabled
		public List<mock_MemberCoverage__c> memCov{get{
			if(memCov == null){
				memCov = new List<mock_MemberCoverage__c>();
			}
			return memCov;
		} set;}

		@AuraEnabled public String claim {get;set;}
		@AuraEnabled public String planGUID {get;set;}		
		@AuraEnabled public String pcdid {get;set;}
		@AuraEnabled public Date termDate {get; set;}
		@AuraEnabled public String subscriberProfileGuid {get; set;}
		@AuraEnabled public Boolean timeout {get; set;}


		public String tempMemberNumber {get; set;}
		public String tempMemberFirstName {get; set;}
		public String tempMemberLastName {get; set;}


		public MemberWrapper(Date serviceDate,  Date birthDate, String memberNumber, String firstName, String lastName, String searchCriteriaId){
			this.serviceDate = serviceDate;
			this.birthDate = birthDate;
			this.memberNumber = memberNumber;
			this.firstName = firstName;
			this.lastName = lastName;
			this.searchCriteriaId = searchCriteriaId;
			status = 'NF';
		}

		public MemberWrapper(Boolean timeout){
			this.timeout = timeout;
		}
	}

	//wrapper for holding the saved search results
	public class SavedSearchWrapper{
		@AuraEnabled
		public List<Prov_ctrl_MemberEligibility.MemberWrapper> memberList {get; set;}
		@AuraEnabled
		public String title {get; set;}
		@AuraEnabled
		public String business {get; set;}
		@AuraEnabled
		public Account serviceLocation {get; set;}
		@AuraEnabled
		public Account provider {get; set;}
		@AuraEnabled
		public String owner {get; set;}
	}

	public class SearchWrapper{
		public String business;
		public String serviceLocation;
		public String provider;
		public String routeId;
		public String index;
		public List<Prov_ctrl_MemberEligibility.MemberWrapper> memberList;
		public Prov_ctrl_MemberEligibility.MemberWrapper member;


	}
}