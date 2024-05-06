@isTest public with sharing class BatchCiclosTest {
    @testSetup
    private static void testSetup() {
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

            UserRole equipoPediatricosRole = [Select Id From UserRole Where Name = 'Equipo Pediatricos Partner User' Limit 1];

            Profile apmPerfil = [
                    SELECT Id 
                    FROM Profile 
                    WHERE Name = 'APM' 
                    LIMIT 1
                ];
            String uniqueUserName = 'wsdataapptest' + DateTime.now().getTime() + '@testorg.com';
            
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

            User apmUser = Build.aUser()
                .withUsername(
                    'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
                )               
                .withEmail('apm@xappia.com')
                .withAlias('apm')
                .withLastName('Owner')
                .withContactId(apm)
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('apm.xappia')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(apmPerfil.Id)                			
                .withLanguageLocaleKey('es')
                .build();           
            userOwner.ManagerId = UserInfo.getUserId();
            userOwner.IsActive = true;
            userOwner.VisMed_ContrasenaApp__c = 'TestOwner';
            insert apmUser;
                
            Date today = Date.today();
            VisMed_Ciclo__c ciclo = Build.aCiclo()
            .withFechaInicio(today.toStartOfMonth())
            .withFechaFin(today.toStartOfMonth().addMonths(1).addDays(-1))
            .build();
            insert ciclo;
        
        }
            
    }
   @isTest
   private static void cuandoSeEjecutaLaBatchCiclosDebeCrearUnCicloPorMes() {
    User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
    system.runAs(userOwner){
    Test.startTest();
    BatchCiclos batch = new BatchCiclos();
    Database.executeBatch(batch);
    Test.stopTest();

    List<VisMed_Ciclo__c> ciclos = [
        SELECT Id
        FROM VisMed_Ciclo__c        
    ];

    System.assertEquals(12, ciclos.size(), 'Error al Crear ciclos');
   
    }
   }
}