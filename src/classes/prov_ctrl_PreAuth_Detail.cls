global without sharing class prov_ctrl_PreAuth_Detail {

   public String portalURL {get;set;}
    

    public prov_ctrl_PreAuth_Detail(){
        portalURL = System.Label.Member_Eligibility_VF_URL;
    }

    @RemoteAction
    global static object getPreAuthDetailRemote(String str){
        //rehydrate the JSON

        prov_Wrap_Claim.ClaimDetailRequestWrapper claimDetail = (prov_Wrap_Claim.ClaimDetailRequestWrapper) System.JSON.deserialize(str,prov_Wrap_Claim.ClaimDetailRequestWrapper.class);


        
        prov_Wrap_Claim.ClaimDetailResultWrapper resWrapper = new prov_Wrap_Claim.ClaimDetailResultWrapper();

            ClaimDetailCalloutWrapper wrap = new ClaimDetailCalloutWrapper();
            HTTPRequest request = wrap.retrieveRecords_continuation(claimDetail);
            //Create a continuation for HTTPRequest
            Continuation con = new Continuation(60);
            con.state = con.addHttpRequest(request);
            con.continuationMethod = 'callback';
            return con;

    }

    @RemoteAction
    global static object getPreAuthAttachmentsRemote(String str){

        prov_Wrap_Claim.ClaimDetailAttachmentRequestWrapper claimAttachRequest = (prov_Wrap_Claim.ClaimDetailAttachmentRequestWrapper) System.JSON.deserialize(str,prov_Wrap_Claim.ClaimDetailAttachmentRequestWrapper.class);

            ClaimAttachmentsCalloutWrapper wrap = new ClaimAttachmentsCalloutWrapper();
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
            system.debug('-- Request -------------------------------------------------------------------------');
            system.debug('Response failed.');
            system.debug(res.getStatusCode());
            system.debug(res.getBody());
            system.debug('-- Request-------------------------------------------------------------------------');
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
                res.setBody('{"Claim":{"Header":{"ProcessingPolicies":[],"RouteId":"GOV","ClaimGuid":"341b8cde-895e-40c2-99d2-bb7d33364a14","TreatingProviderGuid":"285f48b0-d961-45d0-a8ee-d84c3524a839","ServiceOfficeGuid":"74e893fa-4db5-47d3-a429-8e5695ec048b","ServiceOfficeName":"Journey Richard","ClaimNumber":"101429348730100","ClaimType":"Prior Auth","ClaimTypeCategory":"Authorization","ClaimStatus":"Determined","StatusCategory":"Finalized","ReceivedDate":"2015-10-22T00:00:00","SubmittedMemberId":"208473936","PlanName":"TX Med Child","PatientFirstName":"Wallace","PatientLastName":"Ayers","PatientBirthDate":"1998-07-13T00:00:00","ProviderLastName":"Stout","ProviderFirstName":"Jovani","ProviderTin":"","ProviderAddress1":"William Street","ProviderAddress2":"","ProviderCity":"NORTH RICHLAND HILLS","ProviderState":"TX","ProviderZipCode":"76180","BusinessName":"Nick Rowland","PlaceOfTreatment":"Office","OfficeReferenceNumber":"","ReferralNumber":"","ProviderNpi":"","BusinessNpi":"","ServiceLocationNpi":"","NetFeeSum":176.40,"SubmittedFeeSum":700.00,"PaymentDate":"1900-01-01T00:00:00","OriginalDecisionDate":"2015-10-26T00:00:00","ExpirationDate":"2016-04-23T00:00:00","PaymentNumber":"","SubmittedDate":"2015-10-22T00:00:00","ICDCode1":null,"ICDCode2":null,"ICDCode3":null,"ICDCode4":null,"Notes":"NEA#85772639 "},"Lines":[{"ProcessingPolicies":"","LineNumber":1,"LineStatus":"Paid","ServiceDate":null,"FinalDeterminationDate":"2015-10-26T00:00:00","ProcedureCode":"D7230","AllowedFee":176.40,"NetFee":176.40,"Quadrant":"LL","SubmittedFee":700.00,"ProcedureCodeDescription":"Removal of impacted tooth - partially bony","PaidProcedureCode":"D7230","Surface":"      ","ToothNumber":"17","Arch":"LA","Quantity":1,"ICDCode1":null,"ICDCode2":null,"ICDCode3":null,"ICDCode4":null}],"CobInfo":[]},"QueryTotalTimeMs":441}');
     
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
                prov_Wrap_Claim.ClaimDetailResultWrapper claimDetail = (prov_Wrap_Claim.ClaimDetailResultWrapper) System.JSON.deserialize(res.getBody(),prov_Wrap_Claim.ClaimDetailResultWrapper.class);

                    String claimDetailResult = JSON.serialize(claimDetail); 
                    System.debug('claim detail results: ' + claimDetailResult);
                    return (Object)claimDetailResult; 

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

        prov_wrap_Claim.ClaimDetailResultWrapper claimDetailWrapper = (prov_wrap_Claim.ClaimDetailResultWrapper) System.JSON.deserialize(response,prov_wrap_Claim.ClaimDetailResultWrapper.class);

        
                //sum billed amounts for each service line and assign to total billed amount
                List<Decimal> intList = new List<Decimal>();
                for(prov_wrap_Claim.ClaimDetailServiceLineWrapper line : claimDetailWrapper.Claim.Lines){
                    intList.add(line.AllowedFee);

                }
                claimDetailWrapper.Claim.Header.TotalBilledAmount = 0.00;
                for(Decimal dec : intList){
                    claimDetailWrapper.Claim.Header.TotalBilledAmount += dec;
                }

       return claimDetailWrapper;
    }


    public class ClaimDetailCalloutWrapper{

        public String BusinessId {get;set;}
        public String ClaimRecNum {get;set;}
        public String BusinessGuid {get;set;}
        
        
        public ClaimDetailCalloutWrapper(){
            
        }
        

        public HttpRequest retrieveRecords_continuation(prov_Wrap_Claim.ClaimDetailRequestWrapper claimRequest){
            System.debug('prov_util_MockData.useMockData::'+prov_util_MockData.useMockData);
            Global_Configuration__c calloutEndpoint = Global_Configuration__c.getInstance('ClaimDetailRequestEndpoint');
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
    public class ClaimAttachmentsCalloutWrapper{

        public String RouteId {get;set;}
        public String ClaimRecNum {get;set;}
        
        
        
        public ClaimAttachmentsCalloutWrapper(){
            
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

    //creates a draft claim based on inputs from a pre-authorization
	@auraEnabled
	public static String startClaimFromPreAuth(String preAuth){
        system.debug('pre Auth string' + preAuth);
        //receives json string from lightning component
        prov_Wrap_Claim.ClaimDetailResultClaimWrapper preAuthDetail = (prov_Wrap_Claim.ClaimDetailResultClaimWrapper) System.JSON.deserialize(preAuth,prov_Wrap_Claim.ClaimDetailResultClaimWrapper.class);
		//populate fields on new claim
        Claim__c newClaim = new Claim__c();
		newClaim.Place_of_Treatment_Desc__c  = preAuthDetail.Header.PlaceOfTreatment;
		newClaim.Office_Reference_Number__c = preAuthDetail.Header.OfficeReferenceNumber;
		newClaim.Referral_Number__c = preAuthDetail.Header.ReferralNumber;
    newClaim.Claim_Type__c = 'CLAIM';
    Account officeLoc = [SELECT Id FROM Account Where guid__c = :preAuthDetail.Header.ServiceOfficeGuid];
    Account provider = [SELECT Id FROM Account Where guid__c = :preAuthDetail.Header.TreatingProviderGuid];
    
    Account business = prov_util_Cache.CurrentBusiness;
		//office location
		newClaim.Service_Location__c = officeLoc.Id;
		//provider
		newClaim.Provider__c = provider.Id;

    newClaim.Business__c = business.Id;

		//include claim/preAuthDetail type

		newClaim.Service_Date__c = Date.today();
		newClaim.Patient_Birth_Date__c = date.newinstance(preAuthDetail.Header.PatientBirthDate.year(), preAuthDetail.Header.PatientBirthDate.month(), preAuthDetail.Header.PatientBirthDate.day());
		newClaim.Subscriber_ID__c = preAuthDetail.Header.SubmittedMemberId;
		newClaim.Patient_First_Name__c = preAuthDetail.Header.PatientFirstName;
		newClaim.Patient_Last_Name__c = preAuthDetail.Header.PatientLastName;
    newClaim.Plan_text__c = preAuthDetail.Header.PlanName;


    //claim.Plan_Text__c = eligible.memCov[0].PlanName__c;
    //                claim.Plan_GUID__c = eligible.memCov[0].PlanGUID__c;
    //                claim.Subscriber_Last_Name__c = eligible.memCov[0].LastName__c;
    //                claim.Subscriber_First_Name__c = eligible.memCov[0].FirstName__c;
    //                claim.Patient_First_Name__c = eligible.memCov[0].FirstName__c;
    //                claim.Patient_Last_Name__c = eligible.memCov[0].LastName__c;
    //                claim.Patient_Birth_Date__c = eligible.memCov[0].Birthdate__c;
    //                claim.Patient_Member_Profile_GUID__c = eligible.memberProfileGuid;


		//create claim from pre-auth

		insert newClaim;
		Claim__c insertedClaim = [SELECT Id FROM Claim__c ORDER BY CreatedDate DESC LIMIT 1];

		//return claim Id to pass to claim entry screen
		return insertedClaim.Id;

	}

    //retreive pre-authorization details from Salesforce if the pre-authorization ID is not in windward
	@auraEnabled
	public static prov_wrap_Claim.ClaimDetailResultClaimWrapper getPreAuthRecSFDCDetails(String claimId){
		
		Claim__c claim = [SELECT Id, Name, Business__r.Name, Business__r.guid__c, Service_Location__r.guid__c, Patient_First_Name__c, Patient_Last_Name__c, Patient_Birth_Date__c, Claim_Number__c, Submitted_DateTime__c,
                         Subscriber_ID__c, Claim_Type__c, Plan__r.Name, Service_Location__r.Name, Treating_Provider_First_Name__c, Treating_Provider_Last_Name__c,Treating_Provider_Address1__c,
                         Treating_Provider_City__c, Treating_Provider_State__c, Treating_Provider_Zip__c, Provider__r.tax_id_number__c, 
                         Place_of_Treatment_Desc__c , Office_Reference_Number__c, Referral_Number__c, Diagnosis_Code_A__c,Total_Billed_Amount__c,
                         Business__r.npi__c, Service_Location__r.npi__c, Provider__r.npi__c, Claim_Draft_Status__c,Remarks2__c,
                         Diagnosis_Code_B__c,Diagnosis_Code_C__c,Diagnosis_Code_D__c, Provider__r.guid__c, (select id, Original_File_Name__c, CreatedDate from Claim_Attachments__r) FROM Claim__c Where id = :claimId];


        system.debug(claim.Business__r.Name);
        //query list of service lines
        List<Claim_Service_Line__c> claimServLine = [SELECT id, Name, Claim__c, Diagnosis_Code_A__c, Diagnosis_Code_B__c,
        Diagnosis_Code_C__c, Diagnosis_Code_D__c, Arch__c,  Billed_Amount__c, Line_Number__c, Procedure_Code__c, Procedure_Code_Lookup__r.Name, Procedure_Code_Lookup__r.Class_Code__c, Procedure_Code_Lookup__r.Description__c,
        Quad__c, Quantity__c, Service_Date__c, Surfaces__c, Tooth_Number__c FROM Claim_Service_Line__c Where Claim__c = :claimId];

        //query COB info
        List<COB_Payer_Claim__c> cobInfos = [SELECT Id, Claim__c, Line_Number__c, Subscriber_Birth_Date__c, Subscriber_First_Name__c,
        Subscriber_Last_Name__c,
        Group_ID__c FROM COB_Payer_Claim__c WHERE Claim__c = :claimId];

        //query cob details
        List<COB_Payer_Detail__c> cobPayerDetails = [SELECT id, Name, Claim_Service_Line__c, Paid_Amount__c, Payment_Date__c FROM COB_Payer_Detail__c WHERE Claim_Service_Line__c in :claimServLine];
        system.debug('claim type::' + claim.Claim_Type__c);

        prov_wrap_Claim.ClaimDetailResultClaimWrapper claimDetailWrapper = new prov_wrap_Claim.ClaimDetailResultClaimWrapper();
        //populate claim detail wrapper based on field values in salesforce claim and associated records
                claimDetailWrapper.Header.ClaimId = claim.Id;


                
                claimDetailWrapper.Header.BusinessName = claim.Business__r.Name;
                claimDetailWrapper.Header.PatientFirstName = claim.Patient_First_Name__c;
                claimDetailWrapper.Header.PatientLastName = claim.Patient_Last_Name__c;
                claimDetailWrapper.Header.PatientBirthDate =  claim.Patient_Birth_Date__c;
                claimDetailWrapper.Header.SubmittedMemberId = claim.Subscriber_ID__c;
                claimDetailWrapper.Header.BusinessGuid = claim.Business__r.guid__c;
                claimDetailWrapper.Header.ServiceOfficeGuid = claim.Service_Location__r.guid__c;
                claimDetailWrapper.Header.TreatingProviderGuid = claim.Provider__r.guid__c;
                claimDetailWrapper.Header.planName = claim.Plan__r.Name;
                claimDetailWrapper.Header.providerFirstName = claim.Treating_Provider_First_Name__c;
                claimDetailWrapper.Header.providerLastName = claim.Treating_Provider_Last_Name__c;
                claimDetailWrapper.Header.providerAddress1 = claim.Treating_Provider_Address1__c;
                claimDetailWrapper.Header.providerCity = claim.Treating_Provider_City__c;
                claimDetailWrapper.Header.providerState = claim.Treating_Provider_State__c;
                claimDetailWrapper.Header.providerZipCode = claim.Treating_Provider_Zip__c;
                claimDetailWrapper.Header.providerTIN = claim.Provider__r.tax_id_number__c;
                claimDetailWrapper.Header.PlaceOfTreatment = claim.Place_of_Treatment_Desc__c ;
                claimDetailWrapper.Header.OfficeReferenceNumber = claim.Office_Reference_Number__c;
                claimDetailWrapper.Header.ReferralNumber = claim.Referral_Number__c;
                claimDetailWrapper.Header.icdCode1 = claim.Diagnosis_Code_A__c;
                claimDetailWrapper.Header.icdCode2 = claim.Diagnosis_Code_B__c;
                claimDetailWrapper.Header.icdCode3 = claim.Diagnosis_Code_C__c;
                claimDetailWrapper.Header.icdCode4 = claim.Diagnosis_Code_D__c;
                claimDetailWrapper.Header.TotalBilledAmount = claim.Total_Billed_Amount__c;
                claimDetailWrapper.Header.ServiceOfficeName = claim.Service_Location__r.Name;
                claimDetailWrapper.Header.notes = claim.Remarks2__c;
                claimDetailWrapper.Header.ClaimNumber = claim.Claim_Number__c;
                claimDetailWrapper.Header.SubmittedDate = claim.Submitted_DateTime__c;
                claimDetailWrapper.Header.ClaimTypeCategory = claim.Claim_Type__c;
                claimDetailWrapper.Header.StatusCategory = claim.Claim_Draft_Status__c;
                claimDetailWrapper.Header.BusinessNpi = claim.Business__r.npi__c;
                claimDetailWrapper.Header.ServiceLocationNpi = claim.Service_Location__r.npi__c;
                claimDetailWrapper.Header.ProviderNpi = claim.Provider__r.npi__c;



                
                system.debug('wrapper :' + claimDetailWrapper);
                system.debug(cobInfos);
                for(COB_Payer_Claim__c cobInfo : cobInfos){
                    system.debug('cobinfo' + cobInfo);
                prov_wrap_Claim.ClaimDetailCOBPayerClaimWrapper cob = new prov_wrap_Claim.ClaimDetailCOBPayerClaimWrapper();
                cob.OtherSubscriberFirstName = cobInfo.Subscriber_First_Name__c;
                cob.OtherSubscriberLastName = cobInfo.Subscriber_Last_Name__c;
                cob.OtherSubscriberDob = cobInfo.Subscriber_Birth_Date__c;
                cob.OtherSubscriberGroupName = cobInfo.Group_ID__c;

                claimDetailWrapper.COBInfo.add(cob);
                }

                //ServiceLineList
                for(Claim_Service_Line__c claimServL : claimServLine){

                prov_wrap_Claim.ClaimDetailServiceLineWrapper servLine = new prov_wrap_Claim.ClaimDetailServiceLineWrapper();
                servLine.Name = claimServL.Name;
                servLine.ServiceDate = claimServL.Service_Date__c;
                servLine.LineNumber = String.valueOf(claimServL.Line_Number__c);
                servLine.ProcedureCode = claimServL.Procedure_Code__c;
                servLine.ToothNumber  = claimServL.Tooth_Number__c;
                servLine.Quadrant = claimServL.Quad__c;
                servLine.Arch = claimServL.Arch__c;
                servLine.Surface = claimServL.Surfaces__c;
                servLine.Quantity = Integer.valueOf(claimServL.Quantity__c);
                servLine.AllowedFee = claimServL.Billed_Amount__c;
                servLine.NetFee = 0;
                servLine.IcdCode1 = claimServL.Diagnosis_Code_A__c;
                servLine.IcdCode2 = claimServL.Diagnosis_Code_B__c;
                servLine.IcdCode3 = claimServL.Diagnosis_Code_C__c;
                servLine.IcdCode4 = claimServL.Diagnosis_Code_D__c;

                if(claimServL.Procedure_Code_Lookup__r.Name != null && claimServL.Procedure_Code_Lookup__r.Description__c != null){
                        servLine.ProcedureCodeDescConcat = claimServL.Procedure_Code_Lookup__r.Name + '-'+ claimServL.Procedure_Code_Lookup__r.Description__c;
                            
                  }
                  claimDetailWrapper.Lines.add(servLine);
                  
                }

                //loop through each cobInfoDetail, if the service line matches, populate
                for(Claim_Service_Line__c cobServLine : claimServLine){
                    for(COB_Payer_Detail__c payerDetails : cobPayerDetails){
                        if(payerDetails.Claim_Service_Line__c == cobServLine.id){
                            prov_wrap_Claim.ClaimDetailCOBPayerClaimWrapper servLineCob = new prov_wrap_Claim.ClaimDetailCOBPayerClaimWrapper();
                
                            servLineCob.PrimePaid = payerDetails.Paid_Amount__c;
                            servLineCob.OtherInsurancePaidDate = payerDetails.Payment_Date__c;
                            
                            //claimDetailWrapper.Lines.COBDetail.add(servLineCob);
                            //loop through lines and add service line cobs
                            for(prov_wrap_Claim.ClaimDetailServiceLineWrapper line : claimDetailWrapper.Lines){
                                

                                if(line.LineNumber == String.valueOf(cobServLine.Line_Number__c)){

                                    line.COBDetail.add(servLineCob);
                                }
                            }
                        }

                    }
                }          
                
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
                    claimDetailWrapper.Header.Attachments.add(attach);
                    //system.debug('attachment ::' +attach);
                }


        return claimDetailWrapper;
	}	

   
    //method gets list of pre-authorizations for confirmation report
    @auraEnabled
    public static List<prov_wrap_Claim.ClaimDetailResultClaimWrapper> retreivePreAuthsReport(String filterDate, String businessId){
        //query submitted claims based on submission date passing into the method
        Date dateVal;
        if(filterDate != null){

        dateVal = date.parse(filterDate);
        }
        system.debug(dateVal);

        //include end date and start date ranges that todays datetime would fall under
        Date laterDate = dateVal.addDays(1);

        //query submitted pre-auth based on submission date passing into the method
        List<prov_wrap_Claim.ClaimDetailResultClaimWrapper> preAuthReportList = new  List<prov_wrap_Claim.ClaimDetailResultClaimWrapper>();
        List<Claim__c> claimList = new List<Claim__c>();

        claimList = [SELECT Id, Name, Claim_Number__c,Submitted_DateTime__c,Patient_First_Name__c, Patient_Last_Name__c,
            Patient_Birth_Date__c, Subscriber_ID__c, Plan__r.Name, Treating_Provider_First_Name__c, Treating_Provider_Last_Name__c,Remarks2__c, Treating_Provider_Address1__c,
                         Treating_Provider_City__c, Treating_Provider_State__c, Treating_Provider_Zip__c, Provider__r.tax_id_number__c, Business__r.Name,
                         Place_of_Treatment_Desc__c , Office_Reference_Number__c, Referral_Number__c,Claim_Draft_Status__c, Total_Billed_Amount__c,
                         Diagnosis_Code_A__c, Diagnosis_Code_B__c, Diagnosis_Code_C__c, Service_Location__r.Name, Diagnosis_Code_D__c, 
                         Business__r.npi__c,Service_Location__r.npi__c,Provider__r.npi__c,
                         (SELECT id, Name, Claim__c, Arch__c, Billed_Amount__c, Line_Number__c, Procedure_Code__c,
                        Quad__c, Quantity__c, Service_Date__c, Surfaces__c, Tooth_Number__c,  Diagnosis_Code_A__c, Diagnosis_Code_B__c,
                        Diagnosis_Code_C__c, Diagnosis_Code_D__c, Procedure_Code_Lookup__r.Name, Procedure_Code_Lookup__r.Description__c FROM Claim_Service_Lines__r),
                        (SELECT id, Name, Claim__c,  Payer_Name__c, Subscriber_First_Name__c,  Subscriber_Last_Name__c,  Subscriber_Birth_Date__c,
                      Subscriber_ID__c, Group_ID__c FROM COB_Payer_Claims__r)

                         FROM Claim__c WHERE Claim_type__c = 'AUTH' AND Submitted_DateTime__c >= :dateVal AND Submitted_DateTime__c < :laterDate AND Claim_Draft_Status__c = 'SUBMITTED' AND Business__c = :businessId ORDER BY Claim_Number__c DESC];
        
        for(Claim__c claim :claimList){
            prov_wrap_Claim.ClaimDetailResultClaimWrapper claimResponse = new prov_wrap_Claim.ClaimDetailResultClaimWrapper();
                claimResponse.Header.ClaimId = claim.Id;
                claimResponse.Header.ClaimNumber = claim.Claim_Number__c;
                claimResponse.Header.ClaimStatus = claim.Claim_Draft_Status__c;
                claimResponse.Header.SubmittedDate = claim.Submitted_DateTime__c;
                claimResponse.Header.PatientFirstName = claim.Patient_First_Name__c;
                claimResponse.Header.PatientLastName = claim.Patient_Last_Name__c;
                claimResponse.Header.PatientBirthDate =  claim.Patient_Birth_Date__c;
                claimResponse.Header.SubmittedMemberId =  claim.Subscriber_ID__c;
                claimResponse.Header.PlanName = claim.Plan__r.Name;
                claimResponse.Header.BusinessName = claim.Business__r.Name;
                claimResponse.Header.ProviderFirstName = claim.Treating_Provider_First_Name__c;
                claimResponse.Header.ProviderLastName = claim.Treating_Provider_Last_Name__c;
                claimResponse.Header.ProviderAddress1 = claim.Treating_Provider_Address1__c;
                claimResponse.Header.ProviderCity = claim.Treating_Provider_City__c;
                claimResponse.Header.ProviderState = claim.Treating_Provider_State__c;
                claimResponse.Header.ProviderZipCode = claim.Treating_Provider_Zip__c;
                claimResponse.Header.ProviderTIN = claim.Provider__r.tax_id_number__c;
                claimResponse.Header.PlaceOfTreatment = claim.Place_of_Treatment_Desc__c ;
                claimResponse.Header.OfficeReferenceNumber = claim.Office_Reference_Number__c;
                claimResponse.Header.ReferralNumber = claim.Referral_Number__c;
                claimResponse.Header.ServiceOfficeName = claim.Service_Location__r.Name;
                claimResponse.Header.IcdCode1 = claim.Diagnosis_Code_A__c;
                claimResponse.Header.IcdCode2 = claim.Diagnosis_Code_B__c;
                claimResponse.Header.IcdCode3 = claim.Diagnosis_Code_C__c;
                claimResponse.Header.IcdCode4 = claim.Diagnosis_Code_D__c;
                claimResponse.Header.BusinessNpi = claim.Business__r.npi__c;
                claimResponse.Header.ServiceLocationNpi = claim.Service_Location__r.npi__c;
                claimResponse.Header.ProviderNpi = claim.Provider__r.npi__c;
                claimResponse.Header.Notes = claim.Remarks2__c;
                claimResponse.Header.TotalBilledAmount = claim.Total_Billed_Amount__c;

            preAuthReportList.add(claimResponse);

            for(Claim_Service_Line__c claimServ : claim.Claim_Service_Lines__r){
                prov_wrap_Claim.ClaimDetailServiceLineWrapper servLine = new prov_wrap_Claim.ClaimDetailServiceLineWrapper();
                        servLine.Name = claimServ.Name;
                        servLine.ServiceDate = claimServ.Service_Date__c;
                        servLine.ToothNumber  = claimServ.Tooth_Number__c;
                        servLine.Quadrant = claimServ.Quad__c;
                        servLine.Arch = claimServ.Arch__c;
                        servLine.Surface = claimServ.Surfaces__c;
                        servLine.Quantity = Integer.valueOf(claimServ.Quantity__c);
                        servLine.AllowedFee = claimServ.Billed_Amount__c;
                        if(claimServ.Procedure_Code_Lookup__r.Name != null && claimServ.Procedure_Code_Lookup__r.Description__c != null){
                        servLine.ProcedureCodeDescConcat = claimServ.Procedure_Code_Lookup__r.Name + '-'+ claimServ.Procedure_Code_Lookup__r.Description__c;
                            
                        }
                        servLine.IcdCode1 = claimServ.Diagnosis_Code_A__c;
                        servLine.IcdCode2 = claimServ.Diagnosis_Code_B__c;
                        servLine.IcdCode3 = claimServ.Diagnosis_Code_C__c;
                        servLine.IcdCode4 = claimServ.Diagnosis_Code_D__c;
                        servLine.LineNumber = String.valueOf(claimServ.Line_Number__c);
                claimResponse.Lines.add(servLine);
            }

            for(COB_Payer_Claim__c cob : claim.COB_Payer_Claims__r){
                prov_wrap_Claim.ClaimDetailCOBPayerClaimWrapper cobWrap = new prov_wrap_Claim.ClaimDetailCOBPayerClaimWrapper();
                cobWrap.OtherCarrierName = cob.Payer_Name__c;
                cobWrap.OtherSubscriberFirstName = cob.Subscriber_First_Name__c;
                cobWrap.OtherSubscriberLastName = cob.Subscriber_Last_Name__c;
                cobWrap.OtherSubscriberDob = Datetime.newInstance(cob.Subscriber_Birth_Date__c.year(), cob.Subscriber_Birth_Date__c.month(), cob.Subscriber_Birth_Date__c.day());
                cobWrap.OtherSubscriberGroupName = cob.Group_ID__c;

                claimResponse.COBInfo.add(cobWrap);
            }
        }

        return preAuthReportList;
    }

}