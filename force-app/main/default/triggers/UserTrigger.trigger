trigger UserTrigger on User (after insert) {
    if (Trigger.isAfter){
        if(Trigger.isInsert){
            userHelper.sendEmailToUserCommunity(Trigger.New);
        }
    }
}