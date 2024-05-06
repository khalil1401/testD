@IsTest
public class GetErrorSyncOrdersScheduleTest {
    @IsTest
    public static void GetErrorSyncOrdersScheduleTest() {
        
        Test.StartTest();
        GetErrorSyncOrdersSchedule schedule = new GetErrorSyncOrdersSchedule();
        String sch = '0 0 0/1 1/1 * ? *';
        system.schedule('Test check', sch, schedule);
        Test.stopTest();
        
        List<CronTrigger> ct = [SELECT CronJobDetail.Name FROM CronTrigger WHERE  CronJobDetail.Name = 'Test check'];
        system.assertEquals(ct.size(), 1);
    }
}