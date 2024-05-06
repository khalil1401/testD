@isTest
public class BatchBirthdateNotificationSchedule_test {

    @isTest
    public static void testBatchBirthdateNotificationSchedule(){
        BatchBirthdateNotificationSchedule sch = new BatchBirthdateNotificationSchedule();

        String crons = '0 0 3 ? * * *'; 
        Test.startTest();
            String jobId = System.schedule('Test Batch Birthdate', crons, sch);
        Test.stopTest(); 

      CronTrigger ct = [
        SELECT Id, CronExpression
        FROM CronTrigger 
        WHERE id = :jobId
        ];
        System.assertEquals(crons, ct.CronExpression);
    }
    
}