@isTest
public class ProfessionalTrackingControllerTest {
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
            //userTest.IsPortalEnabled = true;
            userTest.VisMed_ContrasenaApp__c = 'Test';
            userTest.ManagerId = userApproval.Id;
            userTest.DelegatedApproverId = userApproval.Id;

            insert userTest;

            Id recordTypeProfesional = [SELECT Id, Name, SobjectType,IsPersonType 
            FROM RecordType 
            WHERE SobjectType='Account' AND IsPersonType=True AND Name = 'Profesional de la Salud'].Id;
            Account aPersonAccount = Build.aPersonalAccount()
                .withFirstName('Profesional')                
                .build();
            aPersonAccount.RecordTypeId = recordTypeProfesional;
            insert aPersonAccount;
            Account profesional = Build.aPersonalAccount()
                .withFirstName('Profesional')                
                .build();
            aPersonAccount.RecordTypeId = recordTypeProfesional;
            insert profesional;

            Id recordTypeAlergia = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Adultos_General_Institucion').getRecordTypeId();
            VisMed_Segmentacion__c segmentacion = new VisMed_Segmentacion__c(
                Profesional__c = aPersonAccount.id,                
                RecordTypeId = recordTypeAlergia
            );
            insert segmentacion;

            Date today = Date.today();
            VisMed_Ciclo__c ciclo = Build.aCiclo()
            .withFechaInicio(today.toStartOfMonth())
            .withFechaFin(today.toStartOfMonth().addMonths(1).addDays(-1))
            .build();
            insert ciclo;

            Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
            .withVisMedAPM(apm)
            .withVisMedCiclo(ciclo)
            .build();
            efectividad.Fecha_de_Fin__c = Date.today().toStartOfMonth();
            efectividad.Fecha_de_inicio__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            insert efectividad;
        
        Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
        Dan360_Licencia__c licencia = new Dan360_Licencia__c(
            Fecha_de_inicio__c = Date.Today().addDays(1),
            Fecha_de_Fin__c = Date.Today().addDays(1),
            Efectividad__c = efectividad.Id,
            Motivo__c = 'Día de estudio',
            Estado__c = 'Pendiente',
            VisMed_APM__c = apm.Id,            
            RecordTypeId = recordTypeLicencia
        );
        insert licencia;

        Id recordTypeProfesionalBaja = [SELECT Id, Name, SobjectType,IsPersonType 
            FROM RecordType 
            WHERE SobjectType='VisMed_Bajas__c' AND Name = 'Profesional de la Salud'].Id;

        VisMed_Bajas__c baja = Build.aVisMedBajasProfesionaldelaSalud()
            .withProfesional(profesional)
            .withVisMedAPM(apm)
            .build();
        baja.RecordTypeId = recordTypeProfesionalBaja;
        insert baja;

        Datetime dt = System.now().addDays(3);
        Date dateVisita;
        if(dt.format('u')== '6' || dt.format('u')== '7'){
            dateVisita = dt.date().addDays(2);
        }
        else{
            dateVisita = dt.date();
        }


        Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(aPersonAccount)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(account)
            .withVisMedFecha(dateVisita)
            .build();
            System.System.debug(dateVisita);
            insert visita;
            
            VisMed_Contacto_Cuenta_Usuario__c seguimiento = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withProfesional(aPersonAccount)
                .withInstitucion(account)
                .withEstado('Pendiente')
                .withSegmentaPor('Adultos General Institucion')
                .build();
            seguimiento.Aprobador_Final__c = userTest.Id;    
            insert seguimiento;
        }
    }

    @IsTest
	private static void getTrackingTest() {   
        Test.startTest();

        Map<String, String> criterias = new Map<String, String>();
        criterias.put('Estado__c','Pendiente');
        ServerResponse response = ProfessionalTrackingController.getTracking(criterias);
		Test.stopTest();
        
        System.assertEquals('SUCCESS',response.state);
	}

    
  


	@IsTest
	private static void transferProfessionalTest() {
        Contact cont = Build.aContact()
        .withRecordType(Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId())
        .build();
        cont.VisMed_DNI__c	='21312233';
        insert cont;
        List<Contact> apms = ProfessionalTrackingController.getAPMList();
        Test.startTest();
        Map<String, Object> mymap = new Map<String, Object>{'Profesional__c' => apms[0].id,'Visitador__c' => cont.id,'Instituciones' => new List<String>()};
        List<Map<String, Object>> lstMaps = new List<Map<String, Object>>();
        lstMaps.add(mymap);
        Boolean result =  ProfessionalTrackingController.transferProfessional(apms[0].Id, lstMaps );
		Test.stopTest();
        System.assertEquals(true,result);

	}

    @IsTest
	private static void shareProfessionalTest() {
        Contact cont = Build.aContact()
        .withRecordType(Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId())
        .build();
        cont.VisMed_DNI__c	='21312233';
        insert cont;
        List<Contact> apms = ProfessionalTrackingController.getAPMList();
        Test.startTest();
        Map<String, Object> mymap = new Map<String, Object>{'Profesional__c' => apms[0].id,'Visitador__c' => cont.id,'Instituciones' => new List<String>()};
        List<Map<String, Object>> lstMaps = new List<Map<String, Object>>();
        lstMaps.add(mymap);
        Boolean result =  ProfessionalTrackingController.shareProfessional(apms[0].Id, lstMaps );
		Test.stopTest();
        System.assertEquals(true,result);

	}

	@IsTest
	private static void getFieldSetTest() {

		Test.startTest();
         ProfessionalTrackingController.getFieldSet('Dan360_SeguimientoFilters');
		Test.stopTest();
	}

    @IsTest
	private static void getSupervisoresAndgetUserAndgetUserInfoTest() {
        Test.startTest();

        List<User> supervisores = ProfessionalTrackingController.getSupervisores();
        System.assertEquals(false, supervisores.isEmpty());
		
        List<User> users = ProfessionalTrackingController.getUser(supervisores[0].Id);
        System.assertEquals(false, users.isEmpty());
        ServerResponse serverResponse = ProfessionalTrackingController.getUserInfo(users[0].Id);
		Test.stopTest();
        System.assertEquals('SUCCESS', serverResponse.state);      
	}

    @IsTest
    private static void getAPMListTest(){

        Contact cont = Build.aContact()
        .withRecordType(Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId())
        .build();
        cont.VisMed_DNI__c	='21312233';
        insert cont;

        Test.startTest();
        List<Contact> apms = ProfessionalTrackingController.getAPMList();
        Test.stopTest();
        System.assertEquals(false, apms.isEmpty());
    }

    @IsTest
    private static void getRecordTypeIdTest(){
        Test.startTest();
        Object obj = ProfessionalTrackingController.getRecordTypeId('Account',null);
        Test.stopTest();
        //System.assertEquals(false, OBJ.Business_Record_Type);
        //VER BIEN CON QUE VALOR VALIDAR EL ASSERT...DEBERIA SER CON ALGUNOS DE LOS RT UTILIZADOS EN EL CMP
    }
}