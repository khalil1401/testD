@isTest
public with sharing class EliminadorRegistrosRefScheduleTest {
    @isTest
    public static void revisarQueLaTareaSeProgrameCorrectamenteParaEliminarRegistrosReferencia() {
        Test.startTest();
        string CRON_EXP = '0 0 0 1/1 * ? *';
        string jobId = System.schedule('BorrarReferenciaTest',CRON_EXP, new EliminadorRegistrosReferenciaSchedule());
        CronTrigger ct = [
        	SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger 
            WHERE Id = :jobId
        ];
        System.assertEquals(0,ct.TimesTriggered);
        Datetime fechaAct = Datetime.now();
        System.assertEquals(Datetime.newInstance(fechaAct.year(),fechaAct.month(),fechaAct.addDays(1).day(),0,0,0), ct.NextFireTime);  
        Test.stopTest();
    }
}