@isTest
public class BatchCiclosSchedule_Test {

    @isTest
    public static void testBatchCiclosSchedule(){
        BatchCiclosSchedule sch = new BatchCiclosSchedule();

        String crons = '0 0 3 ? * * *'; 
        Test.startTest();
            String jobId = System.schedule('Test Batch Ciclos Schedule', crons, sch);
        Test.stopTest(); 

      CronTrigger ct = [
        SELECT Id, CronExpression
        FROM CronTrigger 
        WHERE id = :jobId
        ];
        System.assertEquals(crons, ct.CronExpression);
    }
    
}