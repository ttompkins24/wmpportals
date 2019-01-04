public with sharing class prov_wrap_EOB {
	// overall result wrapper for claim header callout
    public class EOBHeaderResultWrapper{
        @AuraEnabled
        public List<EOBHeaderResponseWrapper> Eobs {get;set;}
        @AuraEnabled
        public Integer Total {get;set;}
        @AuraEnabled
        public Integer PageNumber {get;set;}
        @AuraEnabled
        public Integer PageSize {get;set;}
        @AuraEnabled
        public Integer TotalPages {get;set;}
    }

	// wrapper for individual claim search results from header callout
	public class EOBHeaderResponseWrapper{
		@AuraEnabled
		public String EobId {get;set;}
		@AuraEnabled
		public String CheckOrEftNumber {get;set;}
		@AuraEnabled
		public String PayerName {get;set;}
		@AuraEnabled
		public String PayeeName {get;set;}
		@AuraEnabled
		public String PayeeAddress1 {get;set;}
		@AuraEnabled
		public String PayeeAddress2 {get;set;}
        @AuraEnabled
		public String PayeeCity {get;set;}
		@AuraEnabled
		public String PayeeState {get;set;}
		@AuraEnabled
		public String PayeeZip {get;set;}
		@AuraEnabled
		public DateTime CheckOrEftReleaseDate {get;
			set{
				if(value != null) {
					CheckOrEftReleaseDate = DateTime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT());
				}
			}
		}
		@AuraEnabled
		public String PaymentType {get;set;}
		@AuraEnabled
		public Decimal PaymentAmount {get;set;}
		@AuraEnabled
		public String BusinessGuid {get;set;}
		@AuraEnabled
		public String ServiceOfficeGuid {get;set;}
		@AuraEnabled
		public String ProviderGuid {get;set;}
		@AuraEnabled
		public String ClientPaymentRunIds {get;set;}
		@AuraEnabled
		public DateTime IssuedDate {get;
			set{
				if(value != null) {
					IssuedDate = DateTime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT());
				}
			}
		}
		@AuraEnabled
		public String RouteId {get;set;}
		@AuraEnabled
		public Boolean Reconciled {get;set;}
		@AuraEnabled
		public String EobLink {get;set;}
	}
}