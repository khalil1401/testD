@isTest
public class BatchSendEmailCCTest {
    @TestSetup
    static void makeData(){
        ID systemAdministrator = [Select Id from Profile where Name = 'System Administrator' or Name = 'Administrador del sistema' ].id;
        
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
                .withProfileId(systemAdministrator)				
                .withLanguageLocaleKey('es')
                .build();           
        insert usuario;
    }

    @isTest
    public static void ifHaveSaldoAndDueSendEmail(){
        Test.startTest();
            BatchSendEmailCC batch = new BatchSendEmailCC();
            Id resultadoId = Database.executeBatch(batch);
            
        Test.stopTest();
        AsyncApexJob aaj = [SELECT id, Status, CompletedDate,
        CreatedBy.Email, CreatedBy.Name,
        NumberOfErrors
        FROM AsyncApexJob WHERE Id =:resultadoId];
        
        System.assertEquals('Completed',  aaj.Status, 'El batch no fue encolado');
    }
}