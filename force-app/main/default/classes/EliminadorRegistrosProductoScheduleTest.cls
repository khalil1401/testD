@isTest
public with sharing class EliminadorRegistrosProductoScheduleTest {
    @isTest
    public static void revisarQueLaTareaSeProgrameCorrectamenteParaEliminarRegistrosProductos() {
        Test.startTest();
        string CRON_EXP = '0 0 0 1/1 * ? *';
        string jobId = System.schedule('BorrarProductosTest',CRON_EXP, new EliminadorRegistrosProductoSchedule());
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