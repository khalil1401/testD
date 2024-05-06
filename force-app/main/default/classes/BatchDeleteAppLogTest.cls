@isTest
public class BatchDeleteAppLogTest {
    @TestSetup
    static void makeData(){
        Id recordTypeEDI = Schema.SObjectType.AppLog__c.getRecordTypeInfosByDeveloperName().get('EDI').getRecordTypeId();
        AppLog__c applog = Build.anAppLog().withName('App Log Prueba').build();
        insert applog;
        AppLog__c applog2 = Build.anAppLog().withName('App Log Prueba EDI').withRecordType(recordTypeEDI).build();
        insert applog2;
    }

    @isTest
    public static void deleteAppLogs(){
        List<AppLog__c> appLogs = [SELECT id,Name, RecordTypeId FROM AppLog__c];
        System.debug(appLogs);
        Test.startTest();
            BatchDeleteAppLog batch = new BatchDeleteAppLog();
            Database.executeBatch(batch);
        Test.stopTest();

        List<AppLog__c> appLogsToCheck = [SELECT id, Name FROM AppLog__c];
        System.assertEquals('App Log Prueba EDI', appLogsToCheck[0].Name, 'No se borro el correcto');
        System.assertEquals(1, appLogsToCheck.size(), 'No se borraron los appsLogs');
    }
}