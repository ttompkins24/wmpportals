/**********************************************************************************************************************
Name                        : 	wmp_util_PCDCalloutWrapper
Purpose                     : 	Wrapper class for the PCD request callout body
Created on                  : 	08/09/2017
Developed by				: 	Patrick Stephens
History

**********************************************************************************************************************/
global class wmp_util_PCDCalloutWrapper {
    public List<PCDRequest>					PCDRequests											{get{
        if(PCDRequests==null)
            PCDRequests = new List<PCDRequest>();
        return PCDRequests;
    }set;}
    
    global class PCDRequest{
        public string 						RouteID												{get;set;}
        public string 						MemberCoverageGUID									{get;set;}
        public string 						ServiceLocationGUID									{get;set;}
        public string 						ProviderGUID										{get;set;}
        public string                       TerminationCode                                     {get;set;}
        public List<string>					UserPlanVerificationSFIDs							{get;set;}
    }
}