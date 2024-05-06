public with sharing class TrackingWrapper {
	@AuraEnabled
	public String Id;
	@AuraEnabled
	public String Name;
	@AuraEnabled
	public String ProfessionalId;
	@AuraEnabled
	public String ProfessionalName;
	@AuraEnabled
	public String InstitutionId;
	@AuraEnabled
	public String InstitutionName;
	@AuraEnabled
	public Boolean Predeterminated;
	@AuraEnabled
	public Date LastVisit;
	@AuraEnabled
	public String VisitorId;
	@AuraEnabled
	public String VisitorName;
}