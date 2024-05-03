public class CreateFormFromCaseController  {
	
	public String caseId;
	public CreateFormFromCaseController(ApexPages.StandardController controller) {	
		caseId = controller.getId();
	}

	public PageReference redirectToCreateForm() {
		Case[] caseList = [
			SELECT AccountId, Account.Name,
				CaseNumber 
			FROM Case 
			WHERE Id = :caseId 
		];  		
		if(caseList.isEmpty()) return null;		

		FormularioCustomField__mdt mdt = [ 
			SELECT  Cuenta__c, Caso__c, ObjectId__c 
			FROM FormularioCustomField__mdt
			WHERE MasterLabel = 'Formulario'
		]; 
		Schema.DescribeSObjectResult describeSObject = Formulario__c.SObjectType.getDescribe();		

		PageReference pageRef = new PageReference(
			'/setup/ui/recordtypeselect.jsp?ent='+mdt.ObjectId__c+'&retURL=%2F'+caseId+'&'+
			'save_new_url=%2F'+describeSObject.getKeyPrefix()+'%2Fe%3F'+mdt.Caso__c+'%3D'+
			caseList[0].CaseNumber+'%26'+mdt.Caso__c+'_lkid%3D'+caseId+'%26retURL%3D%252F'+caseId+'&'+
			mdt.Cuenta__c+'='+caseList[0].Account.Name+'&'+mdt.Cuenta__c+'_lkid='+caseList[0].AccountId
		);
			
		return pageRef;
	}
}