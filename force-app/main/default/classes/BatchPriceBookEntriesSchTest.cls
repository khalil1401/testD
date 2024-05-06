@isTest
public class BatchPriceBookEntriesSchTest {
    @isTest 
    public static void testSchedule() {
        String jobName = 'Batch cambios de precios';
        
        String cronExpression = '0 15 * 1 * ?';

        Test.startTest();
            String jobId = System.schedule(jobName, cronExpression, new BatchPriceBookEntriesSchedule());
        Test.stopTest();

        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger WHERE 
            Id = :jobId
        ];

        System.assertEquals(0, ct.TimesTriggered, 'El trabajo programado fue ejecutado');
        System.assertEquals(cronExpression, ct.CronExpression, 'El trabajo no se programo segun lo indicado');
    }
}