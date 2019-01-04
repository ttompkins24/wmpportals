/**********************************************************************************************************************
Name                        : wmp_EOBRequestDetail
Purpose                     : Object representation of JSON results for EOB
Created on                  : October 2017
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                            By                      Comments
1.0             8           October 2017              		West Monroe Partners    See header - purpose
 
**********************************************************************************************************************/
public class wmp_EOBRequestDetail {

		@AuraEnabled
		public String SubscriberId {get; set;}
		@AuraEnabled
		public String PlanGuid {get; set;}
		@AuraEnabled
		public String RouteId {get; set;}
		@AuraEnabled
		public String MemberUniversalGuid {get; set;}
		@AuraEnabled
		public String ClaimNumber {get; set;}
		@AuraEnabled
		public String DateOfService {get; set;}
		@AuraEnabled
		public String EobLink {get; set;}
		
	public static List<wmp_EOBRequestDetail> parse(String json) {
		return (List<wmp_EOBRequestDetail>) System.JSON.deserialize(json, List<wmp_EOBRequestDetail>.class);
	}
}