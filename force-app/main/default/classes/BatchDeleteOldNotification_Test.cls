@isTest
public  class BatchDeleteOldNotification_Test {
   
    @isTest
    public static void testBatchDeleteOldNotification(){

        Account account = Build.anAccount()
        .withName('Institucion')					
        .build();

        insert account;

        Contact apm = Build.aContact()
        .withAccount(account)
        .withFirstName('NameTwo')
        .withLastName('LastnameTwo')
        .build();     
        apm.VisMed_DNI__c = '23234324';
        apm.Sub_Equipo__c = 'Metabólicos y Dieta';

        insert apm;

        List<Notificacion__c> notificacionList = new List<Notificacion__c>();

        for (Integer i = 0; i < 3; i++) {

            Notificacion__c notificacion = new Notificacion__c(
                Name = 'test'+i,
                APM__c=apm.Id,
                Leido__c=true
            );
            notificacionList.add(notificacion);
        }

        insert notificacionList;

        Datetime yesterday = Datetime.now().addDays(-31);

        for (Notificacion__c notif: notificacionList) {
            Test.setCreatedDate(notif.Id, yesterday);  
        }
        Test.startTest();
            BatchDeleteOldNotification batch = new BatchDeleteOldNotification();
            Database.executebatch(batch);
        Test.stopTest(); 
        
        List<Notificacion__c> testNot = [
            SELECT Id
            FROM Notificacion__c 
            ];  

        System.assertEquals(0, testNot.size());  
    }
}