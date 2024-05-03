public class SLAUtils{
	static Map<Id, Account> mapAccount = new Map<Id, Account>();

	public static void assignEntitlements(List<Case> cases) {

		Set<Id> idsAccounts = new Set<Id>();
		Set<Id> idsSlaProcesses = new Set<Id>();

		for (Case aCase : cases) {
			SlaProcessId_by_name__c config =
				SlaProcessId_by_name__c.getValues(getSlaNameByCase(aCase));

			if (config == null || String.isBlank(aCase.AccountId)) {
				continue;
			}
			idsAccounts.add(aCase.AccountId);
			idsSlaProcesses.add(config.SlaProcess_Id__c);
		}

		Map<Id, List<Entitlement>> entitlementsByAccount = new Map<Id, List<Entitlement>>();
		for (Entitlement accountEntitlement : [
				SELECT Id, AccountId, SLAProcessId
				FROM Entitlement
				WHERE AccountId IN: idsAccounts
				AND SlaProcessId IN :idsSlaProcesses
		]) {
			if (!entitlementsByAccount.containsKey(accountEntitlement.AccountId)) {
				entitlementsByAccount.put(accountEntitlement.AccountId, new Entitlement[] {});
			}
			entitlementsByAccount.get(accountEntitlement.AccountId).add(accountEntitlement);
		}

		List<Case> casesToCreateEntitlement = new List<Case>();
		for (Case aCase : cases) {
			SlaProcessId_by_name__c config =
				SlaProcessId_by_name__c.getValues(getSlaNameByCase(aCase));

			if (config == null || String.isBlank(aCase.AccountId)) {
				aCase.EntitlementId = null;
				continue;
			}
			List<Entitlement> entitlements = entitlementsByAccount.get(aCase.AccountId);
			if (entitlements == null) {
				casesToCreateEntitlement.add(aCase);
				continue;
			}

			for (Entitlement accountEntitlement : entitlements) {
				if (accountEntitlement.SlaProcessId == config.SlaProcess_Id__c
					&& aCase.EntitlementId != accountEntitlement.Id
				) {
					aCase.EntitlementId = accountEntitlement.Id;
					break;
				}
			}

			if (String.isBlank(aCase.EntitlementId)) {
				casesToCreateEntitlement.add(aCase);
			}
		}

		if (!casesToCreateEntitlement.isEmpty()) {
			for (Account cuenta : [
				SELECT Id, LastName
				FROM Account
				WHERE Id IN :idsAccounts
			]) {
				mapAccount.put(cuenta.Id, cuenta);
			}
			createAndAssignEntitlements(casesToCreateEntitlement);
		}
	}

	public static void createAndAssignEntitlements(List<Case> cases) {

		List<Entitlement> newEntitlements = new List<Entitlement>();
		Map<String, Entitlement> entitlementsByAccountAndSLA = new Map<String, Entitlement>();

		for (Case aCase : cases) {
			SlaProcessId_by_name__c config =
				SlaProcessId_by_name__c.getValues(getSlaNameByCase(aCase));

			String newEntitlementKey = aCase.AccountId + '-' + config.SlaProcess_Id__c;

			if (entitlementsByAccountAndSLA.containsKey(newEntitlementKey)) {
				continue;
			}

			Entitlement newEntitlement = new Entitlement();
			newEntitlement.AccountId = aCase.AccountId;
			newEntitlement.SlaProcessId = config.SlaProcess_Id__c;
			newEntitlement.Name = config.Name + ' ' + mapAccount.get(aCase.AccountId).LastName;
			newEntitlement.StartDate = Date.today().addDays(-1);
			newEntitlement.EndDate = Date.newInstance(2048, 01, 1);
			newEntitlements.add(newEntitlement);
			entitlementsByAccountAndSLA.put(newEntitlementKey, newEntitlement);
		}
		insert newEntitlements;
		for(Case aCase : cases){
			SlaProcessId_by_name__c config =
				SlaProcessId_by_name__c.getValues(getSlaNameByCase(aCase));
			String newEntitlementKey = aCase.AccountId + '-' + config.SlaProcess_Id__c;
			aCase.EntitlementId = entitlementsByAccountAndSLA.get(newEntitlementKey).Id;
		}
	}

	public static String getSlaNameByCase(Case aCase){
		return aCase.Type;
	}

	// Milestones
	public static void closeMilestones(List<Case> cases) {

		List<CaseMilestone> caseMilestones = getCaseMilestonesFromCases(cases);
		DateTime now = DateTime.now();

		for(CaseMilestone milestone : caseMilestones){
			milestone.CompletionDate = now;
		}

		update caseMilestones;
	}

	public static List<CaseMilestone> getCaseMilestonesFromCases(List<Case> cases) {

		return [
			SELECT Id, CompletionDate, IsCompleted, MilestoneType.Name
			FROM CaseMilestone
			WHERE CaseId in :cases
				AND IsCompleted = false
		];

	}
}