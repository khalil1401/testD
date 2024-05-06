@isTest
public with sharing class FicheroControllerTest {

  @TestSetup
    static void testSetup() {
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
        account.BillingPostalCode ='1134';
        account.BillingCity = 'Buenos Aires';
        account.BillingState = 'Barrio F. Ameghi';
        account.Primera_especialidad__c = 'Nutricionista';
        insert account;
        
        Account accint = Build.anAccount()
        .withName('Institucion')					
        .build();
        accint.BillingPostalCode ='1134';
        accint.BillingCity = 'Buenos Aires';
        accint.BillingState = 'Barrio F. Ameghi';
        accint.Primera_especialidad__c = 'Nutricionista';
        accint.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Institucion').getRecordTypeId();
        insert accint;


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
        aPersonAccount.Primera_especialidad__c = 'Nutricionista';
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
        


      //  DateTime dT2 = System.now();
       // Date myDate = date.newinstance(dT2.year(), dT2.month(), dT2.day());
        

        VisMed_Contacto_Cuenta_Usuario__c seguimiento = Build.aVisMedContactCuentaUsuarioBuilder()
            .withAPM(apm)
            .withProfesional(aPersonAccount)
            .withInstitucion(accint)
            .withEstado('Activo')
            .withSegmentaPor('Adultos General Institucion')
            .build();
        seguimiento.Aprobador_Final__c = userTest.Id;
        seguimiento.Ultima_Visita__c = Date.today().addDays(-43);
        insert seguimiento;
        /*
        SELECT Id, Name, Profesional__c, Institucion__c, Ultima_Visita__c, VisMed_APM__c, Predeterminada__c, Estado__c, OwnerId 
        FROM VisMed_Contacto_Cuenta_Usuario__c 
        WHERE  (Estado__c = 'Activo' OR Estado__c = 'Baja Temporal') 
        AND  Ultima_Visita__c < LAST_N_DAYS:365 
        AND  VisMed_APM__c IN ('00503000002JR0KAAW') 
        AND  Profesional__c = '0010300000lIfnkAAC' 
        AND  Institucion__c = '0010300000lIfnjAAC' 
        AND  Profesional__r.Primera_especialidad__c = 'Kinesiólogo'
        */
    }

}
@IsTest
    
static void transferirProfesionalTest(){
    List<VisMed_Contacto_Cuenta_Usuario__c> regFichero = [SELECT Id, Estado__c, Name, VisMed_APM__c, Profesional__c, Ultima_Visita__c, Institucion__c 
    FROM VisMed_Contacto_Cuenta_Usuario__c];

        Map<String, List<String>> ficheros = new Map<String, List<String>> ();
        ficheros.put(String.valueOf(regFichero[0].VisMed_APM__c+'-'+regFichero[0].Profesional__c),new List<String>{String.valueOf(regFichero[0].Institucion__c)});

    List<Contact> apm = [SELECT Id FROM Contact WHERE Sub_Equipo__c = 'Metabólicos y Dieta' AND id =:regFichero[0].VisMed_APM__c LIMIT 1];
    Test.startTest();
    
    Boolean result = ficheroController.transferirProfesional(ficheros,new List<String>{String.valueOf(apm[0].Id)} ,'TEST');
    Test.stopTest();
System.assertEquals(true, result);

 
}

@IsTest
static void compartirProfesionalTest(){
    List<VisMed_Contacto_Cuenta_Usuario__c> regFichero = [SELECT Id, Estado__c, Name, VisMed_APM__c, Profesional__c, Ultima_Visita__c, Institucion__c 
    FROM VisMed_Contacto_Cuenta_Usuario__c];

        Map<String, List<String>> ficheros = new Map<String, List<String>> ();
        ficheros.put(String.valueOf(regFichero[0].VisMed_APM__c+'-'+regFichero[0].Profesional__c),new List<String>{String.valueOf(regFichero[0].Institucion__c)});

    List<Contact> apm = [SELECT Id FROM Contact WHERE Sub_Equipo__c = 'Metabólicos y Dieta' AND id =:regFichero[0].VisMed_APM__c LIMIT 1];
    Test.startTest();
     Boolean result = ficheroController.compartirProfesional(ficheros,new List<String>{String.valueOf(apm[0].Id)} ,'TEST');
    Test.stopTest();
    System.assertEquals(true,result);
    
}

@IsTest
static void bajaProfesionalTest(){
    
    List<VisMed_Contacto_Cuenta_Usuario__c> regFichero = [SELECT Id, Estado__c, Name, VisMed_APM__c, Profesional__c, Ultima_Visita__c, Institucion__c 
    FROM VisMed_Contacto_Cuenta_Usuario__c];

        Map<String, List<String>> ficheros = new Map<String, List<String>> ();
        ficheros.put(String.valueOf(regFichero[0].VisMed_APM__c+'-'+regFichero[0].Profesional__c),new List<String>{String.valueOf(regFichero[0].Institucion__c)});

    List<Contact> apm = [SELECT Id FROM Contact WHERE Sub_Equipo__c = 'Metabólicos y Dieta' AND id =:regFichero[0].VisMed_APM__c LIMIT 1];
    Test.startTest();
   Boolean result =  ficheroController.bajaProfesional(ficheros, 'TEST DE COMENTARIO', System.Date.today(), System.Date.today(), 'No recibe APM');
    Test.stopTest();
    System.assertEquals(true, result);
    
}


    @IsTest
    
    static void getSupervisoresTest(){
        Test.startTest();
        List<User> supervisores = ficheroController.getSupervisores();
        Test.stopTest();
        System.assertEquals(true, supervisores.isEmpty() == false);
        
    }
  
    @IsTest
    static void getUserListTest(){
        Test.startTest();
        List<User> supervisores = ficheroController.getSupervisores();
        List<id> idSupervisor = new List<id>();
        idSupervisor.add(supervisores[0].id);
        List<user> usuarios =  ficheroController.getUserList(idSupervisor);
        Test.stopTest(); 
      
        System.assertEquals(true,supervisores[0].id != usuarios[0].id);
       // System.assertEquals(1,usuarios.size());
    }

    @IsTest
    static void getDataTest(){
        List<VisMed_Contacto_Cuenta_Usuario__c> regFichero = [SELECT Id, Estado__c, Name, VisMed_APM__c, Profesional__c,Profesional__r.Primera_especialidad__c, Ultima_Visita__c, Institucion__c 
        FROM VisMed_Contacto_Cuenta_Usuario__c LIMIT 1];
        System.debug('@@LOQUE' + regFichero);

        List<Account> cta = [SELECT id, Primera_especialidad__c, BillingCity,BillingPostalCode,BillingCountry From Account WHERE id =: regFichero[0].Profesional__c  ];


        List<User> supervisores = ficheroController.getSupervisores();
        List<id> idSupervisor = new List<id>();
        idSupervisor.add(supervisores[0].id);
        List<String> lstUsers = new List<String>();
        for(user usuarios : ficheroController.getUserList(idSupervisor)){
            lstUsers.add(usuarios.Id);
        }
        
        Test.startTest();
       
       String result = ficheroController.getData(new List<String> {regFichero[0].VisMed_APM__c}, new List<String> {regFichero[0].VisMed_APM__c}, (String)cta[0].Id, String.valueOf(regFichero[0].Institucion__c) ,
                                                                '30' 
                                                , (String)regFichero[0].Profesional__r.Primera_especialidad__c,(String)cta[0].BillingCity,(String)cta[0].BillingCountry,(String)cta[0].BillingPostalCode);
        
        
        Test.stopTest();
        List<ficheroController.FicheroWrapper> resultObj = (List<ficheroController.FicheroWrapper>)JSON.deserialize(result,List<ficheroController.FicheroWrapper>.class);
        System.debug(result);
        System.assertEquals(cta[0].id , resultObj[0].profesionalId );
        
    }

@IsTest
static void getMetadataInfoTest(){
    
    Configuracion_de_motivos_para_la_Baja__mdt MotivosBaja = [SELECT Label,Baja_Temporal__c  FROM Configuracion_de_motivos_para_la_Baja__mdt LIMIT 1];

    Test.startTest();

   Boolean result = ficheroController.getMetadataInfo(MotivosBaja.Label);
   
   Test.stopTest();

   System.assertEquals(MotivosBaja.Baja_Temporal__c,result);
    
}


}