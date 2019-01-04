global without sharing class prov_util_MemberEligibilityCallout {

    
    /*************************************************************************************************
    ***************************************Search criteria wrapper********************************************
    **************************************************************************************************/
    public class CriteriaElementWrap{
        public String MemberId {get;set;}
        public String LastName {get;set;}
        public String FirstName {get;set;}
        public Date DateOfService {get;set;}
        public Date DateOfBirth {get;set;}
        
        public CriteriaElementWrap(Prov_ctrl_MemberEligibility.MemberWrapper criteria){
            DateOfBirth = criteria.birthDate;
            DateOfService = criteria.serviceDate;
            FirstName = criteria.firstName;
            LastName = criteria.lastName;
            MemberId = criteria.memberNumber;
        }
    }
    
    
    /*************************************************************************************************
    **************************************CALLOUT WRAPPER********************************************
    **************************************************************************************************/
    
    public class CalloutWrapper{
        public List<CriteriaElementWrap> MemberEligibilityRequests {get;set;}
        
        public CalloutWrapper(){
            //intialzie the wrapper
            MemberEligibilityRequests = new List<CriteriaElementWrap>();
        }
    } 
    
    /*************************************************************************************************
    ***************************************CALLOUT WRAPPER********************************************
    **************************************************************************************************/
    public class HTTPResponseWrap{
        public String MemberCoverageGuid {get;set;}
        public String RouteId {get;set;}
        public String MemberProfileGuid {get;set;}
        public String SubscriberProfileGuid {get;set;}
        public String MedicaidId {get;set;}
        public String SubscriberId {get;set;}
        public String CoverageLevel {get;set;}
        public String PlanGuid {get;set;}
        public String PlanId {get;set;}
        public String PlanName {get;set;}
        public String AidCategory {get;set;}
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String ProviderGuid {get;set;}
        public String ServiceLocationGuid {get;set;}
        public String UniversalMemberGuid {get;set;}
        public Datetime EffectiveDate {get;set;}
        public Datetime TerminationDate {get;set;}
        public Datetime DateOfBirth {get;set;}
        public Integer CoverageRank {get;set;}

        //convert the wrapper class into the member coverage record
        public mock_MemberCoverage__c covertToMemberCoverage(){
            mock_MemberCoverage__c memCov = new mock_MemberCoverage__c();
            
            //set the fields
            if(AidCategory != null)
                memCov.AidCategory__c = AidCategory;
            if(DateOfBirth != null)
                memCov.Birthdate__c =  DateOfBirth.dateGMT();
            memCov.MemberCoverageGuid__c = this.MemberCoverageGuid;
            memCov.RouteId__c = this.RouteId;
            memCov.MemberProfileGuid__c = this.MemberProfileGuid;
            memCov.SubscriberProfileGUID__c = this.SubscriberProfileGuid;
            
            memCov.MedicaidId__c = this.MedicaidId;
            memCov.SubscriberId__c = this.SubscriberId;
            memCov.CoverageLevelCode__c = this.CoverageLevel;
            memCov.PlanGuid__c = this.PlanGuid;
            memCov.FirstName__c = this.FirstName;
            memCov.LastName__c = this.LastName;
            memCov.UniversalMemberGuid__c = this.UniversalMemberGuid;
             if(this.EffectiveDate != null)
                memCov.EffectiveDate__c = date.newinstance(EffectiveDate.yearGmt(), EffectiveDate.monthGmt(), EffectiveDate.dayGmt());
            if(this.TerminationDate != null){
                memCov.TerminationDate__c = date.newinstance(TerminationDate.yearGmt(), TerminationDate.monthGmt(), TerminationDate.dayGmt());
            }
           memCov.PlanName__c = this.PlanName;
            memCov.ProviderGUID__c = this.ProviderGuid;
            memCov.ServiceLocationGUID__c = this.ServiceLocationGuid;
            //return the record
            return memCov;
        }
    }
    
    public static  HTTPRequest                                     getPayload(List<Prov_ctrl_MemberEligibility.MemberWrapper> criteriaList, String businessId){
        System.debug('Entering requestMemberEligibilityInfo...');
        //initialize the variables
        try{
            if(criteriaList != null && criteriaList.size()> 0){
                CalloutWrapper memEligWrapper = new CalloutWrapper();
                
                //get userVerification records for the associated contactIds
                //get variables
                for( Prov_ctrl_MemberEligibility.MemberWrapper memWrap : criteriaList){
                    memEligWrapper.MemberEligibilityRequests.add( new CriteriaElementWrap(memWrap) );
                } 

                System.debug('memEligWrapper.MemberEligibilityRequests::'+memEligWrapper.MemberEligibilityRequests);
                System.debug('prov_util_MockData.useMockData::'+prov_util_MockData.useMockData);
                Global_Configuration__c calloutEndpoint = Global_Configuration__c.getInstance('EligibilityRequestEndpoint');
                Global_Configuration__c calloutUsername = Global_Configuration__c.getInstance('PCDRequestUsername');
                Global_Configuration__c calloutPassword = Global_Configuration__c.getInstance('PCDRequestPassword');
                if(String.IsNotBlank(calloutEndpoint.value__c) && calloutEndpoint.value__c!='null' 
                   && String.IsNotBlank(calloutUsername.value__c) && calloutUsername.value__c!='null'
                   && String.IsNotBlank(calloutPassword.value__c) && calloutPassword.value__c!='null'){
                    //setup basic auth
                    Blob headerValue = Blob.valueOf(calloutUsername.value__c +':' +calloutPassword.value__c);
                    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    //make a callout to WW to submit the request
                    System.debug('headerValue::'+calloutUsername.value__c +':' +calloutPassword.value__c);
                    System.debug('calloutEndpoint::'+calloutEndpoint);
                    HTTP h = new HTTP();
                    HTTPRequest req = new HTTPRequest();
                    req.setEndpoint(calloutEndpoint.value__c);
                    req.setMethod('POST');
                    req.setTimeout(10000);
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Authorization', authorizationHeader);
                    String payload = JSON.serialize(memEligWrapper);
                    system.debug('Payload: ');
                    system.debug(payload);
                    req.setBody(payload);
                    
                  return req;


                } else {
                    system.debug('--PMember Eligibility Search Request-------------------------------------------------------------------------');
                    system.debug('No valid endpoint in the setting.');
                    system.debug('--Member Eligibility Search Request-------------------------------------------------------------------------');
                } 
            }
        } catch (exception ex){
            system.debug('--Member Eligibility Search Request-------------------------------------------------------------------------');
            //system.debug('Member Eligibility Search : ' + memEligWrapper);
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            system.debug('--Member Eligibility Search Request-------------------------------------------------------------------------');
            
            //not move to results - error/ delay. need to rerun
        }
        return null;
    }

    public static  List<mock_MemberCoverage__c>                                      requestMemberEligibilityInfo(List<Prov_ctrl_MemberEligibility.MemberWrapper> criteriaList, String businessId){
        System.debug('Entering requestMemberEligibilityInfo...');
        //initialize the variables
        List<mock_MemberCoverage__c> result = new List<mock_MemberCoverage__c>();
        try{
            if(criteriaList != null && criteriaList.size()> 0){
                CalloutWrapper memEligWrapper = new CalloutWrapper();
                
                //get userVerification records for the associated contactIds
                //get variables
                //String routeId = PortalConfiguration.RouteID__c;
               for( Prov_ctrl_MemberEligibility.MemberWrapper memWrap : criteriaList){
                    memEligWrapper.MemberEligibilityRequests.add( new CriteriaElementWrap(memWrap) );
               } 
                System.debug('memEligWrapper.MemberEligibilityRequests::'+memEligWrapper.MemberEligibilityRequests);
                if(prov_util_MockData.useMockData){
                    //we are in test or dev, do not make the callout
                    return prov_util_DAL.getMemberCoverageByNameBirthdateMemberNumber(criteriaList, businessId); 
                } else {
                    System.debug('prov_util_MockData.useMockData::'+prov_util_MockData.useMockData);
                    Global_Configuration__c calloutEndpoint = Global_Configuration__c.getInstance('EligibilityRequestEndpoint');
                    Global_Configuration__c calloutUsername = Global_Configuration__c.getInstance('PCDRequestUsername');
                    Global_Configuration__c calloutPassword = Global_Configuration__c.getInstance('PCDRequestPassword');
                    if(String.IsNotBlank(calloutEndpoint.value__c) && calloutEndpoint.value__c!='null' 
                       && String.IsNotBlank(calloutUsername.value__c) && calloutUsername.value__c!='null'
                       && String.IsNotBlank(calloutPassword.value__c) && calloutPassword.value__c!='null'){
                        //setup basic auth
                        Blob headerValue = Blob.valueOf(calloutUsername.value__c +':' +calloutPassword.value__c);
                        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                        //make a callout to WW to submit the request
                        System.debug('headerValue::'+calloutUsername.value__c +':' +calloutPassword.value__c);
                        System.debug('calloutEndpoint::'+calloutEndpoint);
                        HTTP h = new HTTP();
                        HTTPRequest req = new HTTPRequest();
                        req.setEndpoint(calloutEndpoint.value__c);
                        req.setMethod('POST');
                        req.setTimeout(10000);
                        req.setHeader('Content-Type', 'application/json');
                        req.setHeader('Authorization', authorizationHeader);
                        String payload = JSON.serialize(memEligWrapper);
                        system.debug('Payload: ');
                        system.debug(payload);
                        req.setBody(payload);
                           
                        HTTPResponse res = h.send(req);
                        //check for the response
                        system.debug('Member Eligibility ResponseCode: ' + res.getStatusCode());
                        if(res.getStatusCode()!=200){
                            system.debug('--Member Eligibility Search Request-------------------------------------------------------------------------');
                            system.debug('Response failed.');
                            system.debug(res.getStatusCode());
                            system.debug(res.getBody());
                            system.debug('--Member Eligibility Search Request-------------------------------------------------------------------------');
                            result.add(new mock_MemberCoverage__c(FirstName__c = 'Error', LastName__c = 'timeout') );
                            return result; 
                        } else {
                            system.debug('Member Eligibility Body: ' + res.getBody());
                            
                            List<HTTPResponseWrap> responseList = ( List<HTTPResponseWrap>)JSON.deserialize(res.getBody(), List<HTTPResponseWrap>.class);
                            System.debug('result::'+responseList);
                            
                            for(HTTPResponseWrap respWrap : responseList){
                                result.add( respWrap.covertToMemberCoverage() );
                            }
                            return result;
                        }
                    } else {
                        system.debug('--PMember Eligibility Search Request-------------------------------------------------------------------------');
                        system.debug('No valid endpoint in the setting.');
                        system.debug('--Member Eligibility Search Request-------------------------------------------------------------------------');
                    } 
                }
            }
        } catch (exception ex){
            system.debug('--Member Eligibility Search Request-------------------------------------------------------------------------');
            //system.debug('Member Eligibility Search : ' + memEligWrapper);
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            system.debug('--Member Eligibility Search Request-------------------------------------------------------------------------');
            
            //not move to results - error/ delay. need to rerun
        }
        return result;
    }
}