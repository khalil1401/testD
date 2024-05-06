@isTest public with sharing class AccountTeamManagementTriggerHelperTest {
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

            Profile perfilApm = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'APM' 
            LIMIT 1
        ];
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

            Dan360_Account_Team_Management__c actm = Build.aDan360AccountTeamManagement()
                .withName('Prueba')
                .withAccount(institucion)
                .withUser(userTest)
                .withTeamMemberRole('Sales Rep')
                .build();
            insert actm;
        }  
    }
    @isTest
    private static void whenUpdateAccountTeamManagementMustCreateAnAccountTeamMember() {
        // Test data setup
        Dan360_Account_Team_Management__c actm = [
            SELECT Id, Estado__c, User__c
            FROM Dan360_Account_Team_Management__c
            WHERE Name = 'Prueba'
        ];
        actm.Estado__c = 'Aprobado';
        // Actual test
        Test.startTest();
            update actm;
        Test.stopTest();
    
        // Asserts
        
        List<AccountTeamMember> atm = [
            SELECT Id, UserId
            FROM AccountTeamMember
            WHERE UserId = :actm.User__c
        ];

        System.assertEquals(1, atm.size(), 'Error al crear account team member');
    }
}