trigger MatriculaTrigger on Dan360_Matricula__c (after insert, after update) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Id recordTypeNacional = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Nacional').getRecordTypeId();
            Id recordTypeProvincial = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Provincial').getRecordTypeId();
            MatriculaTriggerHelper.setMatriculaToProfesional(Trigger.new);
        }
        if (Trigger.isUpdate) {
            Id recordTypeNacional = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Nacional').getRecordTypeId();
            Id recordTypeProvincial = Schema.SObjectType.Dan360_Matricula__c.getRecordTypeInfosByDeveloperName().get('Provincial').getRecordTypeId();
            MatriculaTriggerHelper.setMatriculaToProfesional(Trigger.new);
        }
    }

}