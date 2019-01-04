/**********************************************************************************************************************
Name 						: wmp_ctrl_helpCenterLanding
Purpose						: The controller for the component that displays the helpcenter landing page
Created on					: 30th September 2017
Developed by				: Santosh Kumar Sriram
History
Version#		Sprint#		Date							By  						Comments
1.0				1.0			30th September 2017				Santosh Kumar Sriram		See header - purpose
**********************************************************************************************************************/
public without sharing class wmp_ctrl_helpCenterLanding {
	
	/**************************************************************
	Method Name : loadConfiguration
	Return type : portal config metadata type
	&**********************************************************************/
	@AuraEnabled
	public static Portal_Configuration__mdt loadConfiguration(){
    	//return the portal configuration
    	return wmp_util_Cache.PortalConfiguration;
    }
    
    
    /**************************************************************
	Method Name : getOtherResourcesPortalLinks
	Return type : portal config links array metadata type
	&**********************************************************************/
	@AuraEnabled
	public static list<Help_Center_Other_resource__kav> getOtherResourcesPortalLinks(list<string> list_KATitles){
		System.debug('>>>>>>>>>>>>>.' + list_KATitles);
		if(!list_KATitles.isEmpty()){
	    	//Querying for the list of all helpcenter other resources
	    	list<Help_Center_Other_resource__kav> list_allRelatedOtherResources= new list<Help_Center_Other_resource__kav>();
	    	String queryString = ' WHERE PublishStatus = \'' + System.Label.PublishStatus + '\''
	    						+ ' AND Language= \''+ UserInfo.getLanguage()+ '\'';
	    		
	    	for(Integer iterating_int= 0 ; iterating_int < list_KATitles.size();iterating_int++){
	    		if(iterating_int > 0){
	    			queryString += 'OR Title = \'' + list_KATitles[iterating_int] + '\'';
	    		}else{
	    			queryString += ' AND (Title = \'' + list_KATitles[iterating_int] + '\'';
	    		}
	    	
	    	}
	    	queryString +=  ')';
	    	list_allRelatedOtherResources = wmp_util_Helper.getObjects('Help_Center_Other_resource__kav',queryString, true);
	    	System.debug('>>>>>>>>>>>>>.' + list_allRelatedOtherResources);
	    	return list_allRelatedOtherResources;
		}else
		return null;
    }
    
}