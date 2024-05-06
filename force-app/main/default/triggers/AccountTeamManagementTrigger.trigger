trigger AccountTeamManagementTrigger on Dan360_Account_Team_Management__c (Before Insert, Before Update) {

    if (Trigger.isBefore) {
        if (Trigger.isUpdate) { 
            AccountTeamManagementTriggerHelper.insertAccountTeamMember(Trigger.new);
        }
    }

}