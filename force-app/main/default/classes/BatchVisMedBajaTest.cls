@IsTest
public with sharing class BatchVisMedBajaTest {

    @TestSetup
    static void setup(){
        id profesionalSalud = XappiaHelper.getRecordType('Account', 'Profesional_de_la_Salud').Id;
        Profile systemAdministrator = [Select Id from Profile where Name = 'System Administrator' or name = 'Administrador del sistema' ];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];

        User usuario = Build.aUser()
                .withUsername('globanttt@globant.com')           
                .withEmail('globanttt@globant.com')
                .withAlias('contact')
				.withLastName('Contacto')
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('test.globant')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(systemAdministrator.Id)
                .withUserRoleId(portalRole)				
                .withLanguageLocaleKey('es')
                .build();           
        insert usuario;

        System.runAs(usuario){

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
            
            Account cuenta = Build.anAccount().withRecordTypeId(profesionalSalud).build();
            cuenta.FirstName = 'Prueba';
            cuenta.LastName = 'Test';
            insert cuenta;

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
            usuario.ManagerId = UserInfo.getUserId();
            usuario.IsActive = true;
            usuario.VisMed_ContrasenaApp__c = 'TestOwner';
            insert apmUser;
            
            VisMed_Contacto_Cuenta_Usuario__c fichero = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(cuenta)
                .build();
            fichero.Segmenta_Por__c = 'Pediatricos General';
            insert fichero;
        }
    }

    @IsTest
    public static void reactivateAccountAccordingToReactivationDate() {
        Id institucionId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Institucion').Id;

        Account cuenta = [
            SELECT Id, Name
            FROM Account
            WHERE FirstName = 'Prueba'
        ];

        User usuario = [
            SELECT id, ContactId
            FROM User
            WHERE Email = 'apm@xappia.com'
        ];

        Contact contacto = [
            SELECT Id, Name
            FROM Contact
            WHERE Id = :usuario.ContactId
        ];
        
        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(institucionId)
            .withProfesional(cuenta)
            .withFechaDeReactivacion(Date.today())
            .withEstado('Aprobada')
            .withMotivoDeLaBaja('No ejerce más la profesión')
            .withVisMedAPM(contacto)
        .Build();
        insert baja;

        Test.startTest();
        Database.executeBatch(new BatchVisMedBaja());
        Test.stopTest();

        cuenta = [
            SELECT Profesional_Activo__c
            FROM Account
            WHERE FirstName = 'Prueba'
            LIMIT 1
        ];

        System.assert(cuenta.Profesional_Activo__c);
    }
}