@isTest public with sharing class BatchSetFrecuenciaScheduleTest {
      
    @isTest 
    public static void testSchedule() {
        String jobName = 'Actualizar frecuencia y  categoria de los ficheros modificados en  el ultimo mes';

        String cronExpression = '0 0 0 1/1 * ? *'; //Every Day at 00:00 

        Test.startTest();
            String jobId = System.schedule(jobName, cronExpression, new BatchSetFrecuenciaSchedule());
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