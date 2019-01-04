/**********************************************************************************************************************
Purpose						: The controller for retrieving info with the user profile dropdown menu
Created on					: 9th Oct 2017
Developed by				: Todd Tompkins
History
Version#		Sprint#		Date							By  					Comments
1.0				1.0			9th Oct 2017					Todd Tompkins					See header - purpose
  

**********************************************************************************************************************/
public without sharing class wmp_ctrl_UserProfile {
	
	@AuraEnabled 
	public static String getUserName(){
		String username = UserInfo.getFirstName();
		try{
			username = wmp_util_Cache.ContactRec.FirstName;
		}catch(Exception ex){}
		return username;
	}
	
    @AuraEnabled 
	public static String getAccountSettingsUrl(){
		String url = '';
		try{
			url = wmp_util_Cache.PortalConfiguration.MyAccountSettings__c ;
		}catch(Exception ex){}
		return url;
	}
    
	@AuraEnabled
    public static String initLanguage(){
    	//initialize the variables
    	Map<String, String> lang2langCodeMap = new Map<String, String>{'en_US'=>'English', 'es' =>'Espanol'};
    	String locKey = UserInfo.getLanguage();
    	
    	System.debug('langSelected::'+locKey);
    	
    	if(lang2langCodeMap.containsKey(locKey)){
    		return lang2langCodeMap.get(locKey);
    	}
    	
    	return 'English';
    }
    
    @AuraEnabled
    public static String setLanguage(String langSelected){
    	//initialize the variables
    	Map<String, String> lang2langCodeMap = new Map<String, String>{'English'=>'en_US', 'Espanol' =>'es'};
    	User u = new User (Id=UserInfo.getUserId());
    	
    	if(lang2langCodeMap.containsKey(langSelected)){
    		u.LanguageLocaleKey = lang2langCodeMap.get(langSelected);
    		
    		update u;
    	}
    	
    	return '';
    }
}