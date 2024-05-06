@isTest
public class SchedulerBatchDeleteTablaInterCCTest {
    @TestSetup
    static void makeData(){
        Dan360_TablaIntermediaCuentaCorriente__c cuentaCorriente = Build.aTablaIntermediaCuentaCorriente()
            .withName('CC Integracion 1')
            .withCodigoCliente('000012')
            .withFechaDocumento('20210211')
            .withIdRegistro('12345')
            .withImporteDocumento('2000')
            .withMoneda('USD')
            .withOrdenAplicacion('222')
            .withRemito('Rem0000')
            .withSaldo('1500')
            .withTipoDeDocumento('CC')
            .withVencimiento('20220122')
            .build();

        Dan360_TablaIntermediaCuentaCorriente__c cuentaCorriente2 = Build.aTablaIntermediaCuentaCorriente()
            .withName('CC Integracion 2')
            .withCodigoCliente('550074147')
            .withFechaDocumento('20210211')
            .withIdRegistro('98765')
            .withImporteDocumento('2000')
            .withMoneda('USD')
            .withOrdenAplicacion('222')
            .withRemito('Rem0022')
            .withSaldo('1500')
            .withTipoDeDocumento('CC')
            .withVencimiento('20220122')
            .build();
        insert new Dan360_TablaIntermediaCuentaCorriente__c [] {cuentaCorriente,cuentaCorriente2};
    }

    @isTest
    static void schedulableBatchDeleteTablaIntermedia(){
        final String CRON_EXP = '0 0 22 * * ? *';
        Date dia = (Datetime.now().hour() >= 22) ? System.today().addDays(1) : System.today();
        Time tiempo = Time.newInstance(22, 0, 0, 0);

        Datetime proxEjecucion = Datetime.newInstance(
            dia, 
            tiempo
        );
                
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                                       CRON_EXP, 
                                       new SchedulerBatchDeleteTablaIntermediaCC());

        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger 
            WHERE id = :jobId
        ];
        
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verificar proxima ejecucion
        System.assertEquals(
            proxEjecucion.format('yyyy-MM-dd HH:mm:ss'), 
            String.valueOf(ct.NextFireTime)
        );
        Test.stopTest();
    }
}