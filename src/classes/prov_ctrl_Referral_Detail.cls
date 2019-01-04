global with sharing class prov_ctrl_Referral_Detail {


    public String portalURL {get;set;}

    public prov_ctrl_Referral_Detail(){
        portalURL = System.Label.Member_Eligibility_VF_URL;
    }

    @RemoteAction
    global static object getRefDetailRemote(String str){
        //rehydrate the JSON

        prov_Wrap_Claim.ReferralDetailRequestWrapper claimDetail = (prov_Wrap_Claim.ReferralDetailRequestWrapper) System.JSON.deserialize(str,prov_Wrap_Claim.ReferralDetailRequestWrapper.class);

		
      
        prov_Wrap_Claim.ReferralDetailResultWrapper resWrapper = new prov_Wrap_Claim.ReferralDetailResultWrapper();
	
            RefDetailCalloutWrapper wrap = new RefDetailCalloutWrapper();
            HTTPRequest request = wrap.retrieveRecords_continuation(claimDetail);
            //Create a continuation for HTTPRequest
            Continuation con = new Continuation(60);
            con.state = con.addHttpRequest(request);
            con.continuationMethod = 'callback';
            return con;

    }

    @RemoteAction
    global static object getRefAttachmentsRemote(String str){

         prov_Wrap_Claim.ClaimDetailAttachmentRequestWrapper claimAttachRequest = (prov_Wrap_Claim.ClaimDetailAttachmentRequestWrapper) System.JSON.deserialize(str,prov_Wrap_Claim.ClaimDetailAttachmentRequestWrapper.class);

            RefAttachmentsCalloutWrapper wrap = new RefAttachmentsCalloutWrapper();
            HTTPRequest request = wrap.retrieveAttachmentRecords_continuation(claimAttachRequest);
            //Create a continuation for HTTPRequest
            Continuation con = new Continuation(60);
            con.state = con.addHttpRequest(request);
            con.continuationMethod = 'attachmentListcallback';
            return con;


    }

    @RemoteAction
    global static object getAttachRemote(String str){

        Global_Configuration__c calloutEndpoint = Global_Configuration__c.getInstance('AttachmentCalloutEndpoint');
            Global_Configuration__c calloutUsername = Global_Configuration__c.getInstance('PCDRequestUsername');
            Global_Configuration__c calloutPassword = Global_Configuration__c.getInstance('PCDRequestPassword');
                //setup basic auth
                Blob headerValue = Blob.valueOf(calloutUsername.value__c +':' +calloutPassword.value__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('get link: ' + str);


        HttpRequest request = new HttpRequest();

        request.setEndpoint(str);
        request.setMethod('GET');
        request.setTimeout(20000);
        request.setCompressed(false);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);

        //create a continuation for callout
        Continuation con = new Continuation(20);
        String requeststr = con.addHttpRequest(request);
        con.state = requeststr;
        con.continuationMethod = 'attachCallback';
        return con;    
    }

    global static object attachCallback(Object state) {
        System.debug('in attachCallback');

        HttpResponse res; 

        if(!Test.isRunningTest()){
            res = Continuation.getResponse((String) state);
            System.debug('response ' + res);
            System.debug('response ' + res.getBody());
        } else {
            //make httpResponse here
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[{"FirstName":"Success","LastName":"Success"}]');
        }

        //200 code is good, all others is error
        if(res.getStatusCode()!=200){
            system.debug('--EOB Request -------------------------------------------------------------------------');
            system.debug('Response failed.');
            system.debug(res.getStatusCode());
            system.debug(res.getBody());
            system.debug('--EOB Request-------------------------------------------------------------------------');
            return null;
        } else {
            string enstr = EncodingUtil.base64Encode(res.getBodyAsBlob());

            //return response as string
            return enstr;
        }
    }

    global static object callback(Object state){

        System.debug('in callback');

        HttpResponse res;

        if(!Test.isRunningTest()){

            res = Continuation.getResponse((String) state);
            System.debug('response ' + res);
            System.debug('response ' + res.getBody());

        }else{
                res = new HttpResponse();
                res.setStatusCode(200);
                res.setBody('{"Claim":{"Header":{"ReasonForDenial":"","RouteId":"GOV","ClaimGuid":"cf3b3e7b-ffbb-4f81-aef9-0079964ee730","ClaimType":"Referral","ClaimNumber":"101212540890500","SubmittedDate":"2013-05-07T00:00:00","ExpirationDate":"2014-02-01T00:00:00","ReferralTypeCode":"S","ReferralType":"Standard","VoidReasonCode":"","PatientFirstName":"Alexandra","PatientLastName":"Barton","PatientBirthDate":"2009-12-07T00:00:00","SubmittedMemberId":"131384138","PlanName":"TX Med Child","BusinessName":"Morgan Burns","BusinessNpi":"","ServiceOfficeGuid":"7464bc3c-9813-4321-af17-834a75e9241b","ServiceOfficeName":"Addison Herring","ServiceLocationNpi":"","TreatingProviderGuid":"d2c046f1-6629-4f88-840e-6306a3b70f48","ProviderLastName":"Crawford","ProviderFirstName":"Gianna","ProviderNpi":"","ProviderAddress1":"Oak Avenue","ProviderAddress2":"","ProviderCity":"STEPHENVILLE","ProviderState":"TX","ProviderZipCode":"76401","Notes":""},"Referral":{"StatusCategory":null,"Approved":"Yes","RequestedProviderFirstName":"Nicolas","RequestedProviderLastName":"Green","RequestedProviderAddress1":"8th Street West","RequestedProviderAddress2":"","RequestedProviderCity":"BELLMEAD","RequestedProviderState":"TX","RequestedProviderZipcode":"76705","RequestedProviderPhoneNumber":"6308745386","RequestedProviderGuid":"d34cba05-7a8f-4185-a08f-9005ac3a906a","RequestedServiceOfficeLocationGuid":"800f8975-981a-41b4-b7c2-87cbd36e4bbe","RequestedBusinessGuid":"e40f7f18-3ca3-40d6-ba19-fe554901e7d0","FinalDeterminationDateTime":null,"ReferralExpirationDate":"2014-02-01T00:00:00","SpecialtyTypeCode":"30","SpecialtyType":"Pediatric Dentist","DeterminationReason":"","MemberContacted":"No"}},"QueryTotalTimeMs":1075}');

        }
                                
        if(res.getStatusCode()!=200){
                system.debug('-- Search Request-------------------------------------------------------------------------');
                system.debug('Response failed.');
                system.debug(res.getStatusCode());
                system.debug(res.getBody());
                system.debug('--Ref Detail Search Request-------------------------------------------------------------------------');
                  String str = '[{"FirstName":"Error","LastName":"timeout"}]';
                return (Object) str; 
        } else {
                prov_Wrap_Claim.ReferralDetailResultWrapper refDetail = (prov_Wrap_Claim.ReferralDetailResultWrapper) System.JSON.deserialize(res.getBody(),prov_Wrap_Claim.ReferralDetailResultWrapper.class);

                    String refDetailResult = JSON.serialize(refDetail); 
                    System.debug('ref detail results: ' + refDetailResult);
                    return (Object)refDetailResult; 

        }
        
    }

    global static object attachmentListcallback(Object state){
        System.debug('in callback');

        HttpResponse res;

        if(!Test.isRunningTest()){

            res = Continuation.getResponse((String) state);
            System.debug('response ' + res);
            System.debug('response ' + res.getBody());

        }else{
                res = new HttpResponse();
                res.setStatusCode(200);
                res.setBody('[{"DocumentId":"Unknown","AttachmentId":"38357fec-7149-4655-9ae1-401f0038f643","FileExtension":".JPG","OriginalFileName":"PHOTOS.JPG","ClaimNumber":"201704600338500","ServiceOfficeGuid":"8f5253f4-65f8-45b9-88a4-47dd5c91183a","DocumentTypeDescription":"RR","Created":"2017-02-15T14:16:32.7127249","InWindward":true,"InDocumentDirect":true,"AttachmentLink":""},{"DocumentId":"Unknown","AttachmentId":"bda47dd8-865d-467c-886e-4bf5caca4c13","FileExtension":".pdf","OriginalFileName":"DANIEL HLD FORM.pdf","ClaimNumber":"201704600338500","ServiceOfficeGuid":"8f5253f4-65f8-45b9-88a4-47dd5c91183a","DocumentTypeDescription":"EB","Created":"2017-02-15T14:16:35.4895605","InWindward":true,"InDocumentDirect":true,"AttachmentLink":""},{"DocumentId":"Unknown","AttachmentId":"d98b10aa-b015-4e86-958a-ab08a47fcdff","FileExtension":".jpg","OriginalFileName":"CEPH.jpg","ClaimNumber":"201704600338500","ServiceOfficeGuid":"8f5253f4-65f8-45b9-88a4-47dd5c91183a","DocumentTypeDescription":"RB","Created":"2017-02-15T14:16:20.1701641","InWindward":true,"InDocumentDirect":true,"AttachmentLink":""},{"DocumentId":"Unknown","AttachmentId":"7f87479a-e698-4183-be9a-ee81dbdcc638","FileExtension":".jpg","OriginalFileName":"PAN.jpg","ClaimNumber":"201704600338500","ServiceOfficeGuid":"8f5253f4-65f8-45b9-88a4-47dd5c91183a","DocumentTypeDescription":"RB","Created":"2017-02-15T14:16:28.1730667","InWindward":true,"InDocumentDirect":true,"AttachmentLink":""}]');
        
        }
                                
        if(res.getStatusCode()!=200){
                system.debug('-- Search Request-------------------------------------------------------------------------');
                system.debug('Response failed.');
                system.debug(res.getStatusCode());
                system.debug(res.getBody());
                system.debug('--Claim Detail Search Request-------------------------------------------------------------------------');
                  String str = '[{"FirstName":"Error","LastName":"timeout"}]';
                return (Object) str; 
        } else {

            List<prov_wrap_Claim.ClaimDetailResponseAttachWrapper> wrapperList = (List<prov_wrap_Claim.ClaimDetailResponseAttachWrapper>) System.JSON.deserialize(res.getBody(),List<prov_wrap_Claim.ClaimDetailResponseAttachWrapper>.class);

            System.debug('wrapper List' + wrapperList);

            String claimAttachmentsResult = JSON.serialize(wrapperList); 
            System.debug('claim attachmentsresults: ' + claimAttachmentsResult);
            return claimAttachmentsResult; 

        }
       
    }

    @RemoteAction
    global static object afterResponseLogic(String response){


        prov_wrap_Claim.ReferralDetailResultWrapper claimDetailWrapper = (prov_wrap_Claim.ReferralDetailResultWrapper) System.JSON.deserialize(response,prov_wrap_Claim.ReferralDetailResultWrapper.class);

        
            
		system.debug('result' + claimDetailWrapper);
       return claimDetailWrapper;
    }

    public class RefDetailCalloutWrapper{

        public String BusinessId {get;set;}
        public String ClaimRecNum {get;set;}
        public String BusinessGuid {get;set;}
        
        
        public RefDetailCalloutWrapper(){
            
        }
        

        public HttpRequest retrieveRecords_continuation(prov_Wrap_Claim.ReferralDetailRequestWrapper claimRequest){
            System.debug('prov_util_MockData.useMockData::'+prov_util_MockData.useMockData);
            Global_Configuration__c calloutEndpoint = Global_Configuration__c.getInstance('ReferralDetailRequestEndpoint');
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
                System.debug('calloutEndpoint::'+calloutEndpoint.Value__c);
                HTTP h = new HTTP();
                HTTPRequest req = new HTTPRequest();
                //req.setEndpoint(calloutEndpoint.Value__c);

                req.setEndpoint(calloutEndpoint.Value__c);
                req.setMethod('POST');
                req.setTimeout(60000);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', authorizationHeader);
                String payload = JSON.serialize(claimRequest);
                system.debug('Payload: ');
                system.debug(payload);
                req.setBody(payload);
                
                return req;  
                
            } else {
                system.debug('--Claim Detail  Request-------------------------------------------------------------------------');
                system.debug('No valid endpoint in the setting.');
                system.debug('--Claim Detail  Request-------------------------------------------------------------------------');
                return null;
            } 
        }
    }

    public class RefAttachmentsCalloutWrapper{

        public String RouteId {get;set;}
        public String ClaimRecNum {get;set;}
        
        
        
        public RefAttachmentsCalloutWrapper(){
            
        }
        

        public HttpRequest retrieveAttachmentRecords_continuation(prov_Wrap_Claim.ClaimDetailAttachmentRequestWrapper attachRequest){
            System.debug('prov_util_MockData.useMockData::'+prov_util_MockData.useMockData);
            Global_Configuration__c calloutEndpoint = Global_Configuration__c.getInstance('claimAttachCalloutEndpoint');
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
                System.debug('calloutEndpoint::'+calloutEndpoint.Value__c);

                HTTPRequest req = new HTTPRequest();
                //req.setEndpoint(calloutEndpoint.Value__c);
                String endpointStr = calloutEndpoint.Value__c + '?ClaimNumber=' + attachRequest.ClaimNumber + '&routeId=' +  attachRequest.RouteId;
                req.setEndpoint(endpointStr);
                req.setMethod('GET');
                req.setTimeout(60000);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', authorizationHeader);
                String payload = JSON.serialize(attachRequest);
                system.debug('Payload: ');
                system.debug(payload);
                req.setBody(payload);
                
                return req;  
                
            } else {
                system.debug('--Claim Attachments  Request-------------------------------------------------------------------------');
                system.debug('No valid endpoint in the setting.');
                system.debug('--Claim Attachments  Request-------------------------------------------------------------------------');
                return null;
            } 
        }
    }

  static final String days = Global_Configuration__c.getInstance('ClaimDeleteDelayDays').value__c;

  @AuraEnabled
    public static String getNumberOfDays(){
        String numDays = days;

        return numDays;
    }

	//retreive pre-authorization details from Salesforce if the pre-authorization ID is not in windward
	@auraEnabled
	public static prov_wrap_Claim.ReferralDetailResultClaimWrapper getReferralRecSFDCDetails(String claimId){
    system.debug('claimId :::' + claimId);
		
		Claim__c claim = [SELECT Id, Name, Business__r.Name, Business__r.guid__c, Service_Location__r.guid__c, Patient_First_Name__c, Patient_Last_Name__c, Patient_Birth_Date__c, Claim_Number__c, Submitted_DateTime__c,
                         Subscriber_ID__c, Claim_Type__c, Plan__r.Name, Treating_Provider_First_Name__c, Treating_Provider_Last_Name__c, Treating_Provider_Address1__c,
                         Treating_Provider_City__c, Treating_Provider_State__c, Service_Location__r.Name, Treating_Provider_Zip__c, Provider__r.tax_id_number__c,Business__r.npi__c,Service_Location__r.npi__c,Provider__r.npi__c,
                         Place_of_Treatment_Desc__c , Referral_Treating_Provider_Name__c, Office_Reference_Number__c, Referral_Number__c, Diagnosis_Code_A__c, Claim_Draft_Status__c, 
                         Requested_Specialty__c, Service_Location_Phone__c, toLabel(Type_of_Referral__c),  Remarks2__c, Referral_Treating_Provider_First_Name__c, Referral_Treating_Provider_Last_Name__c,
                         Diagnosis_Code_B__c,Diagnosis_Code_C__c,Referral_Service_Location_Address__c, Referral_Treating_Provider_City__c, Referral_Treating_Provider_State__c, Referral_Treating_Provider_Zip__c,Diagnosis_Code_D__c, Internal_Care_Transfer__c, Provider__r.guid__c, (select id, Original_File_Name__c, CreatedDate from Claim_Attachments__r) FROM Claim__c Where id = :claimId];

        system.debug(claim.Referral_Treating_Provider_First_Name__c);
        system.debug(claim.Referral_Treating_Provider_Last_Name__c);
        

        prov_wrap_Claim.ReferralDetailResultClaimWrapper refDetailWrapper = new prov_wrap_Claim.ReferralDetailResultClaimWrapper();
        //populate claim detail wrapper based on field values in salesforce claim and associated records
                refDetailWrapper.Header.BusinessName = claim.Business__r.Name;
                refDetailWrapper.Header.PatientFirstName = claim.Patient_First_Name__c;
                refDetailWrapper.Header.PatientLastName = claim.Patient_Last_Name__c;
                refDetailWrapper.Header.PatientBirthDate = claim.Patient_Birth_Date__c;
                refDetailWrapper.Header.SubmittedMemberId = claim.Subscriber_ID__c;
                refDetailWrapper.Header.BusinessGuid = claim.Business__r.guid__c;
                refDetailWrapper.Header.ServiceOfficeGuid = claim.Service_Location__r.guid__c;
                refDetailWrapper.Header.TreatingProviderGuid = claim.Provider__r.guid__c;
                refDetailWrapper.Header.planName = claim.Plan__r.Name;
                refDetailWrapper.Header.providerFirstName = claim.Treating_Provider_First_Name__c;
                refDetailWrapper.Header.providerLastName = claim.Treating_Provider_Last_Name__c;
                refDetailWrapper.Header.providerAddress1 = claim.Treating_Provider_Address1__c;
                refDetailWrapper.Header.providerCity = claim.Treating_Provider_City__c;
                refDetailWrapper.Header.providerState = claim.Treating_Provider_State__c;
                refDetailWrapper.Header.providerZipCode = claim.Treating_Provider_Zip__c;
                refDetailWrapper.Header.providerTIN = claim.Provider__r.tax_id_number__c;
                refDetailWrapper.Header.PlaceOfTreatment = claim.Place_of_Treatment_Desc__c ;
                refDetailWrapper.Header.OfficeReferenceNumber = claim.Office_Reference_Number__c;
                refDetailWrapper.Header.ReferralNumber = claim.Referral_Number__c;
                refDetailWrapper.Header.icdCode1 = claim.Diagnosis_Code_A__c;
                refDetailWrapper.Header.icdCode2 = claim.Diagnosis_Code_B__c;
                refDetailWrapper.Header.icdCode3 = claim.Diagnosis_Code_C__c;
                refDetailWrapper.Header.icdCode4 = claim.Diagnosis_Code_D__c;
                refDetailWrapper.Header.notes = claim.Remarks2__c;
                refDetailWrapper.Header.ClaimNumber = claim.Claim_Number__c;
                refDetailWrapper.Header.SubmittedDate = claim.Submitted_DateTime__c;
                refDetailWrapper.Header.ClaimTypeCategory = claim.Claim_Type__c;
                refDetailWrapper.Header.ServiceOfficeName = claim.Service_Location__r.Name;

                refDetailWrapper.Referral.StatusCategory = claim.Claim_Draft_Status__c;
                refDetailWrapper.Header.RequestedSpecialty =  claim.Requested_Specialty__c;
                refDetailWrapper.Header.ReferralType = claim.Type_of_Referral__c;
                refDetailWrapper.Header.IsInternalCareTransfer = claim.Internal_Care_Transfer__c;
                refDetailWrapper.Header.BusinessNpi = claim.Business__r.npi__c;
                refDetailWrapper.Header.ServiceLocationNpi = claim.Service_Location__r.npi__c;
                refDetailWrapper.Header.ProviderNpi = claim.Provider__r.npi__c;

                refDetailWrapper.Referral.RequestedProviderName = claim.Referral_Treating_Provider_Name__c;

                refDetailWrapper.Referral.RequestedProviderPhoneNumber = claim.Service_Location_Phone__c;
                refDetailWrapper.Referral.RequestedProviderAddress1 = claim.Referral_Service_Location_Address__c;
                refDetailWrapper.Referral.RequestedProviderCity = claim.Referral_Treating_Provider_City__c;
                refDetailWrapper.Referral.RequestedProviderState = claim.Referral_Treating_Provider_State__c;
                refDetailWrapper.Referral.RequestedProviderZipcode = claim.Referral_Treating_Provider_Zip__c;
              

                Set<Id> claimAttachIdSet = new Set<Id>();
                for(Claim_Attachment__c a : claim.Claim_Attachments__r){
                    claimAttachIdSet.add(a.Id);
                }

                List<Attachment> attachments = [SELECT Id, Name, ParentId, CreatedDate FROM Attachment WHERE ParentId IN :claimAttachIdSet];

                //Attachments
                for(Attachment a : attachments){
                    system.debug('attachment : ' + a);
                    prov_wrap_Claim.ClaimDetailResponseAttachWrapper attach = new prov_wrap_Claim.ClaimDetailResponseAttachWrapper();
                    attach.OriginalFileName = a.Name;
                    attach.AttachmentId = a.Id;
                    attach.CreatedDate = a.CreatedDate;
                    refDetailWrapper.Header.Attachments.add(attach);
                    system.debug('attachment ::' +attach);
                }

        system.debug(refDetailWrapper.Referral.RequestedProviderName);
        return refDetailWrapper;
	}	

	

	//method gets list of referrals for confirmation report
    @auraEnabled
    public static List<prov_wrap_Claim.ClaimDetailResultClaimWrapper> retreiveReferralsReport(String filterDate, String businessId){

        Date dateVal;
        if(filterDate != null){

        dateVal = date.parse(filterDate);
        }

        //include end date and start date ranges
        Date laterDate = dateVal.addDays(1); 

        system.debug(dateVal);

        system.debug('here');
        //query submitted pre-auth based on submission date passing into the method
        List<prov_wrap_Claim.ClaimDetailResultClaimWrapper> refReportList = new  List<prov_wrap_Claim.ClaimDetailResultClaimWrapper>();
        List<Claim__c> refList = new List<Claim__c>();
        
        
        refList = [SELECT Id, Name, Claim_Number__c,Submitted_DateTime__c, Patient_First_Name__c, Patient_Last_Name__c,
            Patient_Birth_Date__c, Subscriber_ID__c, Plan__r.Name, Treating_Provider_First_Name__c, Treating_Provider_Last_Name__c,Treating_Provider_Address1__c,
                         Treating_Provider_City__c, Treating_Provider_State__c, Treating_Provider_Zip__c, Provider__r.tax_id_number__c, Business__r.Name,
                         Place_of_Treatment_Desc__c , Office_Reference_Number__c, Referral_Number__c,Claim_Draft_Status__c, Total_Billed_Amount__c,
                         Diagnosis_Code_A__c, Diagnosis_Code_B__c, Diagnosis_Code_C__c, Diagnosis_Code_D__c,Referral_Treating_Provider_Name__c,
                         Service_Location_Phone__c, Referral_Service_Location_Address__c, Service_Location__r.Name, Referral_Treating_Provider_City__c, Referral_Treating_Provider_State__c, Referral_Treating_Provider_Zip__c,
                         Business__r.npi__c, Service_Location__r.npi__c, Provider__r.npi__c,Remarks2__c,Internal_Care_Transfer__c,
                   Requested_Specialty__c, Type_of_Referral__c
                         FROM Claim__c WHERE Claim_type__c = 'REFERRAL' AND Submitted_DateTime__c >= :dateVal AND Submitted_DateTime__c < :laterDate AND Claim_Draft_Status__c = 'SUBMITTED' AND Business__c = :businessId ORDER BY Claim_Number__c DESC];
        
                         system.debug(refList);

        for(Claim__c ref :refList){
            prov_wrap_Claim.ClaimDetailResultClaimWrapper claimResponse = new prov_wrap_Claim.ClaimDetailResultClaimWrapper();
                claimResponse.Header.ClaimId = ref.Id;
                claimResponse.Header.ClaimId = ref.Id;
                claimResponse.Header.ClaimNumber = ref.Claim_Number__c;
                claimResponse.Header.StatusCategory = ref.Claim_Draft_Status__c;
                claimResponse.Header.SubmittedDate = ref.Submitted_DateTime__c;
                claimResponse.Header.PatientFirstName = ref.Patient_First_Name__c;
                claimResponse.Header.PatientLastName = ref.Patient_Last_Name__c;
                claimResponse.Header.PatientBirthDate =  ref.Patient_Birth_Date__c;
                claimResponse.Header.SubmittedMemberId =  ref.Subscriber_ID__c;
                claimResponse.Header.PlanName = ref.Plan__r.Name;
                claimResponse.Header.BusinessName = ref.Business__r.Name;
                claimResponse.Header.ProviderFirstName = ref.Treating_Provider_First_Name__c;
                claimResponse.Header.ProviderLastName = ref.Treating_Provider_Last_Name__c;
                claimResponse.Header.ProviderAddress1 = ref.Treating_Provider_Address1__c;
                claimResponse.Header.ProviderCity = ref.Treating_Provider_City__c;
                claimResponse.Header.ProviderState = ref.Treating_Provider_State__c;
                claimResponse.Header.ProviderZipCode = ref.Treating_Provider_Zip__c;
                claimResponse.Header.ProviderTIN = ref.Provider__r.tax_id_number__c;
                claimResponse.Header.PlaceOfTreatment = ref.Place_of_Treatment_Desc__c ;
                claimResponse.Header.OfficeReferenceNumber = ref.Office_Reference_Number__c;
                claimResponse.Header.ReferralNumber = ref.Referral_Number__c;
                claimResponse.Header.ServiceOfficeName = ref.Service_Location__r.Name;
                claimResponse.Header.IcdCode1 = ref.Diagnosis_Code_A__c;
                claimResponse.Header.IcdCode2 = ref.Diagnosis_Code_B__c;
                claimResponse.Header.IcdCode3 = ref.Diagnosis_Code_C__c;
                claimResponse.Header.IcdCode4 = ref.Diagnosis_Code_D__c;
                claimResponse.Header.BusinessNpi = ref.Business__r.npi__c;
                claimResponse.Header.ServiceLocationNpi = ref.Service_Location__r.npi__c;
                claimResponse.Header.ProviderNpi = ref.Provider__r.npi__c;
                claimResponse.Header.Notes = ref.Remarks2__c;
                claimResponse.Header.IsInternalCareTransfer = ref.Internal_Care_Transfer__c;
                claimResponse.Header.RequestedSpecialty =  ref.Requested_Specialty__c;
                claimResponse.Header.ReferralType = ref.Type_of_Referral__c;
                claimResponse.Header.ApprovedProvider = ref.Referral_Treating_Provider_Name__c;
                claimResponse.Header.ApprovedProviderPhone = ref.Service_Location_Phone__c;
                claimResponse.Header.ApprovedProviderAddress = ref.Referral_Service_Location_Address__c + ' ' + ref.Referral_Treating_Provider_City__c + ', ' + ref.Referral_Treating_Provider_State__c + ' ' + ref.Referral_Treating_Provider_Zip__c;

                system.debug('provider name' + ref.Referral_Treating_Provider_Name__c);
                system.debug('provider name' + claimResponse.Header.ApprovedProvider);

            refReportList.add(claimResponse);
        }


        system.debug(refReportList);
        return refReportList;
    }
}