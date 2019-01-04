/*
/*******************************************************************************************************
Name                        : prov_ctrl_Member_Detail_History
Purpose                     : Controller for the prov_comp_Member_Detail_History
                              Gets relevant service history records for a member
Created on                  : 13rd January 2018
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                    by                              Comments
1.0             1.0         13rd January 2018       West Monroe Partners            See header - purpose
 
*******************************************************************************************************
*/
public class prov_ctrl_Member_Detail_History {   

    @AuraEnabled
    public static MemberHistoryWrapper getHistoryApex(String memberGuid, List<String> planGuids, String pageNumS, String numResultsS, String sortByField, String sortDirection){
        MemberHistoryWrapper wrapper = new MemberHistoryWrapper();

        Integer pageNum = 1;
        Integer numResults = 25;
        
        //check to see if blank, if so then set default 
        if(pageNumS != null && pageNumS != '')              pageNum = Integer.valueOf(pageNumS);
        if(numResultsS != null && numResultsS != '')        numResults = Integer.valueOf(numResultsS);
        if(sortByField == null || sortByField == '')        sortByField = 'ProcedureDate__c';
        if(sortDirection == null || sortDirection == '')    sortDirection = 'DESC';

        List<String> availablePlanGuids = new List<String>();
        availablePlanGuids.addAll(prov_util_Cache.getVisibilePlanWWIds(prov_util_Cache.CurrentBusinessId));
        System.debug('### available plan guids: ' + availablePlanGuids);
        System.debug('### for business id: ' + prov_util_Cache.CurrentBusinessId);
        

        List<mock_MembersServiceHistory__c> services = prov_util_DAL.getMemberServiceHistory_MemDetail(new List<String>{ memberGuid },  availablePlanGuids, pageNum, numResults, sortByField, sortDirection);
        wrapper.totalResults = 1;

        List<mock_MembersServiceHistory__c> services_in_plans = new List<mock_MembersServiceHistory__c>();
        for(mock_MembersServiceHistory__c service : services) {
            if(availablePlanGuids.contains(service.PlanGUID__c)) {
                services_in_plans.add(service);
            }
        }

        wrapper.services = services_in_plans;

        //query to get total num of results
        List<mock_MembersServiceHistory__c> all_services = prov_util_DAL.getMemberServiceHistory_MemDetailSize(new List<String>{ memberGuid },  availablePlanGuids);
        Integer counter = 0;
        for(mock_MembersServiceHistory__c service : all_services) {
            if(availablePlanGuids.contains(service.PlanGUID__c)) {
                counter = counter + 1;
            }
        }

        wrapper.totalResults = counter;
        return wrapper;
    }

    public class MemberHistoryWrapper {
        @AuraEnabled public List<mock_MembersServiceHistory__c> services;
        @AuraEnabled public Integer totalResults;
    }

}