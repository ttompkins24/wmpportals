/**********************************************************************************************************************
Name                        : prov_util_Search_Tests
Purpose                     : Test class utilities for provider portal search pages
Created on                  : June 2018
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                            By                      Comments
1.0             9           June 2018                West Monroe Partners    See header - purpose
 
**********************************************************************************************************************/
public without sharing class prov_util_Search_Tests {
	// GENERAL UTILITY METHODS FOR CREATING TEST SHELLS/RECORDS
	public static Claim__c util_generateTestShell(String claimType, Id businessId, String claimNumber) {
		Claim__c testClaim = new Claim__c();

		testClaim.Patient_First_Name__c = 'Daily';
		testClaim.Patient_Last_Name__c = 'Planet';
		testClaim.Service_Date__c = Date.today();
		testClaim.Treating_Provider_Address1__c = '123 Main Street';
		testClaim.Treating_Provider_Address2__c = 'Apt DNE';
		testClaim.Treating_Provider_City__c = 'Anytown';
		testClaim.Treating_Provider_First_Name__c = 'Clark';
		testClaim.Treating_Provider_Last_Name__c = 'Kent';
		testClaim.Claim_Number__c = claimNumber;
		testClaim.Claim_Type__c = claimType;
		testClaim.Claim_Draft_Status__c = 'Draft';
		testClaim.Business__c = businessId;
		if(claimType == 'REFERRAL') {
			testClaim.Remarks2__c = 'test';
		}

		return testClaim;
	}

	public static Claim_Service_Line__c util_generateTestServiceLine(Id claimId, Id procedureCodeId) {
		Claim_Service_Line__c testServiceLine = new Claim_Service_Line__c();

		testServiceLine.Claim__c = claimId;
		testServiceLine.Quantity__c = 2;
		testServiceLine.Service_Date__c = Date.today();
		testServiceLine.Billed_Amount__c = 12;
		testServiceLine.Procedure_Code_Lookup__c = procedureCodeId;
		testServiceLine.Procedure_Code__c  = '123';

		return testServiceLine;
	}

	public static Procedure_Code__c util_generateTestProcedureCode() {
		Procedure_Code__c testProcedureCode = new Procedure_Code__c();

		testProcedureCode.Class_Code__c = 'Orthodontics';
		testProcedureCode.Description__c = 'test description';
		testProcedureCode.Is_Arch_Required__c = false;
		testProcedureCode.Is_Quad_Required__c = false;
		testProcedureCode.Is_Surface_Required__c = false;
		testProcedureCode.Is_Tooth_Required__c = false;
		testProcedureCode.RouteId__c = 'GOV';
		testProcedureCode.External_Id__c = 'D8020';

		return testProcedureCode;
	}	

	public static COB_Payer_Claim__c util_generateTestCOBPayerClaim(Id claimId) {
		COB_Payer_Claim__c testCOBPayer = new COB_Payer_Claim__c();

		testCOBPayer.Claim__c = claimId;
		testCOBPayer.Subscriber_Birth_Date__c = Date.today().addDays(-1);
		testCOBPayer.Payer_Name__c = 'Placeholder';
		testCOBPayer.Group_ID__c = '12345';
		testCOBPayer.Subscriber_First_Name__c = 'Test';
		testCOBPayer.Subscriber_Last_Name__c = 'Testerson';

		return testCOBPayer;
	}	

	public static COB_Payer_Detail__c util_generateTestCOBPayerDetail(Id claimServiceLineId, Id cobPayerClaimId) {
		COB_Payer_Detail__c testCOBPayerDetail = new COB_Payer_Detail__c();

		testCOBPayerDetail.Claim_Service_Line__c = claimServiceLineId;
		testCOBPayerDetail.COB_Payer_Claim__c = cobPayerClaimId;
		testCOBPayerDetail.Paid_Amount__c = 100;

		return testCOBPayerDetail;
	}	
	// END GENERAL UTILITY METHODS

	// CLAIM SPECIFIC UTILITY METHODS
	public static prov_Wrap_Claim.ClaimHeaderRequestWrapper util_generateClaimHeader(String methodName) {
		prov_Wrap_Claim.ClaimHeaderRequestWrapper claimHeader = new prov_Wrap_Claim.ClaimHeaderRequestWrapper();
		Date currentDate = Date.today();

		claimHeader.StatusCategory = 'All';

		if(methodName == 'whereClause') {
			claimHeader.DateOfServiceStart = currentDate;
			claimHeader.DateOfServiceEnd = currentDate.addDays(5);
			claimHeader.MemberFirstName = 'Placeholder';
			claimHeader.MemberLastName = 'Placeholder';
			claimHeader.MemBirthDate = currentDate;
			claimHeader.ReceivedDateStart = currentDate;
			claimHeader.ReceivedDateEnd = currentDate;
			claimHeader.ServiceOfficeGuids = 'Placeholder; Placeholder2';
			claimHeader.TreatingDentistGuids = 'Placeholder';
			claimHeader.ClaimNumber = 'Placeholder';
			claimHeader.MemberId = 'Placeholder';
		}
		return claimHeader;
	}

	public static prov_wrap_Claim.ClaimHeaderResponseWrapper util_generateTestClaimHeaderResponseWrapper(String claimNumber) {
		prov_wrap_Claim.ClaimHeaderResponseWrapper testClaimHeaderResponseWrapper = new prov_wrap_Claim.ClaimHeaderResponseWrapper();

		testClaimHeaderResponseWrapper.ClaimNumber = claimNumber;
		
		return testClaimHeaderResponseWrapper;
	}
	// END CLAIM SPECIFIC UTILITY METHODS

	// REFERRAL SPECIFIC UTILITY METHODS
	public static prov_Wrap_Claim.ReferralHeaderRequestWrapper util_generateReferralHeader(String methodName) {
		prov_Wrap_Claim.ReferralHeaderRequestWrapper referralHeader = new prov_Wrap_Claim.ReferralHeaderRequestWrapper();
		Date currentDate = Date.today();

		referralHeader.RequestStatus = 'All';

		if(methodName == 'whereClause') {
			referralHeader.SubmittedDateStart = currentDate;
			referralHeader.SubmittedDateEnd = currentDate.addDays(5);
			referralHeader.MemberFirstName = 'Placeholder';
			referralHeader.MemberLastName = 'Placeholder';
			referralHeader.MemberDateOfBirth = currentDate;
			referralHeader.ServiceOfficeGuids = 'Placeholder; Placeholder2';
			referralHeader.SubmittingDentistGuids = 'Placeholder';
			referralHeader.ReferralNumber = 'Placeholder';
			referralHeader.MemberId = 'Placeholder';
			referralHeader.RequestedSpecialty = 'Placeholder';
		}
		return referralHeader;
	}

	public static prov_wrap_Claim.ReferralHeaderResponseWrapper util_generateTestReferralHeaderResponseWrapper(String claimNumber) {
		prov_wrap_Claim.ReferralHeaderResponseWrapper testReferralHeaderResponseWrapper = new prov_wrap_Claim.ReferralHeaderResponseWrapper();

		testReferralHeaderResponseWrapper.ClaimNumber = claimNumber;
		
		return testReferralHeaderResponseWrapper;
	}
	// END REFERRAL SPECIFIC UTILITY METHODS

	// FEE SCHEDULE SPECIFIC UTILITY METHODS
	public static prov_wrap_FeeSchedule.FeeScheduleRequestWrapper util_generatefeeScheduleHeader() {
		prov_wrap_FeeSchedule.FeeScheduleRequestWrapper testFeeScheduleHeader = new prov_wrap_FeeSchedule.FeeScheduleRequestWrapper();
		Date currentDate = Date.today();

		testFeeScheduleHeader.NetworkGuid = 'Placeholder';
		testFeeScheduleHeader.ServiceDate = currentDate;
		testFeeScheduleHeader.RouteId = 'Placeholder';
		testFeeScheduleHeader.BusinessGuid = 'Placeholder';
		testFeeScheduleHeader.ProviderGuid = 'Placeholder';
		testFeeScheduleHeader.ServiceOfficeGuid = 'Placeholder';
		testFeeScheduleHeader.NetworkStatus = 'Placeholder';
		testFeeScheduleHeader.CoverageType = 'Placeholder';
		testFeeScheduleHeader.ProviderOfficeType = 'Placeholder';
		testFeeScheduleHeader.ProviderSpecialty = 'Placeholder';
		testFeeScheduleHeader.IsSpecialDeal = false;

		return testFeeScheduleHeader;
	}

	public static List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper> util_generateFeeScheduleResponses() {
		List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper> testFeeSchedules = new List<prov_wrap_FeeSchedule.FeeScheduleResponseWrapper>();
		prov_wrap_FeeSchedule.FeeScheduleResponseWrapper tempFeeScheduleWrapper = new prov_wrap_FeeSchedule.FeeScheduleResponseWrapper();
		Date currentDate = Date.today();

		for(Integer i=0; i<5; i++) {
			tempFeeScheduleWrapper.ProcedureCode = 'Placeholder' + String.valueOf(i);
			tempFeeScheduleWrapper.ProcedureDescription = 'Placeholder';
			tempFeeScheduleWrapper.SpecialDeal = false;
			tempFeeScheduleWrapper.Network = false;
			tempFeeScheduleWrapper.DollarAmount = 100.50;
			tempFeeScheduleWrapper.ToothCode = 'Placeholder';
			tempFeeScheduleWrapper.ZipCode = 'Placeholder';
			tempFeeScheduleWrapper.MinimumAge = 12;
			tempFeeScheduleWrapper.MaximumAge = 55;
			tempFeeScheduleWrapper.EffectiveDate = currentDate;
			tempFeeScheduleWrapper.TerminationDate = currentDate;
			testFeeSchedules.add(tempFeeScheduleWrapper);
		}
		return testFeeSchedules;
	}
	// END FEE SCHEDULE SPECIFIC UTILITY METHODS

	// EOB SPECIFIC UTILITY METHODS
	public static prov_wrap_EOB.EOBHeaderResultWrapper util_generateEOBResponses() {
		prov_wrap_EOB.EOBHeaderResultWrapper eobResultWrapper = new prov_wrap_EOB.EOBHeaderResultWrapper();
		prov_wrap_EOB.EOBHeaderResponseWrapper eobResponseWrapper = new prov_wrap_EOB.EOBHeaderResponseWrapper();
		Date currentDate = Date.today();

		eobResultWrapper.Total = 100;
		eobResultWrapper.PageNumber = 1;
		eobResultWrapper.PageSize = 10;
		eobResultWrapper.TotalPages = 10;
		eobResultWrapper.Eobs = new List<prov_wrap_EOB.EOBHeaderResponseWrapper>();

		for(Integer i=0; i<5; i++) {
			eobResponseWrapper.EobId = 'Placeholder' + String.valueOf(i);
			eobResponseWrapper.CheckOrEftNumber = 'Placeholder';
			eobResponseWrapper.PayerName = 'Placeholder';
			eobResponseWrapper.PayeeName = 'Placeholder';
			eobResponseWrapper.PayeeAddress1 = 'Placeholder';
			eobResponseWrapper.PayeeAddress2 = 'Placeholder';
			eobResponseWrapper.PayeeCity = 'Placeholder';
			eobResponseWrapper.PayeeState = 'Placeholder';
			eobResponseWrapper.PayeeZip = 'Placeholder';
			eobResponseWrapper.CheckOrEftReleaseDate = currentDate;
			eobResponseWrapper.PaymentType = 'Placeholder';
			eobResponseWrapper.PaymentAmount = 100.50;
			eobResponseWrapper.BusinessGuid = 'Placeholder';
			eobResponseWrapper.ServiceOfficeGuid = 'Placeholder';
			eobResponseWrapper.ProviderGuid = 'Placeholder';
			eobResponseWrapper.ClientPaymentRunIds = 'Placeholder';
			eobResponseWrapper.IssuedDate = currentDate;
			eobResponseWrapper.RouteId = 'Placeholder';
			eobResponseWrapper.Reconciled = false;
			eobResponseWrapper.EobLink = 'Placeholder';
			eobResultWrapper.Eobs.add(eobResponseWrapper);
		}
		return eobResultWrapper;
	}
	// END EOB SPECIFIC UTILITY METHODS
}