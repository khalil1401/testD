@isTest public with sharing class SubmitApproSeguimientoTriggerHelperTest {
    @testSetup
    private static void testSetup() {
    
        Account account = Build.anAccount()
        .withName('Institucion')					
        .build();
    
        insert account;
        
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Visitador Medico').getRecordTypeId();
        Contact aContactOne = Build.aContact()
            .withAccount(account)
            .withFirstName('NameOne')
            .withLastName('LastnameOne')
            .build();
        
        aContactOne.RecordTypeId = recordTypeId;
        aContactOne.VisMed_DNI__c = '23555777';
        insert aContactOne;
        Contact aContactTwo = Build.aContact()
            .withAccount(account)
            .withFirstName('NameTwo')
            .withLastName('LastnameTwo')
            .build();
        
        
        aContactTwo.RecordTypeId = recordTypeId;
        aContactTwo.VisMed_DNI__c = '23234324';
        insert aContactTwo;
    
        Profile perfil = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'APM' 
            LIMIT 1
        ];
    
        User userApproval = Build.aUser()
            .withUsername(
                'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
            )
            .withContactId(aContactOne)
            .withLastName('Approval')
            .withEmail('approval@xappia.com')
            .withAlias('appro')
            .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
            .withLocaleSidKey('es_AR')
            .withCommunityNickname('approval.xappia')
            .withEmailEncodingKey('ISO-8859-1')
            .withProfileId(perfil.Id)
            .withLanguageLocaleKey('es')
            .build();
    
        userApproval.IsActive = true;
        userApproval.VisMed_ContrasenaApp__c = 'appro';
    
        insert userApproval;
        User userTest = Build.aUser()
            .withUsername(
                'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
            )
            .withContactId(aContactTwo)
            .withLastName('Contacto2')
            .withEmail('contacto1@xappia.com')
            .withAlias('contact2')
            .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
            .withLocaleSidKey('es_AR')
            .withCommunityNickname('prueba1.xappia')
            .withEmailEncodingKey('ISO-8859-1')
            .withProfileId(perfil.Id)
            .withLanguageLocaleKey('es')
            .build();
    
        userTest.IsActive = true;
        userTest.VisMed_ContrasenaApp__c = 'Test';
        userTest.ManagerId = userApproval.Id;
        userTest.DelegatedApproverId = userApproval.Id;
    
        insert userTest;
    
        Id recordTypeProfesional = [SELECT Id, Name, SobjectType,IsPersonType 
        FROM RecordType 
        WHERE SobjectType='Account' AND IsPersonType=True AND Name = 'Profesional de la Salud'].Id;
        Account aPersonAccount = Build.aPersonalAccount()
            .withFirstName('Profesional')
            .withProfesionalActivo(false)
            .build();
        aPersonAccount.RecordTypeId = recordTypeProfesional;
        insert aPersonAccount;
        Id recordTypeAlergia = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Adultos_General_Institucion').getRecordTypeId();
        VisMed_Segmentacion__c segmentacion = new VisMed_Segmentacion__c(
            Profesional__c = aPersonAccount.id,
            Institucion__c = account.id,
            Frecuencia__c = 1.00,            
            RecordTypeId = recordTypeAlergia
        );
        insert segmentacion;
        VisMed_Contacto_Cuenta_Usuario__c seguimiento = Build.aVisMedContactCuentaUsuarioBuilder()
            .withAPM(aContactTwo)
            .withProfesional(aPersonAccount)
            .withInstitucion(account)
            .withEstado('Pendiente')
            .withSegmentaPor('Adultos General Institucion')
            .build();
        seguimiento.Aprobador_Final__c = userTest.Id;    
        insert seguimiento;
    }
   @IsTest
   static void whenSeguimientoIsInsertedMustSubmitApprovalProcess(){        
        VisMed_Contacto_Cuenta_Usuario__c seg = [
            SELECT Id, Estado__c 
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE Estado__c = 'Pendiente'
        ];
        Test.startTest();
            Boolean locked = Approval.isLocked(seg.Id);
        Test.stopTest();
        System.assertEquals(true, locked, 'Error al crear la aprobacion');
   }
   @IsTest
   static void whenSeguimientoIsInsertedMustSubmitApprovalProcessWithStatusPending(){
        Contact contact = [
            SELECT Id
            FROM Contact
            WHERE FirstName = 'NameTwo'
        ];
        Account aPersonAccount = [
            SELECT Id
            FROM Account
            WHERE FirstName = 'Profesional'
        ];
        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Institucion'
        ];

        User userTest = [
            SELECT Id
            FROM User
            WHERE Alias = 'contact2'
        ];

        VisMed_Contacto_Cuenta_Usuario__c seguimiento = Build.aVisMedContactCuentaUsuarioBuilder()
            .withAPM(contact)
            .withProfesional(aPersonAccount)
            .withInstitucion(account)           
            .withSegmentaPor('Adultos General Institucion')
            .build();
        seguimiento.Aprobador_Final__c = userTest.Id;    
        insert seguimiento;

        seguimiento.Estado__c = 'Pendiente';
        Test.startTest();
            Update seguimiento;            
        Test.stopTest();

        ProcessInstance existingApprovals = [SELECT Id, TargetObjectId
                                                FROM ProcessInstance 
                                                WHERE TargetObjectId = :seguimiento.Id
                                                AND Status = 'Pending'];
        System.debug(existingApprovals);
        System.assertEquals(seguimiento.Id, existingApprovals.TargetObjectId, 'Error al crear la aprobacion');
   }
}