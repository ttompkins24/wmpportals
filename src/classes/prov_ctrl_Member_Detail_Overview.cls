/*
/*******************************************************************************************************
Name                        : prov_ctrl_Member_Detail_Overview
Purpose                     : Controller for the prov_comp_Member_Detail_Overview
                              Gets relevant overview information, including member eligibility
Created on                  : 13rd January 2018
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                    by                              Comments
1.0             1.0         13rd January 2018       West Monroe Partners            See header - purpose
 
*******************************************************************************************************
*/
public class prov_ctrl_Member_Detail_Overview {
    @AuraEnabled
    public static MemberOverviewWrapper getMemberOverviewApex(String coverageId, String memberGuid, String dateOfService){
        MemberOverviewWrapper wrapper = new MemberOverviewWrapper();

        Date dos = Date.today();
        System.debug('### dateOfServiceL ' + dateOfService);
        if(dateOfService != NULL) {
            dos = Date.parse(dateOfService);
            //dos = Date.valueOf(dateOfService);
        }
        
        List<String> coverageIds = new List<String>();
        if(coverageId != '' && coverageId != null)
        	coverageIds.add(coverageId);

        List<mock_MemberPrimaryCareDentist__c> pcds = prov_util_DAL.getPrimaryDentistsByDate(coverageIds, memberGuid, dos); 
        if(pcds != NULL && pcds.size() > 0) {
            wrapper.primaryCareDentist = pcds[0];
        }
        System.debug('### pcds: ' + pcds);
        System.debug('### pcds size: ' + pcds.size());

        wrapper.otherCoverages = prov_util_DAL.getCOBs(new List<String>{memberGuid});
        Set<String> accumulatorGuids = new Set<String>();
        wrapper.benefits = new List<mock_MemberAccumulator__c>();
        for(mock_MemberAccumulator__c acc : prov_util_DAL.getMemberAccumulators(new List<String>{ memberGuid }, dos)){
            if(!accumulatorGuids.contains(acc.MemberAccumulatorGuid__c.toLowercase())){
                wrapper.benefits.add(acc);
                accumulatorGuids.add(acc.MemberAccumulatorGuid__c.toLowercase());
            }
        }

        // get the service location and provider accounts based on their guid matching the 
        // winward Id on account
        Set<String> windwardGuids = new Set<String>();
        windwardGuids.add(wrapper.primaryCareDentist.ServiceLocationGUID__c);
        windwardGuids.add(wrapper.primaryCareDentist.ProviderGUID__c);
        List<Account> accounts = prov_util_DAL.getAccounts(windwardGuids);

        System.debug('### windwardGuids: ' + windwardGuids);
        System.debug('### accounts: ' + accounts);

        for(Account acc : accounts) {
            if(acc.guid__c == wrapper.primaryCareDentist.ServiceLocationGUID__c) {
                wrapper.pcdServiceLocation = acc;
            } else if(acc.guid__c == wrapper.primaryCareDentist.ProviderGUID__c) {
                wrapper.pcdProvider = acc;
            }
        }
        return wrapper;
    }

    public class MemberOverviewWrapper {
        @AuraEnabled public mock_MemberPrimaryCareDentist__c primaryCareDentist;
        @AuraEnabled public Account pcdServiceLocation;
        @AuraEnabled public Account pcdProvider;
        @AuraEnabled public List<mock_MemberCOB__c> otherCoverages;
        @AuraEnabled public List<mock_MemberAccumulator__c> benefits;
    }
}