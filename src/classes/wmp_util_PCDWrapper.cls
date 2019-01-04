/**********************************************************************************************************************
Name                        : 	wmp_util_PCDWrapper
Purpose                     : 	Wrapper class for PCD requests
Created on                  : 	08/09/2017
Developed by				: 	Patrick Stephens
History

**********************************************************************************************************************/

public class wmp_util_PCDWrapper {
    	public string 				ProviderGUID									{get;set;}
        public string 				ServiceLocationGUID								{get;set;}
        public string 				reason											{get;set;}
        
        //list of MemberCoverageGUID
        public List<String>			MemberCoverageGUIDs								{get;set;}
}