@IsTest
public class SubmitApprovalSeguimientoTriggerTest {
	@TestSetup
	public static void makeData() {
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
                
            Date today = Date.today();
            VisMed_Ciclo__c ciclo = Build.aCiclo()
            .withFechaInicio(today.toStartOfMonth())
            .withFechaFin(today.toStartOfMonth().addMonths(1).addDays(-1))
            .build();
            insert ciclo;

            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
            Account aPersonAccount = Build.aPersonalAccount()
            .withFirstName('Profesional')
            //.withLastName('Test')
            .withProfesionalActivo(true)
            .build();
            aPersonAccount.LastName = 'Test';
            aPersonAccount.RecordTypeId = recordTypeProfesional;
            insert aPersonAccount;
        
            Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
            .withVisMedAPM(apm)
            .withVisMedCiclo(ciclo)
            .build();
            efectividad.Fecha_de_Fin__c = Date.today().toStartOfMonth();
            efectividad.Fecha_de_inicio__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            insert efectividad;
        }
    }
    @IsTest
    public static void verifyWhenCreateSeguimiento(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){
            Contact apm = [
                SELECT Id
                FROM Contact
                WHERE VisMed_DNI__c = '22222333'
            ];
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional' AND LastName = 'Test'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest'
            ];

            AccountTeamMember teamMember = new AccountTeamMember(
                AccountId = profesional.Id,
                TeamMemberRole = 'Sales Rep',
                OpportunityAccessLevel = 'None',
                ContactAccessLevel = 'None',
                UserId = userOwner.Id,
                AccountAccessLevel = 'Read',
                CaseAccessLevel = 'None'
            );

            insert teamMember;

            VisMed_Contacto_Cuenta_Usuario__c seg = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(profesional)
                .withEstado('pendiente')
                .build();
            Test.startTest();
            insert seg;
            Test.stopTest();
        }

        VisMed_Contacto_Cuenta_Usuario__c seg = [
            SELECT Id
            FROM VisMed_Contacto_Cuenta_Usuario__c
            LIMIT 1
        ];

        List<ProcessInstance> pIList = [
            SELECT id
            FROM ProcessInstance 
            WHERE TargetObjectId  = :seg.Id
        ];

        system.assertEquals(1,pIList.size());
        
    }	

    @IsTest
    public static void verifyWhenUpdateSeguimiento(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){
            Contact apm = [
                SELECT Id
                FROM Contact
                WHERE VisMed_DNI__c = '22222333'
            ];
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional' AND LastName = 'Test'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest'
            ];

            AccountTeamMember teamMember = new AccountTeamMember(
                AccountId = profesional.Id,
                TeamMemberRole = 'Sales Rep',
                OpportunityAccessLevel = 'None',
                ContactAccessLevel = 'None',
                UserId = userOwner.Id,
                AccountAccessLevel = 'Read',
                CaseAccessLevel = 'None'
            );

            insert teamMember;

            VisMed_Contacto_Cuenta_Usuario__c seg = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(profesional)
                .withEstado('')
                .build();
            
            insert seg;

            seg.Estado__c = 'pendiente';
            Test.startTest();
            update seg;
            Test.stopTest();
        }

        VisMed_Contacto_Cuenta_Usuario__c seg = [
            SELECT Id
            FROM VisMed_Contacto_Cuenta_Usuario__c
            LIMIT 1
        ];

        List<ProcessInstance> pIList = [
            SELECT id
            FROM ProcessInstance 
            WHERE TargetObjectId  = :seg.Id
        ];

        system.assertEquals(1,pIList.size());
        
    }	
}