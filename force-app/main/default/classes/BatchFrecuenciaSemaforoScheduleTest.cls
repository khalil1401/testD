@isTest
private class BatchFrecuenciaSemaforoScheduleTest {
    @isTest 
    public static void testExecute() {
        Test.startTest();
        BatchFrecuenciaSemaforoSchedule scheduleJob = new BatchFrecuenciaSemaforoSchedule();
        String sch = '0 0 23 * * ?'; // Schedule for every day at 11pm
        system.schedule('BatchFrecuenciaSemaforoScheduleTest', sch, scheduleJob);
        Test.stopTest();

        // Assert that the batch job has been executed
        List<CronTrigger> ct = [SELECT CronJobDetail.Name FROM CronTrigger WHERE  CronJobDetail.Name = 'BatchFrecuenciaSemaforoScheduleTest'];
        system.assertEquals(ct.size(), 1);        
    }
}