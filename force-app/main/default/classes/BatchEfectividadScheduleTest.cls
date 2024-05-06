@IsTest
public class BatchEfectividadScheduleTest {
    @IsTest
    public static void newProcessIsScheduled(){
        Test.StartTest();
        BatchEfectividadSchedule schedule = new BatchEfectividadSchedule();
        String sch = '0 0 0/1 1/1 * ? *';
        system.schedule('Test check', sch, schedule);
        Test.stopTest();
        
        List<CronTrigger> ct = [SELECT CronJobDetail.Name FROM CronTrigger WHERE  CronJobDetail.Name = 'Test check'];
        system.assertEquals(ct.size(), 1);
    }
}