public with sharing class ApprovalProcessIsLocked {
    @InvocableMethod(label='Check if approval process is  locked' description='Check if approval process is  locked')    
    public static List<String> processIsLocked(List<String> recordIds){
        List<String> lockedList = new List<String>();
        for (String id : recordIds) {
            Boolean locked = Approval.isLocked(id);
            if (locked) {
                lockedList.add('Verdadero');
            }
        }     
        return lockedList;
    }
}