/*
/*******************************************************************************************************
Name 						: prov_ctrl_Member_Detail_Claims
Purpose						: Controller for the prov_comp_Member_Detail_Claims
							  Gets relevant claims for a member
Created on					: 13rd January 2018
Developed by				: West Monroe Partners
History
Version#		Sprint#		Date					by  							Comments
1.0				1.0			13rd January 2018		West Monroe Partners			See header - purpose
 
*******************************************************************************************************
*/
global class prov_ctrl_Member_Detail_Claims {


    public String portalURL {get;set;}
	public Boolean useMockData {get;set;}

    public prov_ctrl_Member_Detail_Claims(){
        portalURL = System.Label.Member_Eligibility_VF_URL;
		useMockData = prov_util_MockData.useMockData;

    }

    @RemoteAction
    global static object searchClaimsRemote(String header){
        system.debug('header ' + header);
        prov_Wrap_Claim.ClaimHeaderRequestWrapper claimHeader = (prov_Wrap_Claim.ClaimHeaderRequestWrapper) System.JSON.deserialize(header,prov_Wrap_Claim.ClaimHeaderRequestWrapper.class);

        system.debug('claimHeader ' + claimHeader);

        HttpRequest claimRequest = prov_util_ClaimCallout.requestClaimHeadersRemote(claimHeader);

        //create a continuation for callout
        Continuation con = new Continuation(20);
        String request = con.addHttpRequest(claimRequest);
        con.state = request;
        con.continuationMethod = 'callback';
        return con;
    }

    global static object callback(Object state){
        System.debug('in callback');

        HttpResponse res; 

        if(!Test.isRunningTest()){
            res = Continuation.getResponse((String) state);
            System.debug('response ' + res);
            System.debug('response ' + res.getBody());
        } else {
            //make httpResponse here
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"SearchResult":[{"BusinessGuid":"083149db-9c70-4d09-b21e-87150336cd65","ServiceOfficeGuid":"74e893fa-4db5-47d3-a429-8e5695ec048b","TreatingDentistGuid":"285f48b0-d961-45d0-a8ee-d84c3524a839","ClaimNumber":"101429348730100","ClaimGuid":"341b8cde-895e-40c2-99d2-bb7d33364a14","StatusCategory":"Finalized","ClaimType":"AUTH","PlanGuid":"5881abae-9db1-40e2-9c66-82fcce7d131d","PlanName":"TX Medicaid Child (Under 21)","MemberId":"208473936","UniversalMemberGuid":"1a0ea11b-2d5c-ec6b-409e-6fd7167c3aed","MemberFirstName":"Wallace","MemberLastName":"Ayers","TreatingDentistFirstName":"Jovani","TreatingDentistLastName":"Stout","ServiceOfficeAddress1":"William Street","ServiceOfficeAddress2":"","ServiceOfficeCity":"NORTH RICHLAND HILLS","ReceivedDate":"2015-10-22T00:00:00","ServiceDate":"2015-10-26T00:00:00","BilledAmount":700.00,"PaidAmount":176.40}],"TotalCount":1,"QueryTotalTimeMs":166}');  
        }

        //200 code is good, all others is error
        if(res.getStatusCode()!=200){
            system.debug('--Claim Request -------------------------------------------------------------------------');
            system.debug('Response failed.');
            system.debug(res.getStatusCode());
            system.debug(res.getBody());
            system.debug('--Claim Request-------------------------------------------------------------------------');
            return null;
        } else {
            system.debug('Claim Request: ' + res.getBody());
	      
	      // turn result into overall result wrapper
	        prov_wrap_Claim.ClaimHeaderResultWrapper resultWrapper = (prov_wrap_Claim.ClaimHeaderResultWrapper) System.JSON.deserialize(res.getBody(), prov_wrap_Claim.ClaimHeaderResultWrapper.class);
	        system.debug('result wrapper: '+resultWrapper);
	        

	        // extract list of individual results from overall wrapper
	        List<prov_wrap_Claim.ClaimHeaderResponseWrapper> returnedClaims = (List<prov_wrap_Claim.ClaimHeaderResponseWrapper>) resultWrapper.SearchResult;

	        Map<String,List<prov_wrap_Claim.ClaimHeaderResponseWrapper>> claimResponseWrappersMap = new Map<String,List<prov_wrap_Claim.ClaimHeaderResponseWrapper>>();

	        if(returnedClaims != null) {
	            claimResponseWrappersMap.put('calloutSuccess',returnedClaims);
	            system.debug('claimResponseWrappersMap: '+claimResponseWrappersMap);
	        } else {
				claimResponseWrappersMap.put('calloutError',null);
			}
	            
	        //return response wrapper as string
	        return JSON.serialize(claimResponseWrappersMap);
        }
    }
}