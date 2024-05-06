@IsTest public with sharing class FilteredTableControllerTest {
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

            Account account = Build.anAccount()            
                .withCanalComercial('E-Commerce')
                .withName('Cuenta Prueba')
                .withIdSap('12345')
                .build();
            
            insert account;
            
            Id recordTypeVisitadorMedico = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId();
            Contact apm = Build.aContactVisitadorMedico()
            .withAccount(account)            
            .build();
            apm.VisMed_DNI__c = '22222333';
            apm.RecordTypeId = recordTypeVisitadorMedico;
            apm.Sub_Equipo__c = 'Metabolicos';
            insert apm;

            Case caso = Build.aReclamo()
                .withAccount(account)            
                .build();
            caso.Priority = 'Medium';
            caso.Subject = 'Prueba';
            caso.Status = 'New';        
            caso.ContactId = apm.Id;
            insert caso;
        }
    }
    @IsTest
    static void methodName(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){  
            Case caso = [
                SELECT Id, CaseNumber, Subject, Status, Priority, Account.Name, Contact.Name
                FROM Case
                WHERE Status = 'New' AND Subject = 'Prueba'
            ];
            String caseNumber = caso.CaseNumber;
            String subject = caso.Subject;
            String priority = caso.Priority;
            String status = caso.Status;
            String accountName = caso.Account.Name;
            String contactName = caso.Contact.Name;
            Test.startTest();
                List<Case> result = FilteredTableController.getCases(caseNumber, subject, priority, status, accountName, contactName);
            Test.stopTest();

            System.debug(result);
            
            System.assertEquals(caso.Id, result[0].Id, 'Error al obtener caso');
        }    
    }

    @IsTest
    static void methodNameWithEmptyConditions(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){  
            Case caso = [
                SELECT Id, CaseNumber, Subject, Status, Priority, AccountId, Contact.Name
                FROM Case
                WHERE Status = 'New' AND Subject = 'Prueba'
            ];
            String caseNumber = caso.CaseNumber;
            String subject = caso.Subject;
            String priority = caso.Priority;
            String status = caso.Status;
            String accountName = caso.AccountId;
            Test.startTest();
                List<Case> result = FilteredTableController.getCases('', '', '', '', '', '');
            Test.stopTest();

            System.debug(result);
            
            System.assertEquals(caso.Id, result[0].Id, 'Error al obtener caso');
        }    
    }
    
}