@isTest
public with sharing class EliminadorRegistrosStockScheduleTest {

    @isTest
    public static void revisarQueLaTareaSeProgrameCorrectamenteParaEliminarRegistrosStock() {
        Test.startTest();
        string CRON_EXP = '0 0 0 1/1 * ? *';
        string jobId = System.schedule('BorrarStockTest',CRON_EXP, new EliminadorRegistrosStockSchedule());
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