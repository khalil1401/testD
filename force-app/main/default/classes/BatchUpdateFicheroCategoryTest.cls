@isTest
public class BatchUpdateFicheroCategoryTest {
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
            apm.Sub_Equipo__c = 'Metabolicos';
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
    public static void ifProfesionalCategoryChangeFicheroMustUpdate(){
        List<VisMed_Segmentacion__c> segmentacion = [SELECT ID, Categoria__c, Profesional__c, Frecuencia__c FROM VisMed_Segmentacion__c];
        List<VisMed_Contacto_Cuenta_Usuario__c> fichero = [SELECT ID, Categoria__c, Profesional__c, Segmenta_Por__c FROM VisMed_Contacto_Cuenta_Usuario__c];
        String categoriaAnterior = fichero[0].Categoria__c;
        System.debug('categoriaAnterior');
        System.debug(categoriaAnterior);
        System.debug('segmentacion');
        System.debug(segmentacion);
        System.debug('fichero');
        System.debug(fichero);
        Test.startTest();
            BatchUpdateFicheroCategory batch = new BatchUpdateFicheroCategory();
            Database.executeBatch(batch);
        Test.stopTest();

        List<VisMed_Contacto_Cuenta_Usuario__c> ficheroUpdateado = [SELECT ID, Categoria__c, Profesional__c, Segmenta_Por__c FROM VisMed_Contacto_Cuenta_Usuario__c];
        System.assertEquals('D', ficheroUpdateado[0].Categoria__c, 'No se actualizo la categoria.');
    }
}