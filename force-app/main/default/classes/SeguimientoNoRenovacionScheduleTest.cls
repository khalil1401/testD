@isTest
public class SeguimientoNoRenovacionScheduleTest {
    @isTest
    public static void testSchedule()
    {
        string cron_exp = '0 0 7,15,23 ? * * *';
        string jobId = System.schedule('Crear casos seguimiento no renovacion', cron_exp, new SeguimientoNoRenovacionSchedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 

        System.assertEquals(0, ct.TimesTriggered); 
        // System.assert(String.valueOf(
        //     DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()).format('yyyy-MM-dd')) +
        //               ' 23:00:00'== String.valueOf(ct.NextFireTime) ||
        //               String.valueOf(
        //                   DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()).format('yyyy-MM-dd')) +
        //               ' 07:00:00'== String.valueOf(ct.NextFireTime) || 
        //               String.valueOf(
        //                   DateTime.newInstance(System.today().year(), System.today().month(), System.today().day()).format('yyyy-MM-dd')) +
        //               ' 15:00:00' == String.valueOf(ct.NextFireTime) 
        //              );       
        
    }
}