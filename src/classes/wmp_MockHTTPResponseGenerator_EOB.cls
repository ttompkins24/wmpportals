/**********************************************************************************************************************
Name                        : wmp_MockHTTPResponseGenerator_EOB
Purpose                     : Returns a Mock call out response for wmp_test_Document
Created on                  : November 2017
Developed by                : West Monroe Partners
History
Version#        Sprint#     Date                            By                      Comments
1.0             8           November 2017               	West Monroe Partners    See header - purpose
 
**********************************************************************************************************************/
@isTest
global class wmp_MockHTTPResponseGenerator_EOB implements HttpCalloutMock {

	global HttpResponse respond(HttpRequest req){
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('[ '+
					    '{ '+
					        '"SubscriberId": "522978997",'+
					        '"PlanGuid": "2373e051-dfde-482a-bba0-41311c0de4fa",'+
					        '"RouteId": "GOV",'+
					        '"MemberUniversalGuid": "1ad5eff1-1c14-475a-98df-82aa8bc08a63",'+
					        '"ClaimNumber": "201720837007200",'+
					        '"DateOfService": "2017-07-26T00:00:00",'+
					        '"EobLink": "https://connectsso3-test.dentaquest.com/api/processintegration/MemberEOB?id=10.repository9.Chvdr02tv8.reportid6.MEMEOB9.reportver14.2017110900000110.reportsect45.201720837007200+++++++++++++++ABSPG000000000610.orgpagenum1.613.numberofpages1.112.repositoryid36.149C9950-FF15-4032-1D24-20D78B007F7816.tcicryptoversion3.1.09.signature32.9793c8caecbb4bfccc1fb4b050d6a5ff"'+
					    '},'+
					    '{'+
					        '"SubscriberId": "522978997",'+
					        '"PlanGuid": "2373e051-dfde-482a-bba0-41311c0de4fa",'+
					        '"RouteId": "GOV",'+
					        '"MemberUniversalGuid": "1ad5eff1-1c14-475a-98df-82aa8bc08a63",'+
					        '"ClaimNumber": "201723537559300",'+
					        '"DateOfService": "2017-08-22T00:00:00",'+
					        '"EobLink": "https://connectsso3-test.dentaquest.com/api/processintegration/MemberEOB?id=10.repository9.Chvdr02tv8.reportid6.MEMEOB9.reportver14.2017110900000110.reportsect45.201723537559300+++++++++++++++ABSPG000000001210.orgpagenum2.1213.numberofpages1.112.repositoryid36.149C9950-FF15-4032-1D24-20D78B007F7816.tcicryptoversion3.1.09.signature32.4cf3f313c42347a600dde9656d4762e5"'+
					    '}'+
					']');
		res.setStatusCode(200);

		return res;
	}
}