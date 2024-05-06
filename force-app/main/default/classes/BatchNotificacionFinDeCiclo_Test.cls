@isTest
public  class BatchNotificacionFinDeCiclo_Test {
    
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
            
            Contact apm = Build.aContact()
                .withAccount(account)
                .withFirstName('NameTwo')
                .withLastName('LastnameTwo')
                .build();     
            
            apm.RecordTypeId = recordTypeId;
            apm.VisMed_DNI__c = '23234324';
            apm.Sub_Equipo__c = 'Metabólicos y Dieta';
            insert apm;
            
            Profile perfil = [
                SELECT Id 
                FROM Profile 
                WHERE Name = 'Supervisores' 
                LIMIT 1
            ];
            
            User userApproval = Build.aUser()
                .withUsername(
                    'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
                )            
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
            userTest.VisMed_Es_un_Visitador_Medico__c = true;
            userTest.VisMed_ContrasenaApp__c = 'Test';
            userTest.ManagerId = userApproval.Id;
            userTest.DelegatedApproverId = userApproval.Id;
            
            insert userTest;
            
            Contact apm2 = Build.aContact()
                .withAccount(account)
                .withFirstName('NameTwo')
                .withLastName('LastnameTwo')
                .build();     
            
            apm2.RecordTypeId = recordTypeId;
            apm2.VisMed_DNI__c = '232343334';
            apm2.Sub_Equipo__c = 'Metabólicos y Dieta';
            apm2.OwnerId= userTest.Id;
            insert apm2;
            
            
            Contact apm3 = Build.aContact()
                .withAccount(account)
                .withFirstName('NameTwo2')
                .withLastName('LastnameTwo3')
                .build();     
            
            apm3.RecordTypeId = recordTypeId;
            apm3.VisMed_DNI__c = '232355334';
            apm3.Sub_Equipo__c = 'Metabólicos y Dieta';
            apm3.OwnerId= userTest.Id;
            insert apm3;
            
            List<VisMed_Ciclo__c> ciclos = new List<VisMed_Ciclo__c>();
            
            Notificacion_fin_de_Ciclo__mdt mdt = [
                SELECT Id, DeveloperName, Dias_de_antelacion__c 
                FROM Notificacion_fin_de_Ciclo__mdt 
                LIMIT 1
            ];
            
            Date diaFinDelCiclo = Date.today().addDays(mdt.Dias_de_antelacion__c.intValue());
            
            for(Integer i=0; i<2 ; i++){
                
                VisMed_Ciclo__c ciclo = Build.aCiclo()
                    .withFechaInicio(Date.today().toStartOfMonth())
                    .withFechaFin(diaFinDelCiclo)
                    .build();
                
                ciclos.add(ciclo);
            }
            
            insert ciclos;
        }
    }
    
    @isTest
    public static void testDeleteOldQuarters(){
        
        Test.startTest();
        BatchNotificacionFinDeCiclo batch = new BatchNotificacionFinDeCiclo();
        Database.executeBatch(batch);
        Test.stopTest();
        List<Notificacion__c> notificacionesToInsert =[
            SELECT id
            FROM Notificacion__c
        ];
        System.assertEquals(2, notificacionesToInsert.size());
    }
    
}