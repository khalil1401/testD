@isTest
public class ScheduleBatchUpdateEstadoMPBC_Test {

    @isTest
    public static void ScheduleBatchUpdateEstadoMPBC_Test() {
        Test.startTest();

            String CRON_EXP = '0 0 * * * ?';
            String jobId = System.schedule('Prueba 1', CRON_EXP, new ScheduleBatchUpdateEstadoMPBC()) ;
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
            System.assertEquals(0, ct.TimesTriggered); 

        Test.stopTest();
    }

}