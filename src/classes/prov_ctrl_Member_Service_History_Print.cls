public without sharing class prov_ctrl_Member_Service_History_Print {
	public List<mock_MembersServiceHistory__c> services {
		get {
			return servicesInternal;
		} private set;
	}
	private static List<mock_MembersServiceHistory__c> servicesInternal;
    
	@TestVisible private static String businessId;
	@TestVisible private static String sortDirection;
	@TestVisible private static String sortField;
    public prov_ctrl_Member_Service_History_Print() {
        String memberGuid = ApexPages.currentPage().getParameters().get('id');

        sortDirection = ApexPages.currentPage().getParameters().get('sortDir');
		sortField = ApexPages.currentPage().getParameters().get('sortField');
		prov_util_CacheObject tobj = (prov_util_CacheObject)Cache.Session.get('ProviderCache');
		businessId = tobj.CurrentBusinessId;

        List<String> availablePlanGuids = new List<String>();
        try {
        	availablePlanGuids.addAll(prov_util_Cache.getVisibilePlanWWIds(businessId));
        } catch(exception e) {
            system.debug('error finding available plan guids: '+e);
        }
        if(!availablePlanGuids.isEmpty()) {
        	servicesInternal = prov_ctrl_Member_Detail_History.getHistoryApex(memberGuid, availablePlanGuids, '1', '10000', sortField, sortDirection).services;
        }
		system.debug('servicesInternal: '+servicesInternal);
    }
}