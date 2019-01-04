public class ClaimException extends Exception {

	public Database.Error errorObj {get;set;}
	public String detailId {get;set;}
	public String claimId {get;set;}
	public String detailObjectType {get;set;}
	
	public ClaimException(Database.Error errorObjNew, String newDetailId, String newClaimid, String newObjectType){
		System.debug('START ClaimException....');
		this.setMessage(errorObjNew.getMessage());
		System.debug('1');
		errorObj = errorObjNew;
		System.debug('2');
		detailId = newDetailId;
		System.debug('3');
		claimId = newClaimId;
		System.debug('4');
		detailObjectType = newObjectType;
		System.debug('5');
	}
}