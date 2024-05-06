@isTest
public with sharing class SchedulerBatchSendEmailCCTest {
    @TestSetup
    static void makeData(){
        Profile systemAdministrator = [Select Id from Profile where Name = 'System Administrator' or name = 'Administrador del sistema' ];
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();

        Dan360_DocumentosCuentaCorriente__c aCuentaCorriente = Build.aDocumentoCuentaCorriente()
            .withNroComprobante('A0001')
            .withCorreo('globanttt@globant.com')
            .withSaldo(20.00)
            .withVencimiento(Date.today().addDays(-1))
            .build();
        insert aCuentaCorriente;

        Account aAccount = Build.anAccount()
            .withName('Test')					
            .build();
        insert aAccount;

        
        Contact aContact = Build.aContact()
            .withAccount(aAccount)
            .withFirstName('Name')
            .withLastName('Lastname')
            .withRecordType(recordTypeId)
            .build();
        insert aContact;

        User usuario = Build.aUser()
                .withUsername('globanttt@globant.com')               
                .withEmail('globanttt@globant.com')
                .withAlias('contact')
				.withLastName('Contacto')
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('test.globant')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(systemAdministrator.Id)				
                .withLanguageLocaleKey('es')
                .build();           
        insert usuario;
    }

    @isTest
    public static void scheduleBatchSendEmailCC (){
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
                                           new SchedulerBatchSendEmailCC());

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