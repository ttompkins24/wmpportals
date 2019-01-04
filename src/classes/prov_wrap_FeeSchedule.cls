global with sharing class prov_wrap_FeeSchedule {

	// wrapper for callout request for fee schedule
	public class FeeScheduleRequestWrapper{
		@AuraEnabled
		public String NetworkGuid {get;set;} // always required
		@AuraEnabled
		public Date ServiceDate {get;set;} // always required
		@AuraEnabled
		public String RouteId {get;set;} // always required
		@AuraEnabled
		public String BusinessGuid {get;set;} // required for special
		@AuraEnabled
		public String ProviderGuid {get;set;} // required for special
		@AuraEnabled
		public String ServiceOfficeGuid {get;set;} // required for special
		@AuraEnabled
		public String NetworkStatus {get;set;}
		@AuraEnabled
		public String CoverageType {get;set;}
		@AuraEnabled
		public String ProviderOfficeType {get;set;}
		@AuraEnabled
		public String ProviderSpecialty {get;set;}
		@AuraEnabled
		public Boolean IsSpecialDeal {get;set;} // set via selection on search page, used in callout class to set endpoint
	}

    // both fee schedule callouts return the same fields
    global class FeeScheduleResponseWrapper{
		@AuraEnabled
        public String ProcedureCode {get;set;}
        @AuraEnabled
        public String ProcedureDescription {get;set;}
        @AuraEnabled
        public Boolean SpecialDeal {get;set;}
        @AuraEnabled
        public Boolean Network {get;set;}
        @AuraEnabled
        public Decimal DollarAmount {get;set;}
        @AuraEnabled
        public String ToothCode {get;set;}
        @AuraEnabled
        public String ZipCode {get;set;}
        @AuraEnabled
        public Integer MinimumAge {get;set;}
        @AuraEnabled
        public Integer MaximumAge {get;set;}
        @AuraEnabled
        public DateTime EffectiveDate {get;
			set{
				if(value != null) {
					EffectiveDate = DateTime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT());
				}
			}
		}
        @AuraEnabled
		public DateTime TerminationDate {get;
			set{
				if(value != null) {
					TerminationDate = DateTime.newInstance(value.yearGMT(), value.monthGMT(), value.dayGMT());
				}
			}
		}
    }
}