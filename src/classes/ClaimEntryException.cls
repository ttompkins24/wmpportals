public class ClaimEntryException extends Exception {

	public Database.Error errorObj {get;set;}
	public String detailId {get;set;}
	public String claimId {get;set;}
	public String objectType {get;set;}
	
	public ClaimEntryException(Database.Error errorObjNew, String newDetailId, String newClaimid, String newObjectType){
		errorObj = errorObjNew;
		detailId = newDetailId;
		claimId = newClaimId;
		objectType = newObjectType;
	}
}