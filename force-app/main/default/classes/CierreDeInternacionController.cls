public with sharing class CierreDeInternacionController {

    public Internacion__c internacion {get; set;}
	ApexPages.StandardController  controller;

    public CierreDeInternacionController(ApexPages.StandardController  controller) {
		this.controller = controller;
		this.internacion = (Internacion__c)controller.getRecord();
	}
	@AuraEnabled
	public static List<String> getPickListValues(){
		List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Internacion__c.Estado_de_Fin_Internaci_n__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		 for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		 }     
		 return pickListValuesList;
	 }
	@AuraEnabled
	public static void cerrarInternacion(String internacionId,Date fechaDeCierre, String estadoDeCierre){
		Internacion__c internacionDB= [
			SELECT id,Paciente__c
			FROM Internacion__c
			WHERE id = :internacionId
			LIMIT 1
		];
       Account accountDB= [
			SELECT id,Fecha_de_obito__c
			FROM Account
			WHERE Id = :internacionDB.Paciente__c
			LIMIT 1
		];
        
		internacionDB.Fecha_de_Fin_Internaci_n__c= fechaDeCierre;
		internacionDB.Estado_de_Fin_Internaci_n__c= estadoDeCierre;
        internacionDB.Closed_by_VF__c =true;
        accountDB.Fecha_de_obito__c = fechaDeCierre;
        
		update internacionDB;
        update accountDB;
	}
	@AuraEnabled
	public static Internacion__c getInternacion(String internacionId){
		if(String.isBlank(internacionId)){
			return null;
		}
		return [
			SELECT id,Fecha_de_Fin_Internaci_n__c
			FROM Internacion__c
			WHERE id = :internacionId
			LIMIT 1
		];
	}
}