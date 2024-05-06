@isTest
public with sharing class BatchDeleteCuentaCorrienteScheduleTest {
    @isTest
    public static void testBatchDeleteCuentaCorrienteSchedule(){
        BatchDeleteCuentaCorrienteSchedule sch = new BatchDeleteCuentaCorrienteSchedule();

        String crons = '0 0 3 ? * * *'; 
        Test.startTest();
            String jobId = System.schedule('Test Batch Delete Cuentas Corrientes', crons, sch);
        Test.stopTest(); 

      CronTrigger ct = [
        SELECT Id, CronExpression
        FROM CronTrigger 
        WHERE id = :jobId
        ];
        System.assertEquals(crons, ct.CronExpression);
    }
}