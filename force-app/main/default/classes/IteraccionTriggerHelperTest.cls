@isTest 
public with sharing class IteraccionTriggerHelperTest {
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
    
                Id recordTypeProfesional = [
                    SELECT Id, Name, SobjectType,IsPersonType 
                    FROM RecordType 
                    WHERE SobjectType='Account' 
                    AND IsPersonType=True 
                    AND Name = 'Profesional de la Salud'
            ].Id;
    
            List<Account> accountsProf = new List<Account>();
    
            for (Integer i = 0; i < 3; i++) {
                Account aPersonAccount = Build.aPersonalAccount()
                .withFirstName('Profesional'+i)                
                .build();
                aPersonAccount.RecordTypeId = recordTypeProfesional;
                aPersonAccount.PersonBirthdate= system.today();
    
                accountsProf.add(aPersonAccount);
            }
    
                insert accountsProf;
    
                Account profesional = Build.aPersonalAccount()
                    .withFirstName('Profesional')                
                    .build();
                    profesional.RecordTypeId = recordTypeProfesional;
    
                insert profesional;
    
                Id recordTypeAlergia = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Adultos_General_Institucion').getRecordTypeId();
                VisMed_Segmentacion__c segmentacion = new VisMed_Segmentacion__c(
                    Profesional__c = accountsProf[0].id,                
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
                    efectividad.Fecha_de_inicio__c = today.toStartOfMonth();
                    efectividad.Fecha_de_Fin__c = today.toStartOfMonth().addMonths(1).addDays(-1);
                insert efectividad;

                
                VisMed_Contacto_Cuenta_Usuario__c seg = Build.aVisMedContactCuentaUsuarioBuilder()
                    .withAPM(apm)
                    .withInstitucion(account)
                    .withProfesional(profesional)                
                    .build();
                seg.Predeterminada__c = true;            
                seg.Estado__c = 'Activo';
                seg.Segmenta_Por__c = 'Pediatricos General';
                insert seg;
                Integer daysToAdd1 = interaccionDaySaturdayOrSunday(true);
                Dan360_Interacciones__c visita = Build.aDan360Interacciones()
                .withProfesional(profesional)
                .withAPM(apm)
                .withVisMedTipodeVisita('Videollamada')
                .withVisMedEfectividad(efectividad)
                .withDomiciliodelaVisita(account)
                .withVisMedFecha(Date.Today().addMonths(-1).addDays(daysToAdd1))                    
                .build();                
                insert visita;
                Integer daysToAdd2 = interaccionDaySaturdayOrSunday(false);
                Dan360_Interacciones__c visita2 = Build.aDan360Interacciones()
                    .withProfesional(profesional)
                    .withAPM(apm)
                    .withVisMedTipodeVisita('Presencial')
                    .withVisMedEfectividad(efectividad)
                    .withDomiciliodelaVisita(account)
                    .withVisMedFecha(Date.Today().addDays(daysToAdd2))                    
                    .build();                
                insert visita2;
            
            // Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
            // Dan360_Licencia__c licencia = new Dan360_Licencia__c(
            //     Fecha_de_inicio__c = Date.Today().addDays(1),
            //     Fecha_de_Fin__c = Date.Today().addDays(1),
            //     Efectividad__c = efectividad.Id,
            //     Motivo__c = 'Día de estudio',
            //     Estado__c = 'Pendiente',
            //     VisMed_APM__c = apm.Id,            
            //     RecordTypeId = recordTypeLicencia
            // );
            // insert licencia;    
           
    }

        
    }

    @IsTest
    static void cuandoSeCreaInteraccionSeDebeCrearComoOwnerAlApm(){

        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '23234324'
        ];
        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Institucion'
        ];
        List<Account> profesional = [
            SELECT Id
            FROM Account
            WHERE FirstName = 'Profesional'
        ];
        Dan360_Efectividad__c efectividad = [
            SELECT Id
            FROM Dan360_Efectividad__c
            WHERE Fecha_de_Inicio__c = :Date.today().toStartOfMonth()
        ];
        Integer daysToAdd = interaccionDaySaturdayOrSunday(false);
        Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(profesional[0])
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(account)
            .withVisMedFecha(Date.Today().addDays(daysToAdd+1))
            .build();

        Test.startTest();        
        insert visita;        
        Test.stopTest();

        user userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'contact1'
        ];
        Dan360_Interacciones__c visitaToCompare = [
            SELECT Id, OwnerId 
            FROM Dan360_Interacciones__c
            WHERE Id = : visita.Id
        ];

        System.assertEquals(userOwner.Id, visitaToCompare.OwnerId, 'Error al hacer owner al APM');
        
    }
    @IsTest
    static void cuandoSeCreaInteraccionDeTipoTareaDeAccionSeDebeCrearUnObjetivoAccionParaElProfesional(){

        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '23234324'
        ];
        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Institucion'
        ];
        List<Account> profesional = [
            SELECT Id
            FROM Account
            WHERE FirstName = 'Profesional'
        ];
        Dan360_Efectividad__c efectividad = [
            SELECT Id
            FROM Dan360_Efectividad__c
            WHERE Fecha_de_Inicio__c = :Date.today().toStartOfMonth()
        ];
        user userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'contact1'
        ];
        VisMed_Objetivo__c obj = Build.aVisMedObjetivo()
        .withName('Objetivo Test')
        .withVisMedFechaInicio(Date.today().toStartOfMonth())
        .withVisMedFechaFin(Date.Today().addMonths(3))
        .build();
        insert obj;

        VisMed_Accion__c accion = Build.aVisMedAccion()
            .withVisMedObjetivo(obj)
            .withVisMedFechaInicio(Date.today().addDays(4))
            .withVisMedFechaFin(Date.today().addDays(30))        
            .build();
        insert accion;
        VisMed_ObjetivoPorCuenta__c objXCuenta = Build.aVisMedObjetivoPorCuenta()
        .withVisMedObjetivo(obj)
        .withVisMedAPM(userOwner)
        .build();
        insert objXCuenta;

        VisMed_AccionPorCuenta__c accionPorCuenta = Build.aVisMedAccionPorCuenta()
            .withVisMedObjetivo(obj)
            .withVisMedObjetivoPorCuenta(objXCuenta)
            .withVisMedAccion(accion)
            .withVisMedAPM(userOwner)
            .build();
        insert accionPorCuenta;

        Integer daysToAdd = interaccionDaySaturdayOrSunday(false);
        Id recordTypeTareaAccion = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Tarea_de_Accion').getRecordTypeId();
        Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(profesional[0])
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(account)
            .withVisMedFecha(Date.Today().addDays(daysToAdd+1))
            //.withRecordTypeId(recordTypeTareaAccion)
            .build();
        visita.Accion_por_cuenta__c = accionPorCuenta.Id;
        visita.RecordTypeId = recordTypeTareaAccion;
        Test.startTest();        
        insert visita;        
        Test.stopTest();
        
        VisMed_Objetivo_Accion_Profesional__c objAccXProfesional = [
            SELECT Id, Interaccion__c 
            FROM VisMed_Objetivo_Accion_Profesional__c
            WHERE Accion__c = : accion.Id
        ];

        System.assertEquals(visita.Id, objAccXProfesional.Interaccion__c, 'Error al crear objivo accion al prfesional');
        
    }
    @IsTest
    static void seDebeEliminarLaInteraccion(){        
        List<Account> profesional = [
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional'
            ];

            List<Dan360_Interacciones__c> visitas = [
                SELECT Id, VisMed_Tipo_de_Visita__c, Estado__c, Profesional__c
                FROM Dan360_Interacciones__c                
                WHERE Profesional__c = :profesional[0].Id
            ];
            System.debug(visitas);
            List<Dan360_Interacciones__c> visitasToUpdate = new List<Dan360_Interacciones__c>();
            List<Dan360_Interacciones__c> visitasToDelete = new List<Dan360_Interacciones__c>();
            for (Dan360_Interacciones__c visita : visitas) {
                if (visita.VisMed_Tipo_de_Visita__c == 'Videollamada') {
                    visita.Estado__c = 'Aprobada';
                    visitasToUpdate.add(visita);                                      
                }  
                visitasToDelete.add(visita);              
            }
        update visitasToUpdate;
        Test.startTest();        
        delete visitasToDelete;        
        Test.stopTest();
       
        List<Dan360_Interacciones__c> visitasDeleted = [
            SELECT Id
            FROM Dan360_Interacciones__c
            WHERE Id = :visitasToDelete[0].Id
        ];      

        System.assertEquals(0, visitasDeleted.size(), 'Error al borrar interaccion');
        
    }
    @IsTest
    static void methodName4(){  
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){       
            Dan360_Interacciones__c visita = [
                SELECT Id, VisMed_Tipo_de_Visita__c, Estado__c
                FROM Dan360_Interacciones__c
                WHERE VisMed_Tipo_de_Visita__c = 'Videollamada'
            ];
            System.debug(visita);
            visita.VisMed_Tipo_de_Visita__c = 'Presencial';
            visita.Estado__c = 'Aprobada';

            Test.startTest();        
            update visita;        
            Test.stopTest();
            System.debug(visita);
            Notificacion__c notificacion = [
                SELECT Id,Id_del_Objeto__c
                FROM Notificacion__c
                WHERE Id_del_Objeto__c = :visita.Id
            ];      

            System.assertEquals(visita.Id, notificacion.Id_del_Objeto__c, 'Error al crear notificacion');
        }  
    }
    @IsTest
    static void CuandoSeActualizaElProfesionalDeVisitaDebeActualizarLosValoresDelFicheroRelacionado(){  
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){  
            Id recordTypeProfesional = [
                    SELECT Id, Name, SobjectType,IsPersonType 
                    FROM RecordType 
                    WHERE SobjectType='Account' 
                    AND IsPersonType=True 
                    AND Name = 'Profesional de la Salud'
            ].Id;
            Account profesionalTest = Build.aPersonalAccount()
            .withFirstName('Profesional Test')                
            .build();
            profesionalTest.RecordTypeId = recordTypeProfesional;

            insert profesionalTest;

            List<Account> profesional = [
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional'
            ];            
            

            List<Dan360_Interacciones__c> visitas = [
                SELECT Id, VisMed_Tipo_de_Visita__c, Estado__c, Profesional__c
                FROM Dan360_Interacciones__c                
                WHERE Profesional__c = :profesional[0].Id
            ];
            System.debug(visitas);
            List<Dan360_Interacciones__c> visitasToUpdate = new List<Dan360_Interacciones__c>();
            for (Dan360_Interacciones__c visita : visitas) {
                if (visita.VisMed_Tipo_de_Visita__c == 'Presencial') {
                    visita.Profesional__c = profesionalTest.Id;                    
                } else {
                    visita.Estado__c = 'Aprobada';
                }
                visitasToUpdate.add(visita);
            }

            Test.startTest();        
            update visitasToUpdate;        
            Test.stopTest();
            System.debug(visitas);
            VisMed_Contacto_Cuenta_Usuario__c fichero = [
                SELECT Id, Ultima_Visita__c, Profesional__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE Profesional__c = :profesional[0].Id
            ];      
            Integer daysToAdd1 = interaccionDaySaturdayOrSunday(true);
            System.assertEquals(Date.Today().addMonths(-1).addDays(daysToAdd1), fichero.Ultima_Visita__c, 'Error al actualizar fichero');
        }  
    }
    public static integer interaccionDaySaturdayOrSunday(Boolean subtractMonth) {
        if (subtractMonth) {
            DateTime now = DateTime.now().addMonths(-1);
            String dayOfWeek = now.format('EEEE');
            System.debug('****** now: ' + now + ' ' + dayOfWeek);
            if (dayOfWeek == 'Saturday') {
                return 2;
            }else if(dayOfWeek == 'Sunday'){
                return 1;
            }else {
                return 0;
            }            
        } else {
            DateTime now = DateTime.now();
            String dayOfWeek = now.format('EEEE');
            System.debug('****** now: ' + now + ' ' + dayOfWeek);
            if (dayOfWeek == 'Saturday') {
                return 2;
            }else if(dayOfWeek == 'Sunday'){
                return 1;
            }else {
                return 0;
            }
        }
    }

    @isTest
    static void cuandoSeCreaInteraccionConLaMismaFechaQueYaExisteDebeArrojarError(){
        String mensaje;
        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '23234324'
        ];
        Account account = [
            SELECT Id
            FROM Account
            WHERE Name = 'Institucion'
        ];
        List<Account> profesional = [
            SELECT Id
            FROM Account
            WHERE FirstName = 'Profesional'
        ];
        Dan360_Efectividad__c efectividad = [
            SELECT Id
            FROM Dan360_Efectividad__c
            WHERE Fecha_de_Inicio__c = :Date.today().toStartOfMonth()
        ];
        Integer daysToAdd = interaccionDaySaturdayOrSunday(false);
        Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(profesional[0])
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(account)
            .withVisMedFecha(Date.Today().addDays(daysToAdd))
            .build();

        Test.startTest();
        try {
            insert visita;
        } catch (Exception e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                mensaje = e.getDmlMessage(i); 
            }
        }           
        Test.stopTest();

        System.assertEquals('Ya existe una visita para este Profesional para esta fecha.', mensaje, 'Se inserto una visita duplicada.');
        
    }

    @isTest
    static void cuandoSeActualizaFechaDeInteraccionConLaMismaFechaQueYaExisteDebeArrojarError(){
        String mensaje;
        // obtengo la visita aprobada automaticamente y  le coloco la fecha de la visita que esta en pendiente
        Dan360_Interacciones__c interaccionToUpdate = [SELECT id, Profesional__c, VisMed_APM__c, Estado__c, VisMed_Fecha__c FROM Dan360_Interacciones__c WHERE Estado__c = 'Aprobada'];
        Integer daysToAdd1 = interaccionDaySaturdayOrSunday(true);
        interaccionToUpdate.VisMed_Fecha__c = Date.Today().addMonths(-1).addDays(daysToAdd1);
        Test.startTest();
            try {
                update interaccionToUpdate;
            } catch (Exception e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    mensaje = e.getDmlMessage(i); 
                }
            }
        Test.stopTest();

        System.assertEquals('Ya existe una visita para este Profesional para esta fecha.', mensaje, 'Se inserto una visita duplicada.');

    }
}