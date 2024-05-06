@isTest
public class SchedulerBatchUpdateFicheroCategoryTest {
    @TestSetup
    static void makeData(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where Name = 'System Administrator' or name = 'Administrador del sistema' ];
    
        User userOwner = Build.aUser()
                .withUsername(
                    'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
                )               
                .withEmail('owner@xappia.com')
                .withAlias('owner')
                .withLastName('Owner')
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('prueba2.xappia')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(profile1.Id)
                .withUserRoleId(portalRole)				
                .withLanguageLocaleKey('es')
                .build();           
        userOwner.ManagerId = UserInfo.getUserId();
        userOwner.IsActive = true;
        userOwner.VisMed_ContrasenaApp__c = 'TestOwner';
        insert userOwner;
    
        System.runAs(userOwner){
            Account institucion = Build.anAccount()
                .withName('InstitucionTest')
                .build();
            insert institucion;
        
            Id recordTypeVisitadorMedico = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId();
            Contact apm = Build.aContactVisitadorMedico()
            .withAccount(institucion)            
            .build();
            apm.VisMed_DNI__c = '22222333';
            apm.RecordTypeId = recordTypeVisitadorMedico;
            apm.Sub_Equipo__c = 'Metabólicos y Dieta';
            insert apm;
            
            Profile perfilApm = [SELECT Id FROM Profile WHERE Name = 'APM' LIMIT 1];

            User userTest = Build.aUser()
            .withUsername(
                'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
            )
            .withContactId(apm)
            .withLastName('Contacto1')
            .withEmail('contacto1@xappia.com')
            .withAlias('contact1')
            .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
            .withLocaleSidKey('es_AR')
            .withCommunityNickname('prueba1.xappia')
            .withEmailEncodingKey('ISO-8859-1')
            .withProfileId(perfilApm.Id)
            .withLanguageLocaleKey('es')
            .build();

            userTest.IsActive = true;
            userTest.VisMed_ContrasenaApp__c = 'Test';
            userTest.ManagerId = userOwner.Id;
            userTest.DelegatedApproverId = userOwner.Id;

            insert userTest;


            Date today = Date.today();
            VisMed_Ciclo__c ciclo = Build.aCiclo()
            .withFechaInicio(today.toStartOfMonth())
            .withFechaFin(today.toStartOfMonth().addMonths(1).addDays(-1))
            .build();
            insert ciclo;

            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
            Account aPersonAccount = Build.aPersonalAccount()
            .withFirstName('Profesional')
            .withProfesionalActivo(true)
            .build();
            aPersonAccount.LastName = 'Test';
            aPersonAccount.RecordTypeId = recordTypeProfesional;
            insert aPersonAccount;

            VisMed_Contacto_Cuenta_Usuario__c seg = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(aPersonAccount)
                .withSegmentaPor('Pediatricos General')
                .withEstado('Activo')
                .build();
            seg.Categoria__c = 'C';
            insert seg;

            Id recordTypPediatricosGeneral = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Pediatricos_General').getRecordTypeId();
            VisMed_Segmentacion__c segmentacion = new VisMed_Segmentacion__c(
                Profesional__c = aPersonAccount.Id,
                RecordTypeId = recordTypPediatricosGeneral
            );
            insert segmentacion; 
        }        
    }

    @isTest
    public static void schedulerBatch(){
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
                                       new SchedulerBatchUpdateFicheroCategory());

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