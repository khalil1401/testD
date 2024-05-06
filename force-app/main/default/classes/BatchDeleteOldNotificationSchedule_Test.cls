@isTest
public class BatchDeleteOldNotificationSchedule_Test {

    @isTest
    public static void testBatchDeleteOldNotificationSchedule(){
        BatchDeleteOldNotificationSchedule sch = new BatchDeleteOldNotificationSchedule();

        String crons = '0 0 3 ? * * *'; 
        Test.startTest();
            String jobId = System.schedule('Test Batch Delete Old Notification', crons, sch);
        Test.stopTest(); 

      CronTrigger ct = [
        SELECT Id, CronExpression
        FROM CronTrigger 
        WHERE id = :jobId
        ];
        System.assertEquals(crons, ct.CronExpression);
    }
    
}