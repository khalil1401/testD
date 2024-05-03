trigger NICTrigger on NIC_Envio__c (before insert) {
    if( Trigger.IsBefore && Trigger.IsInsert ){
        NICTriggerHelper.relateNICWithAccount(Trigger.new);
    }
}