@IsTest
public with sharing class BatchCountLicenciasScheduleTest {
    @IsTest
    public static void newProcessIsScheduled() {
        Test.StartTest();
        BatchCountLicenciasSchedule schedule = new BatchCountLicenciasSchedule();
        String sch = '0 0 0/1 1/1 * ? *';
        system.schedule('Test check', sch, schedule);
        Test.stopTest();
        
        List<CronTrigger> ct = [
            SELECT CronJobDetail.Name 
            FROM CronTrigger 
            WHERE CronJobDetail.Name = 'Test check'
        ];

        System.assertEquals(ct.size(), 1);
    }
}