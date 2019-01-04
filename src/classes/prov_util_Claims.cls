/**********************************************************************************************************************
Name                        : 	prov_util_Claims
Purpose                     : 	utility methods for claims entry and management
Created on                  : 	03/06/2018
Developed by				: 	Patrick Stephens
History
Version#    Sprint#     Date            by                   Comments
1.1			1.0      	03/06/2018		Patrick Stephens	 	

**********************************************************************************************************************/

global without sharing class prov_util_Claims {
    
    private class ClaimException extends Exception{}
    
    /**
     * Starting suffix number
     */
    public static final String STARTING_SUFFIX = '00';

    /* @description
    * Build a claim/pre-auth/referral number with the current date and the next claim/pre-auth/referral sequence number
    * pulled from Org1
    * @return                  Claim/pre-auth/referral number
    */
    public static String buildNumber() {
        return buildNumber(1)[0];
    }
    public static List<String> buildNumber(Integer num) {
        if(num==null || num<1)
            num=1;
        Sequence_Number__c seqNumber = [SELECT Id, Date__c, Number__c, Source_number__c 
                                        FROM Sequence_Number__c WHERE Name = 'Claim Number' FOR UPDATE]; 
        List<String> result = new List<String>();
        system.debug('sn: ' + seqNumber);
        if (seqNumber.Date__c < Date.today()) {
            seqNumber.Number__c = 0;
            seqNumber.Source_Number__c = 2;
            seqNumber.Date__c = Date.today();
        }
        for(integer i = 0;i<num;i++){
            if(seqNumber.Number__c == 9999){
                if(seqNumber.Source_Number__c == 9){
                    //we are out of source numbers
                    //what do we do here?
                    throw new ClaimException('Total available claim numbers exceeded.');
                } else {
                    //iterate the source number
                    seqNumber.Number__c = 1;
                    seqNumber.Source_Number__c += 1;
                }
            } else {
                seqNumber.Number__c += 1;
            }
            String sourceNum = string.valueOf(seqNumber.Source_Number__c).leftPad(2,'0');
            string seqNum = string.valueOf(seqNumber.Number__c).leftPad(4,'0');
            String numResult = buildDateString() + sourceNum + seqNum + STARTING_SUFFIX;
            system.debug('numResult ' + num + ' : ' + numResult);
            result.add(numResult);
        }
        
        
        
        update seqNumber;
        
        
        return result;
    }
    /*
    * @description
    * Build the date portion of the claim or referral number
    * pulled from org1
    * @return String containing year followed by day of year
    */
    public static String buildDateString() {
        Date today = Date.today();
        String year = String.valueOf(today.year());
        String dayOfYear = String.valueOf(today.dayOfYear()).leftPad(3,'0');
        return year + dayOfYear;
    }

}