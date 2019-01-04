public with sharing class prov_wrap_Claim {
    // wrapper for callout request for claim search
	public class ClaimHeaderRequestWrapper{
		@AuraEnabled
		public String BusinessGuid {get;set;}
        @AuraEnabled
		public String ClaimType {get;set;}
		@AuraEnabled
		public Date DateOfServiceStart {get;set;}
		@AuraEnabled
		public Date DateOfServiceEnd {get;set;}
		@AuraEnabled
		public String StatusCategory {get;
            set {
                StatusCategory = value;
                if(value == 'Submitted') {
                    StatusCategory = 'Accepted';
                }
            }
        }
		@AuraEnabled
        public String MemberFirstName {get; set;}
        @AuraEnabled
        public String MemberLastName {get; set;}
        @AuraEnabled
        public Date MemBirthDate {get;set;}
        @AuraEnabled
		public String MemberId {get;set;}
        @AuraEnabled
        public String MemberProfileGuid {get;set;}
        @AuraEnabled
        public String UniversalMemberGuid {get;set;}
        @AuraEnabled
        public String ServiceOfficeGuids {get;set;}
        @AuraEnabled
        public String TreatingDentistGuids {get;set;}
        @AuraEnabled
        public String ClaimNumber {get;set;}
        @AuraEnabled
        public Date ReceivedDateStart {get;set;}
        @AuraEnabled
        public Date ReceivedDateEnd {get;set;}
        @AuraEnabled
        public String OrderBy {get;set;}
        @AuraEnabled
        public String OrderDirection {get;set;}
	}

    // overall result wrapper for claim header callout
    public class ClaimHeaderResultWrapper{
        @AuraEnabled
        public List<ClaimHeaderResponseWrapper> SearchResult {get;set;}
        @AuraEnabled
        public Integer TotalCount {get;set;}
        @AuraEnabled
        public String QueryTotalTimeMs {get;set;}
    }

    // wrapper for individual claim search results from header callout
	public class ClaimHeaderResponseWrapper{
		@AuraEnabled
		public String BusinessGuid {get;set;}
		@AuraEnabled
		public String ClaimNumber {get;set;}
		@AuraEnabled
		public String StatusCategory {get;
            set {
                StatusCategory = value;
                if(value == 'Accepted') {
                    StatusCategory = 'Submitted';
                }
            }
        }
		@AuraEnabled
		public String ClaimType {get;set;}
		@AuraEnabled
		public String MemberFirstName {get;set;}
		@AuraEnabled
		public String MemberLastName {get;set;}
        @AuraEnabled
        public String MemberId {get;set;}        
        @AuraEnabled
        public String UniversalMemberGuid {get;set;}        
        @AuraEnabled
        public String PlanGuid {get;set;}        
        @AuraEnabled
		public String PlanName {get;set;}
		@AuraEnabled
		public String TreatingDentistFirstName {get;set;}
		@AuraEnabled
		public String TreatingDentistLastName {get;set;}
		@AuraEnabled
		public String ServiceOfficeAddress1 {get;set;}
		@AuraEnabled
		public String ServiceOfficeAddress2 {get;set;}
		@AuraEnabled
		public String ServiceOfficeCity {get;set;}
		@AuraEnabled
        public DateTime ReceivedDate {get;
			set{
				if(value != null) {
					ReceivedDate = DateTime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT());
				}
			}
		}
		@AuraEnabled
        public DateTime ServiceDate {get;
			set{
				if(value != null) {
					ServiceDate = DateTime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT());
				}
			}
		}
		@AuraEnabled
		public Decimal BilledAmount {get;set;}
		@AuraEnabled
		public Decimal PaidAmount {get;set;}
        @AuraEnabled
        public String DetailRedirectId {
            get {
                if(SalesforceId != null) {
                    return SalesforceId;
                }
                return ClaimNumber;
            }
            set;
        }
        @AuraEnabled
        public String SalesforceId {get;set;}
	}

    // wrapper for callout request for referral search
	public class ReferralHeaderRequestWrapper{
		@AuraEnabled
		public String BusinessGuid {get;set;}
		@AuraEnabled
		public String RequestStatus {get;
            set {
                RequestStatus = value;
                if(value == 'Submitted') {
                    RequestStatus = 'Accepted';
                }
            }
        }
        @AuraEnabled
        public String RequestedSpecialty {get;set;}
		@AuraEnabled
        public String MemberFirstName {get; set;}
        @AuraEnabled
        public String MemberLastName {get; set;}
        @AuraEnabled
        public Date MemberDateOfBirth {get;set;}
        @AuraEnabled
		public String MemberId {get;set;}
        @AuraEnabled
        public String MemberProfileGuid {get;set;}
        @AuraEnabled
        public String ServiceOfficeGuids {get;set;}
        @AuraEnabled
        public String SubmittingDentistGuids {get;set;}
        @AuraEnabled
        public String ReferralNumber {get;set;}
        @AuraEnabled
        public Date SubmittedDateStart {get;set;}
        @AuraEnabled
        public Date SubmittedDateEnd {get;set;}
        @AuraEnabled
        public String OrderBy {get;set;}
        @AuraEnabled
        public String OrderDirection {get;set;}
	}

    // overall result wrapper for referral header callout
    public class ReferralHeaderResultWrapper{
        @AuraEnabled
        public List<ReferralHeaderResponseWrapper> SearchResult {get;set;}
        @AuraEnabled
        public Integer TotalCount {get;set;}
        @AuraEnabled
        public String QueryTotalTimeMs {get;set;}
    }

    // wrapper for individual referral search results from header callout
	public class ReferralHeaderResponseWrapper{
		@AuraEnabled
		public String BusinessGuid {get;set;}
		@AuraEnabled
		public String ClaimNumber {get;set;}
		@AuraEnabled
		public String Status {get;
            set {
                Status = value;
                if(value == 'Accepted') {
                    Status = 'Submitted';
                }
            }
        }
		@AuraEnabled
		public String ClaimType {get;set;}
		@AuraEnabled
		public String MemberFirstName {get;set;}
		@AuraEnabled
		public String MemberLastName {get;set;}
        @AuraEnabled
		public String MemberId {get;set;}
		@AuraEnabled
		public String SubmittingProviderFirstName {get;set;}
		@AuraEnabled
		public String SubmittingProviderLastName {get;set;}
		@AuraEnabled
		public String SubmittingProviderAddressLine1 {get;set;}
		@AuraEnabled
		public String SubmittingProviderAddressLine2 {get;set;}
		@AuraEnabled
		public String SubmittingProviderCity {get;set;}
		@AuraEnabled
		public String ReferringProviderFirstName {get;set;}
		@AuraEnabled
		public String ReferringProviderLastName {get;set;}
        @AuraEnabled
		public String ReferralType {get;set;}
        @AuraEnabled
		public String SpecialtyType {get;set;}
		@AuraEnabled
        public DateTime SubmittedDate {get;
			set{
				if(value != null) {
					SubmittedDate = DateTime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT());
				}
			}
		}
        @AuraEnabled
        public String DetailRedirectId {
            get {
                if(SalesforceId != null) {
                    return SalesforceId;
                }
                return ClaimNumber;
            }
            set;
        }
        @AuraEnabled
        public String SalesforceId {get;set;}
	}

	public class ClaimDetailRequestWrapper{
		@AuraEnabled
		public String BusinessId {get;set;}
		@AuraEnabled
		public String ClaimNumber {get;set;}
        @AuraEnabled
        public String BusinessGuid {get;set;}

	}
	
	public class ReferralDetailRequestWrapper{
		@AuraEnabled
		public String ClaimNumber {get;set;}
        @AuraEnabled
        public String BusinessGuid {get;set;}

	}

    public class ClaimDetailResultWrapper{



        @AuraEnabled
        public ClaimDetailResultClaimWrapper Claim {get;set;}
        //@AuraEnabled
        //public String QueryTotalTimeMs {get;set;}
    }
    public class ReferralDetailResultWrapper{



        @AuraEnabled
        public ReferralDetailResultClaimWrapper Claim {get;set;}
        //@AuraEnabled
        //public String QueryTotalTimeMs {get;set;}
    }


    public class ClaimDetailResultClaimWrapper{
        public ClaimDetailResultClaimWrapper(){
            Header = new ClaimDetailResponseWrapper();
            Lines = new List<ClaimDetailServiceLineWrapper>();
            CobInfo = new List<ClaimDetailCOBPayerClaimWrapper>();
            Referral = new ClaimDetailReferralWrapper();
        }

        @AuraEnabled
        public ClaimDetailResponseWrapper Header {get;set;}
        @AuraEnabled
        public List<ClaimDetailServiceLineWrapper> Lines {get;set;}
        @AuraEnabled
        public List<ClaimDetailCOBPayerClaimWrapper> CobInfo {get;set;}
        @AuraEnabled
        public ClaimDetailReferralWrapper Referral {get;set;}
    }
    public class ReferralDetailResultClaimWrapper{
        public ReferralDetailResultClaimWrapper(){
            Header = new ReferralDetailResponseWrapper();
            Lines = new List<ClaimDetailServiceLineWrapper>();
            CobInfo = new List<ClaimDetailCOBPayerClaimWrapper>();
            Referral = new ReferralDetailReferralWrapper();
        }

        @AuraEnabled
        public ReferralDetailResponseWrapper Header {get;set;}
        @AuraEnabled
        public List<ClaimDetailServiceLineWrapper> Lines {get;set;}
        @AuraEnabled
        public List<ClaimDetailCOBPayerClaimWrapper> CobInfo {get;set;}
        @AuraEnabled
        public ReferralDetailReferralWrapper Referral {get;set;}
        @AuraEnabled
        public String QueryTotalTimeMs {get;set;}
    }


	public class ReferralDetailResponseWrapper{
        public ReferralDetailResponseWrapper() {

            Attachments = new List<ClaimDetailResponseAttachWrapper>();
            ProcessingPolicies = new List<ClaimDetailResponsePoliciesWrapper>(); 
        }

        @AuraEnabled
        public String ReasonForDenial {get;set;}
        @AuraEnabled
        public String TreatingProviderGuid {get;set;}
        @AuraEnabled
        public String ServiceOfficeGuid {get;set;}

        @AuraEnabled
        public String ClaimId {get;set;}
		@AuraEnabled
		public String ClaimNumber {get;set;}
        @AuraEnabled
        public String ClaimTypeCategory {get;set;}

        @AuraEnabled
        public String StatusCategory {get;
            set {
                StatusCategory = value;
                if(value == 'Accepted') {
                    StatusCategory = 'Submitted';
                }
            }
        }
        @AuraEnabled
        public String ClaimStatus {get;set;}
		@AuraEnabled
		public Datetime SubmittedDate {get;set;}
		@AuraEnabled
        public String MemberName {get {
            return PatientFirstName + ' ' + PatientLastName;} set;}

        @AuraEnabled
        public String PatientFirstName {get;set;}
        @AuraEnabled
        public String PatientLastName {get;set;}
        @AuraEnabled
        public String SubmittedMemberId {get; set;}
        @AuraEnabled
        public DateTime PatientBirthDate {get;set{
            if(value != null){
                PatientBirthDate = DateTime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
            }
        }
        @AuraEnabled
        public String PlanName {get;set;}
        @AuraEnabled
        public Boolean SubmittedEligibility {get;set;}
        @AuraEnabled
        public String ProviderName {get {
            String npi = '';
            if(ProviderNpi != ''){
                npi = ' (#' + ProviderNpi +') ';

            }
            return ProviderFirstName + ' ' + ProviderLastName + npi

            ;}set;}

        @AuraEnabled
        public String ProviderFirstName {get;set;}
        @AuraEnabled
        public String ProviderLastName {get;set;}
        @AuraEnabled
        public String ProviderAddress1 {get;set;}
        @AuraEnabled
        public String ProviderAddress2 {get;set;}
        @AuraEnabled
        public String ServiceLocationName {get{
            String npi = ' ';
            String name = '';
            String city = '';
            String address = '';
            String state = '';
            String location = '';
            String zip = '';
            if(ServiceLocationNpi != ''){
                npi = ' (#' + ServiceLocationNpi +') ';

            }
            if(ProviderCity != null && ProviderAddress1 != null && ProviderState != null){
                city = ProviderCity;
                address = ProviderAddress1;
                state = ProviderState;
                zip = ProviderZipCode;
                name = ServiceOfficeName;
                location = name + npi + address + ', ' + city + ', '+ state + ' ' + zip;
            }

            return location
            ;}set;}

        @AuraEnabled
        public String ServiceOfficeName {get;set;}
        @AuraEnabled
        public String ProviderCity {get;set;}
        @AuraEnabled
        public String ProviderState {get;set;}
        @AuraEnabled
        public String ProviderZipCode {get;set;}
        @AuraEnabled
        public String Business {get{
            String bizNpi = '';
            if(BusinessNpi != ''){
                bizNpi = ' (#' + BusinessNpi +')';

            }
            return BusinessName + bizNpi;
        }
            set;}
        @AuraEnabled
        public String BusinessName {get;set;}
        @AuraEnabled
        public String ProviderTIN {get
            {
                String returnTIN = ProviderTIN;   
                if(returnTIN == null) {
                    returnTIN = '';
                }
                return returnTIN;
             }
            set;
        }

        @AuraEnabled
        public String ProviderNpi {get
            {
                String returnNpi = ProviderNpi;   
                if(returnNpi == null) {
                    returnNpi = '';
                }
                return returnNpi;
             }
            set;
        }

        @AuraEnabled
        public String BusinessNpi {get
            {
                String returnNpi = BusinessNpi;   
                if(returnNpi == null) {
                    returnNpi = '';
                }
                return returnNpi;
             }
            set;
        }

        @AuraEnabled
        public String ServiceLocationNpi {get
            {
                String returnNpi = ServiceLocationNpi;   
                if(returnNpi == null) {
                    returnNpi = '';
                }
                return returnNpi;
             }
            set;
        }

        @AuraEnabled
        public Decimal TotalBilledAmount {get;set;}
        @AuraEnabled
        public String PlaceOfTreatment {get;set;}
        @AuraEnabled
        public String OfficeReferenceNumber {get;set;}
        @AuraEnabled
        public String ReferralNumber {get;set;}
        @AuraEnabled
        public String IcdCode1 {get;set;}
        @AuraEnabled
        public String IcdCode2 {get;set;}
        @AuraEnabled
        public String IcdCode3 {get;set;}
        @AuraEnabled 
        public String IcdCode4 {get;set;}
        @AuraEnabled
        public Decimal SubmittedFeeSum {get;set;}
        @AuraEnabled
        public Decimal NetFeeSum {get;set;}
        @AuraEnabled
        public Datetime PaymentDate {get;
            set{
                if(value != null){
             PaymentDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
            }
        }
        @AuraEnabled
        public String PaymentNumber {get;set;}
        @AuraEnabled
        public Datetime ReceivedDate {get;set{
            if(value != null){
            ReceivedDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
        }
        }
        @AuraEnabled
        public Datetime OriginalDecisionDate {get;set {
            if(value != null){
            OriginalDecisionDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
        }
        }
        @AuraEnabled
        public String Notes {get;set;}
        @AuraEnabled
        public String BusinessGuid {get;set;}
        @AuraEnabled
        public Datetime ExpirationDate {get;set {
            if(value != null){
            ExpirationDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
        }
        }

        //Referral Specific fields
        @AuraEnabled
        public Datetime DecisionDate {get;set {
            if(value != null){
            DecisionDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
        }
        }

        @AuraEnabled
        public String RequestedSpecialty {get;set;}

        @AuraEnabled
        public String ReferralType {get;set;}
        @AuraEnabled
        public String ReferralTypeDesc {get;set;}
        @AuraEnabled
        public String VoidReasonCode {get;set;}
        @AuraEnabled
        public String DeterminationReason {get;set;}
        @AuraEnabled
        public Boolean MemberContacted {get;set;}
        @AuraEnabled
        public String DenialReason {get;set;}
        @AuraEnabled
        public Boolean IsInternalCareTransfer {get;set;}

        @AuraEnabled
        public String ApprovedProvider {get;set;}
        @AuraEnabled
        public Boolean ReferralApproved {get;set;}
        @AuraEnabled
        public String ApprovedProviderAddress {get;set;}
        @AuraEnabled
        public String ApprovedProviderPhone {get;set;}


        @AuraEnabled
        public List<ClaimDetailResponseAttachWrapper> Attachments {get;set;}

        @AuraEnabled
        public List<ClaimDetailResponsePoliciesWrapper> ProcessingPolicies {get;set;}

        

	}

	public class ClaimDetailResponseWrapper{
        public ClaimDetailResponseWrapper() {

            Attachments = new List<ClaimDetailResponseAttachWrapper>();
            ProcessingPolicies = new List<ClaimDetailResponsePoliciesWrapper>(); 
        }
        @AuraEnabled
        public String TreatingProviderGuid {get;set;}
        @AuraEnabled
        public String ServiceOfficeGuid {get;set;}



        @AuraEnabled
        public String ClaimId {get;set;}
		@AuraEnabled
		public String ClaimNumber {get;set;}
        @AuraEnabled
        public String ClaimTypeCategory {get;set;}
        @AuraEnabled
        public String ClaimStatus {get;set;}
		@AuraEnabled
		public Datetime SubmittedDate {get;set;}
		@AuraEnabled
        public String MemberName {get {
            return PatientFirstName + ' ' + PatientLastName;} set;}

        @AuraEnabled
        public String PatientFirstName {get;set;}
        @AuraEnabled
        public String PatientLastName {get;set;}
        @AuraEnabled
        public String SubmittedMemberId {get; set;}
        @AuraEnabled
        public DateTime PatientBirthDate {get;set{
            if(value != null){
                PatientBirthDate = DateTime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
            }
        }
        @AuraEnabled
        public String PlanName {get;set;}
        @AuraEnabled
        public Boolean SubmittedEligibility {get;set;}
        @AuraEnabled
        public String ProviderName {get {
            String npi = '';
            if(ProviderNpi != ''){
                npi = ' (#' + ProviderNpi +') ';

            }
            return ProviderFirstName + ' ' + ProviderLastName + npi

            ;}set;}

        @AuraEnabled
        public String ProviderFirstName {get;set;}
        @AuraEnabled
        public String ProviderLastName {get;set;}
        @AuraEnabled
        public String ProviderAddress1 {get;set;}
        @AuraEnabled
        public String ServiceLocationName {get{
            String npi = ' ';
            String name = '';
            String city = '';
            String address = '';
            String state = '';
            String location = '';
            String zip = '';
            if(ServiceLocationNpi != ''){
                npi = ' (#' + ServiceLocationNpi +') ';

            }
            if(ProviderCity != null && ProviderAddress1 != null && ProviderState != null){
                city = ProviderCity;
                address = ProviderAddress1;
                state = ProviderState;
                zip = ProviderZipCode;
                name = ServiceOfficeName;
                location = name + npi + address + ', ' + city + ', '+ state + ' ' + zip;
            }

            return location
            ;}set;}
        @AuraEnabled
        public String ServiceOfficeName {get;set;}
        @AuraEnabled
        public String ProviderCity {get;set;}
        @AuraEnabled
        public String ProviderState {get;set;}
        @AuraEnabled
        public String ProviderZipCode {get;set;}
        @AuraEnabled
        public String Business {get{
            String bizNpi = '';
            if(BusinessNpi != ''){
                bizNpi = ' (#' + BusinessNpi +')';

            }
            return BusinessName + bizNpi;
        }
            set;}
        @AuraEnabled
        public String BusinessName {get;set;}
        @AuraEnabled
        public String ProviderTIN {get
            {
                String returnTIN = ProviderTIN;   
                if(returnTIN == null) {
                    returnTIN = '';
                }
                return returnTIN;
             }
            set;
        }

        @AuraEnabled
        public String ProviderNpi {get
            {
                String returnNpi = ProviderNpi;   
                if(returnNpi == null) {
                    returnNpi = '';
                }
                return returnNpi;
             }
            set;
        }

        @AuraEnabled
        public String BusinessNpi {get
            {
                String returnNpi = BusinessNpi;   
                if(returnNpi == null) {
                    returnNpi = '';
                }
                return returnNpi;
             }
            set;
        }

        @AuraEnabled
        public String ServiceLocationNpi {get
            {
                String returnNpi = ServiceLocationNpi;   
                if(returnNpi == null) {
                    returnNpi = '';
                }
                return returnNpi;
             }
            set;
        }

        @AuraEnabled
        public Decimal TotalBilledAmount {get;set;}
        @AuraEnabled
        public String PlaceOfTreatment {get;set;}
        @AuraEnabled
        public String OfficeReferenceNumber {get;set;}
        @AuraEnabled
        public String ReferralNumber {get;set;}
        @AuraEnabled
        public String IcdCode1 {get;set;}
        @AuraEnabled
        public String IcdCode2 {get;set;}
        @AuraEnabled
        public String IcdCode3 {get;set;}
        @AuraEnabled 
        public String IcdCode4 {get;set;}
        @AuraEnabled
        public Decimal SubmittedFeeSum {get;set;}
        @AuraEnabled
        public Decimal NetFeeSum {get;set;}
        @AuraEnabled
        public Datetime PaymentDate {get;
            set{
                if(value != null){
             PaymentDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
            }
        }
        @AuraEnabled
        public String PaymentNumber {get;set;}
        @AuraEnabled
        public Datetime ReceivedDate {get;set{
            if(value != null){
            ReceivedDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
        }
        }
        @AuraEnabled
        public Datetime OriginalDecisionDate {get;set {
            if(value != null){
            OriginalDecisionDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
        }
        }
        @AuraEnabled
        public String Notes {get;set;}
        @AuraEnabled
        public String BusinessGuid {get;set;}
        @AuraEnabled
        public String StatusCategory {get;
            set {
                StatusCategory = value;
                if(value == 'Accepted') {
                    StatusCategory = 'Submitted';
                }
            }
        }
        @AuraEnabled
        public Datetime ExpirationDate {get;set {
            if(value != null){
            ExpirationDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
        }
        }

        //Referral Specific fields
        @AuraEnabled
        public Datetime DecisionDate {get;set {
            if(value != null){
            DecisionDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
        }
        }

        @AuraEnabled
        public String RequestedSpecialty {get;set;}

        @AuraEnabled
        public String ReferralType {get;set;}
        @AuraEnabled
        public String VoidReasonCode {get;set;}
        @AuraEnabled
        public String DeterminationReason {get;set;}
        @AuraEnabled
        public Boolean MemberContacted {get;set;}
        @AuraEnabled
        public String DenialReason {get;set;}
        @AuraEnabled
        public Boolean IsInternalCareTransfer {get;set;}

        @AuraEnabled
        public String ApprovedProvider {get;set;}
        @AuraEnabled
        public Boolean ReferralApproved {get;set;}
        @AuraEnabled
        public String ApprovedProviderAddress {get;set;}
        @AuraEnabled
        public String ApprovedProviderPhone {get;set;}

        @AuraEnabled
        public String PlanGuid {get;set;}
        @AuraEnabled
        public String PatientMemberProfileGuid {get;set;}
         @AuraEnabled
        public String BusinessId {get;set;}
        @AuraEnabled
        public String ServiceOfficeId {get;set;}
        @AuraEnabled
        public String ProviderId {get;set;}


        @AuraEnabled
        public String SubscriberFirstName {get;set;}
        @AuraEnabled
        public String SubscriberLastName {get;set;}
        @AuraEnabled
        public Date SubscriberBirthDate {get;set;}
        @AuraEnabled
        public String SubscriberAddress1 {get;set;}
        @AuraEnabled
        public String SubscriberAddress2 {get;set;}
        @AuraEnabled
        public String SubscriberCity {get;set;}
        @AuraEnabled
        public String SubscriberState {get;set;}
        @AuraEnabled
        public String SubscriberZip {get;set;}
        @AuraEnabled
        public String SubscriberId {get;set;}

        @AuraEnabled
        public String PatientAddress1 {get;set;}
        @AuraEnabled
        public String PatientAddress2 {get;set;}
        @AuraEnabled
        public String PatientCity {get;set;}
        @AuraEnabled
        public String PatientState {get;set;}
        @AuraEnabled
        public String PatientZip {get;set;}


        @AuraEnabled
        public List<ClaimDetailResponseAttachWrapper> Attachments {get;set;}

        @AuraEnabled
        public List<ClaimDetailResponsePoliciesWrapper> ProcessingPolicies {get;set;}

        

	}

    


    //COB Payer Claim
    public class ClaimDetailCOBPayerClaimWrapper{
        public ClaimDetailCOBPayerClaimWrapper() {
        
        }
        @AuraEnabled
        public String LineNumber {get;set;}
        @AuraEnabled
        public String OtherCarrierName {get;set;}
        @AuraEnabled
        public String MemberName {get;set;}
        @AuraEnabled
        public String OtherSubscriberFirstName {get;set;}
        @AuraEnabled
        public String OtherSubscriberLastName {get;set;}
        @AuraEnabled
        public String OtherPolicyNumber {get;set;}
        @AuraEnabled
        public Datetime OtherSubscriberDob {get
            ;set{
            if(value != null){
            OtherSubscriberDob = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
        }
        }

            
        @AuraEnabled
        public String OtherSubscriberGroupName{get;set;}
        @AuraEnabled
        public Decimal PrimePaid {get;set;}
        @AuraEnabled
        public Datetime OtherInsurancePaidDate {get;set{
            if(value != null){
            OtherInsurancePaidDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
        }
        }

    }


    //Service Line
    public class ClaimDetailServiceLineWrapper{
        public ClaimDetailServiceLineWrapper(){

            COBDetail = new List<prov_wrap_Claim.ClaimDetailCOBPayerClaimWrapper>();
            
        }
       

        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public Datetime ServiceDate {get
            ;set{
            if(value != null){
                ServiceDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
            }
            
        }
        @AuraEnabled
        public String ProcedureCode {get;set;}

        //concatenation of the Processing Policy Code and Description for the confirmation report
        @AuraEnabled
        public String ProcedureCodeDescConcat {get;set;}
        @AuraEnabled
        public String PaidProcedureCode {get;set;}
        @AuraEnabled
        public String ProcedureCodeDescription {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String LineNumber {get;set;}
        @AuraEnabled
        public String ToothQuadArchSurface {get{

            return ToothNumber + '/' + Quadrant + '/'+Arch + '/'+Surface;
        }
            set;}
        @AuraEnabled
        public String ToothNumber {get{
            String tooth = '-';
            if(ToothNumber != null){
                tooth = ToothNumber;
            }
            return tooth;
        }
            set;}
        @AuraEnabled
        public String Quadrant {get{
            String quad = '-';
            if(Quadrant != null){
                quad = Quadrant;
            }
            return quad;
        }
            set;}
        @AuraEnabled
        public String Arch {get{
            String arc = '-';
            if(Arch != null){
                arc = Arch;
            }
            return arc;
        }
            set;}
        @AuraEnabled
        public String Surface {get{
            String surf = '-';
            if(Surface != null){
                surf = Surface;
            }
            return surf;
        }
            set;}

        


        //this is always 1
        @AuraEnabled
        public Integer Quantity {get;set;}
        @AuraEnabled
        public String LineStatus {get;set;}

        @AuraEnabled
        public Decimal AllowedFee {get;set;}
        @AuraEnabled
        public Decimal NetFee {get;set;}
        @AuraEnabled
        public String ICDPositions {get {
            List<String> values = new List<String>();
            if(IcdCode1 != null ){
                values.add(IcdCode1);
            }
            if(IcdCode2 != null){
                values.add(IcdCode2);
            }
            if(IcdCode3 != null ){
                values.add(IcdCode3);
            }
            if(IcdCode4 != null){
                values.add(IcdCode4);
            }

            return String.join( values , '; ')
            ;}set;}
        @AuraEnabled
        public String IcdCode1 {get;set;}
        @AuraEnabled
        public String IcdCode2 {get;set;}
        @AuraEnabled
        public String IcdCode3 {get;set;}
        @AuraEnabled 
        public String IcdCode4 {get;set;}

        @AuraEnabled
        public String ProcessingPolicies {get;set;}

        @AuraEnabled
        public List<ClaimDetailCOBPayerClaimWrapper> COBDetail {get;set;}



    }


    //Processing Policies
    public class ClaimDetailResponsePoliciesWrapper{
        public ClaimDetailResponsePoliciesWrapper() {

        }
        @AuraEnabled
        public String MessageCode {get;set;}
        @AuraEnabled
        public String Description {get;set;}
    }

    //attachment request 
    public class ClaimDetailAttachmentRequestWrapper{
        public ClaimDetailAttachmentRequestWrapper() {
        
        }
        @AuraEnabled
        public String ClaimNumber {get;set;}
        @AuraEnabled
        public String RouteId {get;set;}
    }



    //List of attachments returned from attachment request
    public class ClaimDetailResponseAttachWrapper {
        public ClaimDetailResponseAttachWrapper() {
        
        }

        @AuraEnabled
        public String OriginalFileName {get;set;}
         @AuraEnabled
        public String DocumentId {get;set;} 
        @AuraEnabled
        public String AttachmentLink {get;set;}
        @AuraEnabled
        public String AttachmentId {get;set;} 
        @AuraEnabled
        public Datetime CreatedDate {get;set;}
        @AuraEnabled
        public Datetime Created {get;set;}
        @AuraEnabled
        public String FileExtension {get;set;}
        @AuraEnabled
        public String ClaimNumber {get;set;}
        @AuraEnabled
        public String ServiceOfficeGuid {get;set;}
    }

    public class ClaimDetailReferralWrapper{
        public ClaimDetailReferralWrapper() {

        }

        @AuraEnabled
        public String Approved {get;set;}
        @AuraEnabled
        public String RequestedProviderName {get {
            return RequestedProviderFirstName + ' ' + RequestedProviderLastName;} set;}
        
        @AuraEnabled
        public String RequestedProviderFirstName {get;set;}
        @AuraEnabled
        public String RequestedProviderLastName {get;set;}
        @AuraEnabled
        public String RequestedProviderAddress {get{
            String city = '';
            String address = '';
            String state = '';
            String location = '';
            if(RequestedProviderCity != null && RequestedProviderAddress1 != null && RequestedProviderState != null){
                city = RequestedProviderCity;
                address = RequestedProviderAddress1;
                state = RequestedProviderState;
                location = address + ', ' + city + ', '+ state + ' ' + RequestedProviderZipcode;
            }

            return location
            ;}set;}
        @AuraEnabled
        public String RequestedProviderAddress1 {get;set;}
        @AuraEnabled
        public String RequestedProviderCity {get;set;}
        @AuraEnabled
        public String RequestedProviderState {get;set;}
        @AuraEnabled
        public String RequestedProviderZipcode {get;set;}
        @AuraEnabled
        public String RequestedProviderPhoneNumber {get;set;}
        @AuraEnabled
        public String RequestedProviderGuid {get;set;}
        @AuraEnabled
        public String RequestedServiceOfficeLocationGuid {get;set;}
        @AuraEnabled
        public String RequestedBusinessGuid {get;set;}
        @AuraEnabled
        public DateTime ReferralExpirationDate {get;set;}
        @AuraEnabled
        public String SpecialtyTypeDesc {get;set;}
        @AuraEnabled
        public String MemberContacted {get;set;}
    }


    public class ReferralDetailReferralWrapper{
        public ReferralDetailReferralWrapper() {

        }
        @AuraEnabled
        public String StatusCategory {get;
            set {
                StatusCategory = value;
                if(value == 'Accepted') {
                    StatusCategory = 'Submitted';
                }
            }
        }

        @AuraEnabled
        public String Approved {get;set;}
        @AuraEnabled
        public String RequestedProviderName {get {
            String name = '';
            if(RequestedProviderName == null || RequestedProviderName == ''){
                name = RequestedProviderFirstName + ' ' + RequestedProviderLastName;
                return name;
            }
            else{
                return RequestedProviderName;
            
             }
             } set;}
            
        
        @AuraEnabled
        public String RequestedProviderFirstName {get;set;}
        @AuraEnabled
        public String RequestedProviderLastName {get;set;}
        @AuraEnabled
        public String RequestedProviderAddress {get{
            String city = '';
            String address = '';
            String state = '';
            String location = '';
            if(RequestedProviderCity != null && RequestedProviderAddress1 != null && RequestedProviderState != null){
                city = RequestedProviderCity;
                address = RequestedProviderAddress1;
                state = RequestedProviderState;
                location = address + ', ' + city + ', '+ state + ' ' + RequestedProviderZipcode;
            }

            return location
            ;}set;}
        @AuraEnabled
        public String RequestedProviderAddress1 {get;set;}
        @AuraEnabled
        public String RequestedProviderAddress2 {get;set;}
        @AuraEnabled
        public String RequestedProviderCity {get;set;}
        @AuraEnabled
        public String RequestedProviderState {get;set;}
        @AuraEnabled
        public String RequestedProviderZipcode {get;set;}
        @AuraEnabled
        public String RequestedProviderPhoneNumber {get{
        	if(RequestedProviderPhoneNumber != null && RequestedProviderPhoneNumber != '' && !RequestedProviderPhoneNumber.startsWith('(') && !RequestedProviderPhoneNumber.contains('-')){
        		String newPhoneNumber = '';
        		newPhoneNumber = RequestedProviderPhoneNumber.substring(0,3) + '-';
        		newPhoneNumber += RequestedProviderPhoneNumber.substring(3,6) + '-';
        		newPhoneNumber += RequestedProviderPhoneNumber.substring(6) ;
        		return newPhoneNumber;
        	} else {
	        	return 	RequestedProviderPhoneNumber;
        		
        	}	
        }set;}



        @AuraEnabled
        public DateTime FinalDeterminationDateTime {get
            ;set{
            if(value != null){
                FinalDeterminationDateTime = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
            }
            
        }
        @AuraEnabled
        public String DeterminationReason {get;set;}
        @AuraEnabled
        public String RequestedProviderGuid {get;set;}
        @AuraEnabled
        public String RequestedServiceOfficeLocationGuid {get;set;}
        @AuraEnabled
        public String RequestedBusinessGuid {get;set;}
        @AuraEnabled
        public DateTime ReferralExpirationDate {get
            ;set{
            if(value != null){
                ReferralExpirationDate = Datetime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT())
            ;}
            }
            
        }
        @AuraEnabled
        public String SpecialtyType {get;set;}
        @AuraEnabled
        public String SpecialtyTypeDesc {get;set;}
        @AuraEnabled
        public String MemberContacted {get;set;}
    }



    
}