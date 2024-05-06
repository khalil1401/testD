public with sharing class PicklistInputTypeController {
	@AuraEnabled
	public static List<LightningPicklistEntry> getPicklistFieldsValues(String sobjectName, String picklistApiName) {
		List<LightningPicklistEntry> wrappedValues = new List<LightningPicklistEntry>();
		List<Schema.PicklistEntry> picklistEntries = new List<Schema.PicklistEntry>();

		Danone360Helper helper = new Danone360Helper(sobjectName);
		picklistEntries = helper.getPicklistEntries(picklistApiName);

		for (Schema.PicklistEntry entry : picklistEntries) {
			if (entry.active) {
				wrappedValues.add(new LightningPicklistEntry(entry.label, entry.value));
			}
		}

		return wrappedValues;
	}

	@AuraEnabled
	public static String getSObjectFieldReference(String referenceName){
		Danone360Helper helper = new Danone360Helper('Dan360_DocumentosCuentaCorriente__c');
		return helper.getFieldReference(referenceName);
	}

	public class LightningPicklistEntry {
		@AuraEnabled
		public String label;

		@AuraEnabled
		public String value;

		public LightningPicklistEntry(String label, String value) {
			this.label = label;
			this.value = value;
		}
	}
}