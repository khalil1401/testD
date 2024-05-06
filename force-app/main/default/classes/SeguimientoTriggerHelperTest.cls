@IsTest
public with sharing class SeguimientoTriggerHelperTest {
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

            Account institucion2 = Build.anAccount()
                .withName('InstitucionTest2')
                .build();
            insert institucion2;

            Account institucion3 = Build.anAccount()
                .withName('InstitucionTest3')
                .build();
            insert institucion3;
        
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
            Contact apmSemaforo = Build.aContactVisitadorMedico()
            .withAccount(institucion)            
            .build();
            apmSemaforo.VisMed_DNI__c = '22222444';
            apmSemaforo.RecordTypeId = recordTypeVisitadorMedico;
            apmSemaforo.Sub_Equipo__c = 'Metabólicos y Dieta';
            insert apmSemaforo;
                       
            User userSemaforo = Build.aUser()
            .withUsername(
                'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
            )
            .withContactId(apmSemaforo)
            .withLastName('ContactoSemaforo')
            .withEmail('contactoSemaforo@xappia.com')
            .withAlias('cSema')
            .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
            .withLocaleSidKey('es_AR')
            .withCommunityNickname('prueba3.xappia')
            .withEmailEncodingKey('ISO-8859-1')
            .withProfileId(perfilApm.Id)
            .withLanguageLocaleKey('es')
            .build();

            userSemaforo.IsActive = true;
            userSemaforo.VisMed_ContrasenaApp__c = 'Test';
            userSemaforo.ManagerId = userOwner.Id;
            userSemaforo.DelegatedApproverId = userOwner.Id;

            insert userSemaforo;
                
            Date today = Date.today();
            VisMed_Ciclo__c ciclo = Build.aCiclo()
            .withFechaInicio(today.toStartOfMonth())
            .withFechaFin(today.toStartOfMonth().addMonths(1).addDays(-1))
            .build();
            insert ciclo;

            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
            System.debug(recordTypeProfesional);
            Account aPersonAccount = Build.aPersonalAccount()
            .withFirstName('Profesional')
            //.withLastName('Test')
            //.withProfesionalActivo(true)
            .build();
            aPersonAccount.LastName = 'Test';
            aPersonAccount.RecordTypeId = recordTypeProfesional;
            insert aPersonAccount;
            
            Account profesional = Build.aPersonalAccount()
            .withFirstName('Profesional2')
            //.withLastName('Test')
            //.withProfesionalActivo(true)
            .build();
            profesional.LastName = 'Test2';
            profesional.RecordTypeId = recordTypeProfesional;
            insert profesional;
            Account profesional3 = Build.aPersonalAccount()
            .withFirstName('Profesional3')
            //.withLastName('Test')
            //.withProfesionalActivo(true)
            .build();
            profesional3.LastName = 'Test3';
            profesional3.RecordTypeId = recordTypeProfesional;
            insert profesional3;
        
            Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
            .withVisMedAPM(apm)
            .withVisMedCiclo(ciclo)
            .build();
            efectividad.Fecha_de_Fin__c = Date.today().toStartOfMonth();
            efectividad.Fecha_de_inicio__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            insert efectividad;
            Dan360_Efectividad__c efectividadSemaforo = Build.aDan360Efectividad()
            .withVisMedAPM(apmSemaforo)
            .withVisMedCiclo(ciclo)
            .build();
            efectividadSemaforo.Fecha_de_Fin__c = Date.today().toStartOfMonth();
            efectividadSemaforo.Fecha_de_inicio__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            insert efectividadSemaforo;

            VisMed_Contacto_Cuenta_Usuario__c seg = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(profesional)                
                .build();
            seg.Predeterminada__c = true;            
            seg.Estado__c = 'Activo';
            insert seg;
            VisMed_Contacto_Cuenta_Usuario__c seg2 = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion2)
                .withProfesional(profesional)                
                .build();
            seg2.Estado_de_aprobacion__c = 'Aprobada';
            seg2.Estado__c = 'Activo';
            seg2.Predeterminada__c = false;
            insert seg2;
            VisMed_Contacto_Cuenta_Usuario__c seg3 = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion3)
                .withProfesional(profesional)                
                .build();            
            seg3.Estado__c = 'Pendiente';
            seg3.Predeterminada__c = false;
            insert seg3;

            VisMed_Contacto_Cuenta_Usuario__c ficheroFrecuenciaEntera = Build.aVisMedContactCuentaUsuarioBuilder()
            .withAPM(apmSemaforo)
            .withInstitucion(institucion)
            .withProfesional(profesional3)                
            .build();
            ficheroFrecuenciaEntera.Estado_de_aprobacion__c = 'Aprobada';
            ficheroFrecuenciaEntera.Estado__c = 'Activo';
            ficheroFrecuenciaEntera.Predeterminada__c = true;            
            ficheroFrecuenciaEntera.Frecuencia__c = 2.0;
            ficheroFrecuenciaEntera.Inicio_de_Frecuencia__c = Date.today().toStartOfMonth();
            ficheroFrecuenciaEntera.Fin_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            insert ficheroFrecuenciaEntera;

            VisMed_Contacto_Cuenta_Usuario__c ficheroFrecuenciaDecimalMenorAUno = Build.aVisMedContactCuentaUsuarioBuilder()
            .withAPM(apmSemaforo)
            .withInstitucion(institucion2)
            .withProfesional(profesional3)                
            .build();
            ficheroFrecuenciaDecimalMenorAUno.Estado_de_aprobacion__c = 'Aprobada';
            ficheroFrecuenciaDecimalMenorAUno.Estado__c = 'Activo';
            ficheroFrecuenciaDecimalMenorAUno.Predeterminada__c = true;
            ficheroFrecuenciaDecimalMenorAUno.Frecuencia__c = 0.5;
            ficheroFrecuenciaDecimalMenorAUno.Inicio_de_Frecuencia__c = Date.today().toStartOfMonth();
            ficheroFrecuenciaDecimalMenorAUno.Fin_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(2).addDays(-1);
            insert ficheroFrecuenciaDecimalMenorAUno;

            VisMed_Contacto_Cuenta_Usuario__c ficheroFrecuenciaDecimalMayorAUno = Build.aVisMedContactCuentaUsuarioBuilder()
            .withAPM(apmSemaforo)
            .withInstitucion(institucion3)
            .withProfesional(profesional)                
            .build();
            ficheroFrecuenciaDecimalMayorAUno.Estado_de_aprobacion__c = 'Aprobada';
            ficheroFrecuenciaDecimalMayorAUno.Estado__c = 'Activo';
            ficheroFrecuenciaDecimalMayorAUno.Predeterminada__c = true;
            ficheroFrecuenciaDecimalMayorAUno.Aun_Quedan_Meses__c = true;
            ficheroFrecuenciaDecimalMayorAUno.Frecuencia__c = 1.5;            
            ficheroFrecuenciaDecimalMayorAUno.Inicio_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(-1);
            ficheroFrecuenciaDecimalMayorAUno.Fin_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(2).addDays(-1);
            insert ficheroFrecuenciaDecimalMayorAUno;

            // VisMed_Contacto_Cuenta_Usuario__c ficheroFrecuenciaDecimalMayorAUno2 = Build.aVisMedContactCuentaUsuarioBuilder()
            // .withAPM(apmSemaforo)
            // .withInstitucion(institucion3)
            // .withProfesional(profesional3)                
            // .build();
            // ficheroFrecuenciaDecimalMayorAUno2.Estado_de_aprobacion__c = 'Aprobada';
            // ficheroFrecuenciaDecimalMayorAUno2.Estado__c = 'Activo';
            // ficheroFrecuenciaDecimalMayorAUno2.Predeterminada__c = true;
            // ficheroFrecuenciaDecimalMayorAUno2.Aun_Quedan_Meses__c = true;
            // ficheroFrecuenciaDecimalMayorAUno2.Frecuencia__c = 1.5;            
            // ficheroFrecuenciaDecimalMayorAUno2.Inicio_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(-1);
            // ficheroFrecuenciaDecimalMayorAUno2.Fin_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            // insert ficheroFrecuenciaDecimalMayorAUno2;

            // Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
            // List<Dan360_Interacciones__c> visitas = new List<Dan360_Interacciones__c>();
            // Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            // .withProfesional(profesional3)
            // .withAPM(apmSemaforo)
            // .withVisMedTipodeVisita('Presencial')
            // .withVisMedEfectividad(efectividad)
            // .withDomiciliodelaVisita(institucion3)
            // .withVisMedFecha(Date.today().addMonths(-1))
            // .build();
            // visita.Estado__c = 'Aprobada';
            // visita.RecordTypeId = recordTypeVisitaMedica;
            // visitas.add(visita);

            // Dan360_Interacciones__c visita2 = Build.aDan360Interacciones()
            // .withProfesional(profesional)
            // .withAPM(apm)
            // .withVisMedTipodeVisita('Presencial')
            // .withVisMedEfectividad(efectividad)
            // .withDomiciliodelaVisita(institucion)
            // .withVisMedFecha(Date.today().addMonths(-1))
            // .build();
            // visita2.Estado__c = 'Aprobada';
            // visita2.RecordTypeId = recordTypeVisitaMedica;
            // visitas.add(visita2);

            // insert visitas;

            VisMed_Contacto_Cuenta_Usuario__c ficheroFrecuenciaEnteraInactivo = Build.aVisMedContactCuentaUsuarioBuilder()
            .withAPM(apmSemaforo)
            .withInstitucion(institucion)
            .withProfesional(aPersonAccount)                
            .build();
            ficheroFrecuenciaEnteraInactivo.Estado_de_aprobacion__c = 'Aprobada';
            ficheroFrecuenciaEnteraInactivo.Estado__c = 'Inactivo';
            ficheroFrecuenciaEnteraInactivo.Predeterminada__c = false;
            ficheroFrecuenciaEnteraInactivo.Frecuencia__c = 2.0;
            ficheroFrecuenciaEnteraInactivo.Inicio_de_Frecuencia__c = Date.today().toStartOfMonth();
            ficheroFrecuenciaEnteraInactivo.Fin_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            insert ficheroFrecuenciaEnteraInactivo;

        }
    }

    @isTest
    public static void cuandoUnFicheroSeVuelveAActivarDesdeAppSeBlanqueaCampos(){
        VisMed_Contacto_Cuenta_Usuario__c ficheroInactivo = [SELECT id, Frecuencia__c,Categoria__c,Aun_Quedan_Meses__c ,
                                                                    Inicio_de_Frecuencia__c,Fin_de_Frecuencia__c , Visitas_Realizadas__c 
                                                            FROM VisMed_Contacto_Cuenta_Usuario__c
                                                            WHERE Estado__c = 'Inactivo'];
        System.debug(ficheroInactivo);

        ficheroInactivo.Estado__c = 'Pendiente';
        ficheroInactivo.Actualizar_Frecuencia__c = true;
        ficheroInactivo.Segmenta_Por__c = 'Epilepsia';

        Test.startTest();
            update ficheroInactivo;
        Test.stopTest();

        VisMed_Contacto_Cuenta_Usuario__c ficheroPendiente = [SELECT id, Frecuencia__c,Categoria__c,Aun_Quedan_Meses__c ,
                                                                    Inicio_de_Frecuencia__c,Fin_de_Frecuencia__c , Visitas_Realizadas__c 
                                                            FROM VisMed_Contacto_Cuenta_Usuario__c
                                                            WHERE id = :ficheroInactivo.id];
        
        System.assertEquals(null, ficheroPendiente.Frecuencia__c, 'No se blanqueo correctamente');
        System.assertEquals(false, ficheroPendiente.Aun_Quedan_Meses__c, 'No se blanqueo correctamente');
        System.assertEquals(null, ficheroPendiente.Categoria__c, 'No se blanqueo correctamente');
        System.assertEquals(null, ficheroPendiente.Inicio_de_Frecuencia__c, 'No se blanqueo correctamente');
        System.assertEquals(null, ficheroPendiente.Fin_de_Frecuencia__c, 'No se blanqueo correctamente');
        System.assertEquals(0, ficheroPendiente.Visitas_Realizadas__c, 'No se blanqueo correctamente');
    }
    @IsTest
    public static void cuandoApmCargaVisitaYEsMayorIgualALaFrecuenciaEnteraSemaforoDebeSerVerde(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){
            Contact apm = [
                SELECT Id
                FROM Contact
                WHERE VisMed_DNI__c = '22222444'
            ];
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional3' AND LastName = 'Test3'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest'
            ];            
            Dan360_Efectividad__c efectividad = [
                SELECT Id
                FROM Dan360_Efectividad__c
                WHERE VisMed_APM__c = :apm.Id
            ]; 

            VisMed_Contacto_Cuenta_Usuario__c fichero = [
                SELECT Id, VisMed_Semaforo__c, Aun_Quedan_Meses__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id           
            ];           
            System.debug('fichero '+fichero);
            Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();           
            List<Dan360_Interacciones__c> visitas = new List<Dan360_Interacciones__c>();
            Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today())
            .build();
            visita.Estado__c = 'Aprobada';
            visita.RecordTypeId = recordTypeVisitaMedica;
            visitas.add(visita);
            Dan360_Interacciones__c visita2 = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today())
            .build();
            visita2.Estado__c = 'Aprobada';
            visita2.RecordTypeId = recordTypeVisitaMedica;
            visitas.add(visita2);

            Test.startTest();
            insert visitas;            
            Test.stopTest();

            VisMed_Contacto_Cuenta_Usuario__c segToCompare = [
                SELECT Id, VisMed_Semaforo__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id                
            ];            

            System.assertEquals('Verde', segToCompare.VisMed_Semaforo__c, 'Error al cambiar semaforo');
        }
        
    }
    @IsTest
    public static void cuandoApmCargaVisitaYEsMenorAlTotalFrecuenciaSemaforoDebeSerAmarillo(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){
            Contact apm = [
                SELECT Id
                FROM Contact
                WHERE VisMed_DNI__c = '22222444'
            ];
            
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest3'
            ];            
            Dan360_Efectividad__c efectividad = [
                SELECT Id
                FROM Dan360_Efectividad__c
                WHERE VisMed_APM__c = :apm.Id
            ]; 

            VisMed_Contacto_Cuenta_Usuario__c fichero = [
                SELECT Id, VisMed_Semaforo__c,Profesional__c, VisMed_APM__c, Aun_Quedan_Meses__c, Inicio_de_Frecuencia__c, Fin_de_Frecuencia__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Frecuencia__c = 1.5
                        
            ];
            fichero.Aun_Quedan_Meses__c = false;
            fichero.Inicio_de_Frecuencia__c = Date.today().addMonths(-1).toStartOfMonth();     
            fichero.Fin_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            update fichero; 
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE Id = :fichero.Profesional__c
            ];    
            System.debug('fichero '+fichero);
            Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();           
            List<Dan360_Interacciones__c> visitas = new List<Dan360_Interacciones__c>();
            Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today().addDays(1))
            .build();
            visita.Estado__c = 'Aprobada';
            visita.RecordTypeId = recordTypeVisitaMedica;
            visitas.add(visita);
            Dan360_Interacciones__c visita2 = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today())
            .build();
            visita2.Estado__c = 'Aprobada';
            visita2.RecordTypeId = recordTypeVisitaMedica;
            visitas.add(visita2);

            Test.startTest();
            insert visitas;            
            Test.stopTest();

            VisMed_Contacto_Cuenta_Usuario__c segToCompare = [
                SELECT Id, VisMed_Semaforo__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id                
            ];            

            System.assertEquals('Amarillo', segToCompare.VisMed_Semaforo__c, 'Error al cambiar semaforo');
        }
        
    }
    @IsTest
    public static void cuandoApmCargaVisitaYEsMenorALaFrecuenciaEnteraSemaforoDebeSerAmarillo(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){
            Contact apm = [
                SELECT Id
                FROM Contact
                WHERE VisMed_DNI__c = '22222444'
            ];
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional3' AND LastName = 'Test3'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest'
            ];            
            Dan360_Efectividad__c efectividad = [
                SELECT Id
                FROM Dan360_Efectividad__c
                WHERE VisMed_APM__c = :apm.Id
            ]; 

            VisMed_Contacto_Cuenta_Usuario__c fichero = [
                SELECT Id, VisMed_Semaforo__c, Aun_Quedan_Meses__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id           
            ];           
            System.debug('fichero '+fichero);
            Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();           
            List<Dan360_Interacciones__c> visitas = new List<Dan360_Interacciones__c>();
            Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today())
            .build();
            visita.Estado__c = 'Aprobada';
            visita.RecordTypeId = recordTypeVisitaMedica;
            visitas.add(visita);            

            Test.startTest();
            insert visitas;            
            Test.stopTest();

            VisMed_Contacto_Cuenta_Usuario__c segToCompare = [
                SELECT Id, VisMed_Semaforo__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id                
            ];            

            System.assertEquals('Amarillo', segToCompare.VisMed_Semaforo__c, 'Error al cambiar semaforo');
        }
        
    }
    @IsTest
    public static void cuandoApmCargaVisitaSeEliminaYVisitaVuelveACeroElSemaforoDebeVolverARojo(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){
            Contact apm = [
                SELECT Id
                FROM Contact
                WHERE VisMed_DNI__c = '22222444'
            ];
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional3' AND LastName = 'Test3'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest'
            ];            
            Dan360_Efectividad__c efectividad = [
                SELECT Id
                FROM Dan360_Efectividad__c
                WHERE VisMed_APM__c = :apm.Id
            ]; 
            
            Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();           
            List<Dan360_Interacciones__c> visitas = new List<Dan360_Interacciones__c>();
            Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today())
            .build();
            visita.Estado__c = 'Aprobada';
            visita.RecordTypeId = recordTypeVisitaMedica;
            visitas.add(visita);            
            insert visitas;  
            VisMed_Contacto_Cuenta_Usuario__c segToCompare = [
                SELECT Id, VisMed_Semaforo__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id                
            ];          
            System.assertEquals('Amarillo', segToCompare.VisMed_Semaforo__c, 'Error al cambiar semaforo a amarillo');
            Test.startTest();
            delete visita;
            Test.stopTest();

            VisMed_Contacto_Cuenta_Usuario__c segToCompare2 = [
                SELECT Id, VisMed_Semaforo__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id                
            ];            

            System.assertEquals('Rojo', segToCompare2.VisMed_Semaforo__c, 'Error al cambiar semaforo a rojo');
        }
        
    }
    @IsTest
    public static void cuandoApmCargaVisitaElSegundoMesYEsMayorIgualALaFrecuenciaDecimalMayorAUnoSemaforoDebeSerAmarillo(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){
            Contact apm = [
                SELECT Id
                FROM Contact
                WHERE VisMed_DNI__c = '22222444'
            ];
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional2' AND LastName = 'Test2'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest3'
            ];            
            Dan360_Efectividad__c efectividad = [
                SELECT Id
                FROM Dan360_Efectividad__c
                WHERE VisMed_APM__c = :apm.Id
            ]; 
            Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();           
            List<Dan360_Interacciones__c> visitas = new List<Dan360_Interacciones__c>();
            Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today())
            .build();
            visita.Estado__c = 'Aprobada';
            visita.RecordTypeId = recordTypeVisitaMedica;
            visitas.add(visita);
            Dan360_Interacciones__c visita2 = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today().addMonths(1).addDays(-2))
            .build();
            visita2.Estado__c = 'Aprobada';
            visita2.RecordTypeId = recordTypeVisitaMedica;
            visitas.add(visita2);

            Test.startTest();
            insert visitas;            
            Test.stopTest();

            VisMed_Contacto_Cuenta_Usuario__c segToCompare = [
                SELECT Id, VisMed_Semaforo__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id
            ];            

            System.assertEquals('Amarillo', segToCompare.VisMed_Semaforo__c, 'Error al cambiar semaforo');
        }
        
    }	
    @IsTest
    public static void cuandoApmCargaVisitaElPrimerMesYEsMayorIgualALaFrecuenciaDecimalMayorAUnoSemaforoDebeSerAmarillo(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){
            Contact apm = [
                SELECT Id
                FROM Contact
                WHERE VisMed_DNI__c = '22222444'
            ];
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional2' AND LastName = 'Test2'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest3'
            ];            
            Dan360_Efectividad__c efectividad = [
                SELECT Id
                FROM Dan360_Efectividad__c
                WHERE VisMed_APM__c = :apm.Id
            ]; 
            VisMed_Contacto_Cuenta_Usuario__c fichero = [
                SELECT Id, VisMed_Semaforo__c, Aun_Quedan_Meses__c,Inicio_de_Frecuencia__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id           
            ];           
            fichero.Inicio_de_Frecuencia__c = Date.today().toStartOfMonth();
            update fichero;
            
            Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();           
            List<Dan360_Interacciones__c> visitas = new List<Dan360_Interacciones__c>();
            Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today())
            .build();
            visita.Estado__c = 'Aprobada';
            visita.RecordTypeId = recordTypeVisitaMedica;
            visitas.add(visita);
            Dan360_Interacciones__c visita2 = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today().addMonths(1).addDays(-2))
            .build();
            visita2.Estado__c = 'Aprobada';
            visita2.RecordTypeId = recordTypeVisitaMedica;
            visitas.add(visita2);

            Test.startTest();
            insert visitas;            
            Test.stopTest();

            VisMed_Contacto_Cuenta_Usuario__c segToCompare = [
                SELECT Id, VisMed_Semaforo__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id
            ];            

            System.assertEquals('Amarillo', segToCompare.VisMed_Semaforo__c, 'Error al cambiar semaforo');
        }
        
    }	
    //@IsTest
    public static void cuandoApmCargaVisitaEnElUtimoMesYEsMayorIgualAlTotalDeFrecuenciaDecimalMayorAUnoSemaforoDebeSerVerde(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){
            Contact apm = [
                SELECT Id
                FROM Contact
                WHERE VisMed_DNI__c = '22222444'
            ];
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional3' AND LastName = 'Test3'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest3'
            ];            
            Dan360_Efectividad__c efectividad = [
                SELECT Id
                FROM Dan360_Efectividad__c
                WHERE VisMed_APM__c = :apm.Id
            ]; 

            Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();           
            List<Dan360_Interacciones__c> visitas = new List<Dan360_Interacciones__c>();
            // Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            // .withProfesional(profesional)
            // .withAPM(apm)
            // .withVisMedTipodeVisita('Presencial')
            // .withVisMedEfectividad(efectividad)
            // .withDomiciliodelaVisita(institucion)
            // .withVisMedFecha(Date.today().addMonths(-1))
            // .build();
            // visita.Estado__c = 'Aprobada';
            // visita.RecordTypeId = recordTypeVisitaMedica;
            // visitas.add(visita);

            Dan360_Interacciones__c visita2 = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today())
            .build();
            visita2.Estado__c = 'Aprobada';
            visita2.RecordTypeId = recordTypeVisitaMedica;
            visitas.add(visita2);
            
            VisMed_Contacto_Cuenta_Usuario__c fichero = [
                SELECT Id, VisMed_Semaforo__c,Visitas_acumuladas__c, Aun_Quedan_Meses__c,Inicio_de_Frecuencia__c, Fin_de_Frecuencia__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id           
            ];         
            
            fichero.Aun_Quedan_Meses__c = false;
            fichero.Visitas_acumuladas__c = 2;
            update fichero;

            
            Dan360_Interacciones__c visita3 = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today())
            .build();
            visita3.Estado__c = 'Aprobada';
            visita3.RecordTypeId = recordTypeVisitaMedica;            
            visitas.add(visita3);
            
            Test.startTest();
            insert visitas; 
            Test.stopTest();
            
            VisMed_Contacto_Cuenta_Usuario__c segToCompare = [
                SELECT Id, VisMed_Semaforo__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id
            ];            

            System.assertEquals('Amarillo', segToCompare.VisMed_Semaforo__c, 'Error al cambiar semaforo');
        }
        
    }	
    @IsTest
    public static void cuandoApmCargaVisitaYEsMayorIgualALaFrecuenciaDecimalMenorAUnoSemaforoDebeSerVerde(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){
            Contact apm = [
                SELECT Id
                FROM Contact
                WHERE VisMed_DNI__c = '22222444'
            ];
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional3' AND LastName = 'Test3'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest2'
            ];            
            Dan360_Efectividad__c efectividad = [
                SELECT Id
                FROM Dan360_Efectividad__c
                WHERE VisMed_APM__c = :apm.Id
            ]; 
            Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();           
            List<Dan360_Interacciones__c> visitas = new List<Dan360_Interacciones__c>();
            Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today())
            .build();
            visita.Estado__c = 'Aprobada';
            visita.RecordTypeId = recordTypeVisitaMedica;

            visitas.add(visita);

            Dan360_Interacciones__c visita2 = Build.aDan360Interacciones()
            .withProfesional(profesional)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(institucion)
            .withVisMedFecha(Date.today())
            .build();
            visita2.Estado__c = 'Aprobada';
            visita2.RecordTypeId = recordTypeVisitaMedica;

            visitas.add(visita2);

            Test.startTest();
            insert visitas;            
            Test.stopTest();

            VisMed_Contacto_Cuenta_Usuario__c segToCompare = [
                SELECT Id, VisMed_Semaforo__c, Visitas_Realizadas__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE VisMed_APM__c = :apm.Id
                AND Profesional__c = : profesional.Id
                AND Institucion__c = : institucion.Id
            ];            

            System.assertEquals('Verde', segToCompare.VisMed_Semaforo__c, 'Error al cambiar semaforo');
            System.assertEquals(2, segToCompare.Visitas_Realizadas__c, 'Error al cambiar Visita');
        }
        
    }	
    @IsTest
    public static void cuandoSeCreaSeguimientoSeDebeAsignarAlAPMCorrespondiente(){
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

            VisMed_Contacto_Cuenta_Usuario__c seg = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(profesional)
                .build();
            Test.startTest();
            insert seg;
            Test.stopTest();

            VisMed_Contacto_Cuenta_Usuario__c segToCompare = [
                SELECT Id, OwnerId
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE Id = :seg.Id
            ];

            User userApm = [
            SELECT Id
            FROM User
            WHERE Alias = 'contact1'
        ];

            System.assertEquals(userApm.Id, segToCompare.OwnerId, 'Error al asignar seguimiento al APM');
        }
        
    }	
    @IsTest
    public static void cuandoSeCreaSeguimientoSeDebeActivarElProfesional(){
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
                SELECT Id, Profesional_Activo__c
                FROM Account
                WHERE FirstName = 'Profesional' AND LastName = 'Test'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest'
            ];            

            VisMed_Contacto_Cuenta_Usuario__c seg = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(profesional)
                .build();
            Test.startTest();
            insert seg;
            Test.stopTest();

            Account profesionalToCompare =[
                SELECT Id, Profesional_Activo__c
                FROM Account
                WHERE FirstName = 'Profesional' AND LastName = 'Test'
            ];
            
            System.assertEquals(true, profesionalToCompare.Profesional_Activo__c, 'Error al activar el  profesional');            
        }        
    }	
    @IsTest
    public static void cuandoSeCreaSeguimientoSeDebeAccountTeamMember(){
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
                SELECT Id, Profesional_Activo__c
                FROM Account
                WHERE FirstName = 'Profesional' AND LastName = 'Test'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest'
            ];            

            VisMed_Contacto_Cuenta_Usuario__c seg = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(profesional)
                .build();
            seg.Estado__c = 'Activo';
            Test.startTest();
            insert seg;
            Test.stopTest();

            User userApm = [
                SELECT Id
                FROM User
                WHERE Alias = 'contact1'
            ];

            List<AccountTeamMember> atmToCompare =[
                SELECT Id
                FROM AccountTeamMember
                WHERE UserId = :userApm.Id
            ];
            
            System.assertEquals(4, atmToCompare.size() , 'Error al crear account team Member');            
        }        
    }	
    @IsTest
    public static void cuandoSeCreaSeguimientoConSegmentaSeDebeSetearFrecuencia(){
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
                SELECT Id, Profesional_Activo__c
                FROM Account
                WHERE FirstName = 'Profesional' AND LastName = 'Test'
            ];
            Account institucion = [
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest'
            ];            

            VisMed_Contacto_Cuenta_Usuario__c seg = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(profesional)
                .withSegmentaPor('Pediatricos General')               
                .build();
            seg.Predeterminada__c = true;            
            seg.Estado__c = 'Activo';  
             
            Test.startTest();
            insert seg;
            Test.stopTest();

            

            List<VisMed_Contacto_Cuenta_Usuario__c> ficherosToCompare = [
            SELECT ID, Segmenta_Por__c, Frecuencia__c, Categoria__c, Fecha_de_Aprobacion__c
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE id = :seg.Id
            ];
        System.debug(ficherosToCompare);
        // Asserts
        System.assertEquals(0.5, ficherosToCompare[0].Frecuencia__c, 'Error al  obtener frecuencia');
        System.assertEquals('D', ficherosToCompare[0].Categoria__c, 'Error al  obtener categoria');            
        }        
    }	
    @IsTest
    public static void cuandoApruebaAltaDeProfesionalSeDebeCrearLaSegmentacionDelProfesionalSiNoExiste(){
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
                WHERE FirstName = 'Profesional2' AND LastName = 'Test2'
            ];
            
            VisMed_Contacto_Cuenta_Usuario__c seg = [
                SELECT Id, Estado_de_aprobacion__c, Profesional__c, Segmenta_Por__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE Profesional__c = :profesional.Id AND Predeterminada__c = true
                AND VisMed_APM__c = : apm.Id
            ];
            seg.Estado_de_aprobacion__c = 'Aprobada';
            seg.Segmenta_Por__c = 'Alergia';
            Test.startTest();
            update seg;
            Test.stopTest();

            Id tipoSegmentacion = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByName().get(seg.Segmenta_Por__c).getRecordTypeId();
            List<VisMed_Segmentacion__c> segmentacion = [
                SELECT Id, Profesional__c, RecordType.Name
                FROM VisMed_Segmentacion__c
                WHERE Profesional__c = :seg.Profesional__c
                    AND RecordType.Name = 'Alergia'
            ];          
            
            System.assertEquals('Alergia', segmentacion[0].RecordType.Name, 'Error al crear segmentacion');            
        }        
    }

    @IsTest
    public static void cuandoSeCargaUnValorPorPrimeraVezAlCampoSegmentaPorDebeCargarLaFrecuencia(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){

            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional2' AND LastName = 'Test2'
            ];
            Contact apm = [
                SELECT Id
                FROM Contact
                WHERE VisMed_DNI__c = '22222333'
            ];
            
            VisMed_Contacto_Cuenta_Usuario__c seg = [
                SELECT Id, Estado_de_aprobacion__c, Profesional__c, Segmenta_Por__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE Profesional__c = :profesional.Id AND Predeterminada__c = true
                AND VisMed_APM__c = : apm.Id
            ];
            seg.Estado_de_aprobacion__c = 'Aprobada';
            seg.Segmenta_Por__c = 'Alergia';
            Test.startTest();
            update seg;
            Test.stopTest();

            Id tipoSegmentacion = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByName().get(seg.Segmenta_Por__c).getRecordTypeId();
            List<VisMed_Segmentacion__c> segmentacion = [
                SELECT Id, Profesional__c, RecordType.Name, Frecuencia__c, Categoria__c
                FROM VisMed_Segmentacion__c
                WHERE Profesional__c = :seg.Profesional__c
                AND RecordType.Name = 'Alergia'
            ];          
            
            System.assertEquals('Alergia', segmentacion[0].RecordType.Name, 'Error al crear segmentacion');            
            System.assertNotEquals(null, segmentacion[0].Frecuencia__c, 'Error al crear segmentacion');            
            System.assertNotEquals(null, segmentacion[0].Categoria__c, 'Error al crear segmentacion');            
        }        
    }   
   // @IsTest
    // public static void cuandoSeActulizaFicheroPrincipalPasaLosCambiosALosFicherosRelacionados(){
    //     User userOwner = [
    //         SELECT Id
    //         FROM User
    //         WHERE Alias = 'owner'
    //     ];
    //     system.runAs(userOwner){

    //         Account profesional =[
    //             SELECT Id
    //             FROM Account
    //             WHERE FirstName = 'Profesional2' AND LastName = 'Test2'
    //         ];
    //         Contact apm = [
    //             SELECT Id
    //             FROM Contact
    //             WHERE VisMed_DNI__c = '22222333'
    //         ];
            
    //         VisMed_Contacto_Cuenta_Usuario__c seg = [
    //             SELECT Id, Frecuencia__c, Fin_de_Frecuencia__c, Inicio_de_Frecuencia__c,Visitas_acumuladas__c, Segmenta_Por__c,
    //             Categoria__c, VisMed_Semaforo__c, Ultima_Visita__c, Visitas_Realizadas__c, Plan__c, VisMed_APM__c, Profesional__c
    //             FROM VisMed_Contacto_Cuenta_Usuario__c
    //             WHERE Profesional__c = :profesional.Id AND Predeterminada__c = true
    //             AND VisMed_APM__c = : apm.Id
    //             AND Predeterminada__c = true
    //         ];
    //         seg.Estado_de_aprobacion__c = 'Aprobada';
    //         seg.Segmenta_Por__c = 'Alergia';
    //         seg.Inicio_de_Frecuencia__c = Date.today().toStartOfMonth().addDays(1);
    //         seg.Fin_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
    //         seg.Frecuencia__c = 2;
    //         seg.Visitas_acumuladas__c = 3;
    //         seg.Categoria__c = 'B';
    //         seg.VisMed_Semaforo__c = 'Verde';
    //         seg.Ultima_Visita__c = Date.today();
    //         seg.Visitas_Realizadas__c = 2;
    //         //seg.Plan__c = 'Alergia';
    //         Test.startTest();
    //         update seg;
    //         Test.stopTest();
            
    //         List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [
    //             SELECT Id, Frecuencia__c, Fin_de_Frecuencia__c, Inicio_de_Frecuencia__c,Visitas_acumuladas__c, Segmenta_Por__c,
    //             Categoria__c, VisMed_Semaforo__c, Ultima_Visita__c, Visitas_Realizadas__c, Plan__c, VisMed_APM__c, Profesional__c
    //             FROM VisMed_Contacto_Cuenta_Usuario__c
    //             WHERE Profesional__c = :seg.Profesional__c
    //             AND VisMed_APM__c = : apm.Id
    //             AND Predeterminada__c = false                
    //         ];          
            
    //         System.assertEquals('Alergia', seguimientos[0].Segmenta_Por__c, 'Error al sincronizar fichero');            
    //         System.assertEquals(Date.today().toStartOfMonth().addDays(1), seguimientos[0].Inicio_de_Frecuencia__c, 'Error al sincronizar fichero');            
    //         System.assertEquals(Date.today().toStartOfMonth().addMonths(1).addDays(-1), seguimientos[0].Fin_de_Frecuencia__c, 'Error al sincronizar fichero');            
    //         System.assertEquals(2, seguimientos[0].Frecuencia__c, 'Error al sincronizar fichero');            
    //         System.assertEquals(3, seguimientos[0].Visitas_acumuladas__c, 'Error al sincronizar fichero');            
    //         System.assertEquals('B', seguimientos[0].Categoria__c, 'Error al sincronizar fichero');            
    //         System.assertEquals('Verde', seguimientos[0].VisMed_Semaforo__c, 'Error al sincronizar fichero');           
    //         System.assertEquals(Date.today(), seguimientos[0].Ultima_Visita__c, 'Error al sincronizar fichero');           
    //         System.assertEquals(2, seguimientos[0].Visitas_Realizadas__c, 'Error al sincronizar fichero');           
    //         //System.assertEquals('Alergia', seguimientos[0].Plan__c, 'Error al sincronizar fichero');           
    //     }
    // }   

    @IsTest
    public static void cuandoSeCargaApruebaAltaDebeCrearNotificacion(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){

            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional' AND LastName = 'Test'
            ];
            
            VisMed_Contacto_Cuenta_Usuario__c seg = [
                SELECT Id, Estado_de_aprobacion__c, VisMed_APM__c, Profesional__c, Segmenta_Por__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE Estado__c = 'Pendiente' AND Predeterminada__c = false
            ];
            seg.Estado_de_aprobacion__c = 'Aprobada';
            seg.Estado__c = 'Activo';
            
            Test.startTest();
            update seg;
            Test.stopTest();
            
            List<Notificacion__c> notificacion = [
                SELECT Id, Id_del_Objeto__c,APM__c
                FROM Notificacion__c
                WHERE Id_del_Objeto__c = :seg.Id                
            ];          
            
            System.assertEquals(seg.VisMed_APM__c, notificacion[0].APM__c, 'Error al crear notificacion');            
            System.assertEquals(seg.Id, notificacion[0].Id_del_Objeto__c, 'Error al crear notificacion');            
                      
        }        
    }
    
    @IsTest
    public static void testBlankFieldMotivo(){
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

            Account institucion =[
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest2'
            ];
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional2' AND LastName = 'Test2'
            ];
            VisMed_Contacto_Cuenta_Usuario__c seg = [
                SELECT Id, Estado_de_aprobacion__c, Profesional__c, Predeterminada__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE Frecuencia__c = 2.0                 
                AND Estado__c = 'Inactivo'                
            ];
            
            seg.Estado__c = 'Activo';
            seg.Motivo_de_la_Baja__c = 'Bajo Potencial';
            
            Test.startTest();            
            update seg;
            Test.stopTest();
           
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [
                SELECT Id, Profesional__c, Motivo_de_la_Baja__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE Id = :seg.Id                 
            ];          
            
            System.assertEquals(null, seguimientos[0].Motivo_de_la_Baja__c, 'Error al limpiar campo');            
            
        }        
    }
    @isTest
    static void soloPuedeHaberUnSoloFicheroComoPredeterminado() {
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

            Account institucion =[
                SELECT Id
                FROM Account
                WHERE Name = 'InstitucionTest2'
            ];
            Account profesional =[
                SELECT Id
                FROM Account
                WHERE FirstName = 'Profesional2' AND LastName = 'Test2'
            ];
            VisMed_Contacto_Cuenta_Usuario__c seg = [
                SELECT Id, Estado_de_aprobacion__c, Profesional__c, Predeterminada__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE Institucion__c = :institucion.Id 
                AND Profesional__c = :profesional.Id
                AND VisMed_APM__c = :apm.Id
            ];
            seg.Estado_de_aprobacion__c = 'Aprobada';
            seg.Predeterminada__c = true;
            seg.Estado__c = 'Activo';
            Test.startTest();
            update seg;
            Test.stopTest();
           
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientos = [
                SELECT Id, Profesional__c
                FROM VisMed_Contacto_Cuenta_Usuario__c
                WHERE Profesional__c = :seg.Profesional__c 
                AND Predeterminada__c = true
                AND VisMed_APM__c = : apm.Id
            ];          
            
            System.assertEquals(1, seguimientos.size(), 'Error al dejar un solo  predeterminado');            
            System.assertEquals(seg.Id, seguimientos[0].Id, 'Error al dejar un solo predeterminado');
        }
    }
}