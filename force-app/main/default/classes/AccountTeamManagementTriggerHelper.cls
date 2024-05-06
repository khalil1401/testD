public class AccountTeamManagementTriggerHelper {

    public static void insertAccountTeamMember(List<Dan360_Account_Team_Management__c> atms) {
        List<AccountTeamMember> members = New List<AccountTeamMember>();
        for (Dan360_Account_Team_Management__c atm : atms) {            
            if (atm.Estado__c == 'Aprobado') {
                AccountTeamMember member = new AccountTeamMember(
                    AccountId = atm.Account__c,
                    UserId = atm.User__c,
                    TeamMemberRole = atm.TeamMemberRole__c
                );
                members.add(member);
            }            
        }
        insert members;
    }

}