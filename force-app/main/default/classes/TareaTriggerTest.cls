@isTest
public class TareaTriggerTest  {
    
    static Account pacienteTest1;
    static task tareaTest;
    
    static {
        
        pacienteTest1 = Build.anAccountPacienteBestCare()
            .withLastName('Paciente')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En Seguimiento')
            .withSubestadoDePaciente('Tramite iniciado')
            //.withCanalParaConsumidorBaby('Almacen')
            .build();
        insert pacienteTest1;
        
        tareaTest = Build.aTaskLlamadodeseguimiento()
            .build();
        insert tareaTest;
        
    }
    
    @IsTest
    public static void verifyIfCalculateCorrectlyTheActivityDate(){
        Id llamadaSeguimiento = XappiaHelper.getRecordTypeToTratamiento('Task','Llamado de seguimiento');
        
        Task t1 = Build.aTaskLlamadodeseguimiento()
            .withSubject('Revisar status del envio del KIT')
            .withDescription('1. Revisar que no haya reclamos de pedido no entregado por parte de Logística que haga referencia al KIT.')
            .build();
        
        Test.startTest();
        insert t1;
        Test.stopTest();
        
        
        List<Task> tareas = [
            SELECT Id,ActivityDate
            FROM Task
            WHERE Id = :t1.id
        ];
        
        system.assert(tareas.get(0).ActivityDate != null);
        
    }
    
    @IsTest
    public static void verifygetNextWorkingDay(){
        
        BusinessHours bHours = [
            SELECT Id 
            FROM BusinessHours 
            WHERE IsDefault = true
        ];
        Test.startTest();
        Datetime dt = TareaTriggerHelper.getNextWorkingDay(bHours.Id,System.now());
        Test.stopTest();
        
        system.assert(dt != null);
    }    
    
    @isTest
    public static void verifyActivityDateWhenTaskIsSeguimientoAndLlamada(){
        
        Task tareaSeguimiento = Build.aTaskLlamadodeseguimiento()
            .withSubject('Seguimiento - MES 1')
            .build();
        
        Test.startTest();
        insert tareaSeguimiento;
        Test.stopTest();
        
        List<Task> tarea = [
            SELECT id,ActivityDate,CreatedDate
            FROM Task
            WHERE Id = :tareaSeguimiento.id
        ];
        
        system.assertEquals(1, tarea.size());
        system.assertEquals(System.today(), tarea.get(0).CreatedDate.date());
        system.assertEquals(System.today().addDays(29),tarea.get(0).ActivityDate);
        
        
    }
    
    @isTest
    public static void whenCreateATaskAssociatedFieldFromAccountRelated(){
        Account pacientePrueba = Build.anAccountPacienteBestCare()
            .withLastName('Nombre completo del paciente')
            .build();
        pacientePrueba.Obra_social__c = 'Obra social del paciente';
        pacientePrueba.Area_terapeutica__c = 'Alergia';
        insert pacientePrueba;
        
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Tarea' LIMIT 1];
        
        Task tareaPrueba = Build.aTaskLlamadodeseguimiento()
            .withRecordTypeId(rt)
            .withWhatId(pacientePrueba)
            .build();
        
        Test.startTest();
        insert tareaPrueba;
        Test.stopTest();
        
        tareaPrueba = [SELECT Id, WhatId, Nombre_de_la_obra_social__c, Nombre_y_Apellido_del_Paciente__c, Area_terap_utica__c FROM Task WHERE Id = :tareaPrueba.id];
        
        System.assertEquals(pacientePrueba.Id,tareaPrueba.WhatId);
        System.assertEquals('Obra social del paciente', tareaPrueba.Nombre_de_la_obra_social__c); 
        System.assertEquals('Nombre completo del paciente', tareaPrueba.Nombre_y_Apellido_del_Paciente__c); 
        System.assertEquals('Alergia', tareaPrueba.Area_terap_utica__c); 
    }
    
    @isTest
    Public static void alCompletarUnaTareaDeLlamadaDeSeguimientoYLaFechaSeaMayorAlCampoUltimoLlamadoSeguimientoActualizarDichoCampo(){
        
        tareaTest.WhatId = pacienteTest1.Id;
        tareaTest.Status = 'Completa';
        
        Test.startTest();
        update tareaTest;
        Test.stopTest();
        
        Task tarea = [
            SELECT Id, Status, isclosed
            FROM Task
            WHERE Id = :tareaTest.Id
            LIMIT 1
        ];
        
        Account paciente = [
            SELECT Id, Ultimo_llamado_de_seguimiento__c
            FROM Account
            WHERE Id = :pacienteTest1.Id
            LIMIT 1
        ];
        
        System.assertEquals('Completa', tarea.Status);
        System.assertEquals(true, tarea.IsClosed);
        System.assertEquals(Date.today(), paciente.Ultimo_llamado_de_seguimiento__c);
    }
    
    @isTest
    Public static void alInsertarUnaTareaConEstatusCompletaYLaFechaSeaMayorAlCampoUltimoLlamadoSeguimientoActualizarDichoCampo(){
        
        delete tareaTest;
        tareaTest = Build.aTaskLlamadodeseguimiento()
            .withWhatId(pacienteTest1)
            .withStatus('Completa')
            .build();
        
        Test.startTest();
        insert tareaTest;
        Test.stopTest();
        
        Task tarea = [
            SELECT Id, Status, isclosed
            FROM Task
            WHERE Id = :tareaTest.Id
            LIMIT 1
        ];
        
        Account paciente = [
            SELECT Id, Ultimo_llamado_de_seguimiento__c
            FROM Account
            WHERE Id = :pacienteTest1.Id
            LIMIT 1
        ];
        
        System.assertEquals('Completa', tarea.Status);
        System.assertEquals(true, tarea.IsClosed);
        System.assertEquals(Date.today(), paciente.Ultimo_llamado_de_seguimiento__c);
    }
    
    @isTest
    Public static void siLaTareaNoTieneUnPacienteAsociadoNoActualizaElCampoAlCompletarla(){
        
        tareaTest.Status = 'Completa';
        
        Test.startTest();
        update tareaTest;
        Test.stopTest();
        
        Task tarea = [
            SELECT Id, Status, isclosed
            FROM Task
            WHERE Id = :tareaTest.Id
            LIMIT 1
        ];
        
        Account paciente = [
            SELECT Id, Ultimo_llamado_de_seguimiento__c
            FROM Account
            WHERE Id = :pacienteTest1.Id
            LIMIT 1
        ];
        
        System.assertEquals('Completa', tarea.Status);
        System.assertEquals(true, tarea.IsClosed);
        System.assertEquals(null, paciente.Ultimo_llamado_de_seguimiento__c);
    }
    
    @isTest
    Public static void siLaTareaSeInsertaConEstatusCompletaYNoTieneUnPacienteAsociadoNoActualizaElCampo(){
        
        delete tareaTest;
        tareaTest = Build.aTaskLlamadodeseguimiento()
            .withStatus('Completa')
            .build();
        
        Test.startTest();
        insert tareaTest;
        Test.stopTest();
        
        Task tarea = [
            SELECT Id, Status, isclosed
            FROM Task
            WHERE Id = :tareaTest.Id
            LIMIT 1
        ];
        
        Account paciente = [
            SELECT Id, Ultimo_llamado_de_seguimiento__c
            FROM Account
            WHERE Id = :pacienteTest1.Id
            LIMIT 1
        ];
        
        System.assertEquals('Completa', tarea.Status);
        System.assertEquals(true, tarea.IsClosed);
        System.assertEquals(null, paciente.Ultimo_llamado_de_seguimiento__c);
    }
    @IsTest
    static void InsertoTareas_VisiblesParaPartnerComunity()
    {
        delete tareaTest;
        tareaTest = new Task();
        Test.startTest();
        insert tareaTest;
        Test.stopTest();
        tareaTest = [SELECT Id, IsVisibleInSelfService FROM Task WHERE IsVisibleInSelfService = true LIMIT 1];
        System.assert(tareaTest.IsVisibleInSelfService, 'Las tareas no se estan creando visibles');
    }
    @isTest 
    static void InsertTaskOfRecordTypeVisitaAndCaseMotivoDifferentVisita_NotInsertTask(){
        List<recordtype> RTTaskVisita = [
            SELECT Id
            FROM recordtype
            WHERE DeveloperName = 'Visita'
            LIMIT 1
        ];
        List<recordtype> RTCaseRegular = [
            SELECT Id
            FROM recordtype
            WHERE DeveloperName = 'General'
            LIMIT 1
        ];
        
        case caso = build.aCase().forAccount(pacienteTest1).build();
        caso.RecordTypeId = RTCaseRegular[0].Id;
        caso.type = 'Gestión';
        caso.Subtipo__c = 'Profesionales de la salud';
        caso.Motivo__c = 'Becas';
        insert caso;
        
        Task tarea = build.aTaskVisita().withWhatId(caso).build();
        tarea.RecordTypeId = RTtaskVisita[0].Id;
        
        string error;
        Test.startTest();
        try {
            insert tarea;
        } catch (Exception e) {
            error = e.getMessage();
        }
        Test.stopTest();
        
        System.assert(error.contains('Solo se puede usar el Tipo de Registro de Tarea Visita para Casos de Motivo Visita'));
        
    }
    @isTest 
    static void InsertTaskOfRecordTypeVisitaAndCaseMotivoDifferentVisita_NotUpdateTask(){
        List<recordtype> RTTaskVisita = [
            SELECT Id
            FROM recordtype
            WHERE DeveloperName = 'Visita'
            LIMIT 1
        ];
        List<recordtype> RTCaseRegular = [
            SELECT Id
            FROM recordtype
            WHERE DeveloperName = 'General'
            LIMIT 1
        ];
        
        case caso = build.aCase().forAccount(pacienteTest1).build();
        caso.RecordTypeId = RTCaseRegular[0].Id;
        caso.type = 'Gestión';
        caso.Subtipo__c = 'Profesionales de la salud';
        caso.Motivo__c = 'Becas';
        insert caso;
        
        Task tarea = build.aTaskVisita().build();
        tarea.RecordTypeId = RTTaskVisita[0].Id;
        insert tarea;
        
        tarea.WhatId = caso.id;
        
        string error;
        Test.startTest();
        try {
            update tarea;
        } catch (Exception e) {
            error = e.getMessage();
        }
        Test.stopTest();
        
        System.assert(error.contains('Solo se puede usar el Tipo de Registro de Tarea Visita para Casos de Motivo Visita'));
        
    }
    @isTest 
    static void InsertTaskOfCaseMotivoVisita_InsertTask(){
        List<recordtype> RTTaskVisita = [
            SELECT Id
            FROM recordtype
            WHERE DeveloperName = 'Visita'
            LIMIT 1
        ];
        List<recordtype> RTCaseRegular = [
            SELECT Id
            FROM recordtype
            WHERE DeveloperName = 'General'
            LIMIT 1
        ];
        
        case caso = build.aCase().forAccount(pacienteTest1).build();
        caso.RecordTypeId = RTCaseRegular[0].Id;
        caso.type = 'Gestión';
        caso.Subtipo__c = 'Profesionales de la salud';
        caso.Motivo__c = 'Visita';
        insert caso;
        
        Task tarea = build.aTaskVisita().withWhatId(caso).build();
        tarea.RecordTypeId = RTTaskVisita[0].Id;
        
        Test.startTest();
        insert tarea;
        Test.stopTest();
        
        list<task> tareas = [SELECT id, whatId FROM task WHERE id =: tarea.id];
        
        System.assertEquals(1, tareas.size());
        System.assertEquals(caso.id, tarea.whatId);
        
    }
    @isTest 
    static void InsertTaskOfCaseMotivoVisita_UpdateTask(){
        List<recordtype> RTTaskVisita = [
            SELECT Id
            FROM recordtype
            WHERE DeveloperName = 'Visita'
            LIMIT 1
        ];
        List<recordtype> RTCaseRegular = [
            SELECT Id
            FROM recordtype
            WHERE DeveloperName = 'General'
            LIMIT 1
        ];
        
        case caso = build.aCase().forAccount(pacienteTest1).build();
        caso.RecordTypeId = RTCaseRegular[0].Id;
        caso.type = 'Gestión';
        caso.Subtipo__c = 'Profesionales de la salud';
        caso.Motivo__c = 'Visita';
        insert caso;
        
        Task tarea = build.aTaskVisita().build();
        tarea.RecordTypeId = RTtaskVisita[0].Id;
        insert tarea;
        
        tarea.WhatId = caso.id;
        
        Test.startTest();
        update tarea;
        Test.stopTest();
        
        list<task> tareas = [SELECT id, whatId FROM task WHERE id =: tarea.id];
        
        System.assertEquals(1, tareas.size());
        System.assertEquals(caso.id, tarea.whatId);
    }
    @isTest
    static void InsertTaskOfCase_UpdatetaksfieldAccount(){
        List<recordtype> RTTaskVisita = [
            SELECT Id
            FROM recordtype
            WHERE DeveloperName = 'Visita'
            LIMIT 1
        ];
        List<recordtype> RTCaseRegular = [
            SELECT Id
            FROM recordtype
            WHERE DeveloperName = 'General'
            LIMIT 1
        ];
        
        
        case caso = build.aCase().forAccount(pacienteTest1).build();
        caso.RecordTypeId = RTCaseRegular[0].Id;
        caso.type = 'Gestión';
        caso.Subtipo__c = 'Profesionales de la salud';
        caso.Motivo__c = 'Visita';
        insert caso;
        
        Task tarea = build.aTaskVisita().build();
        tarea.RecordTypeId = RTtaskVisita[0].Id;
        insert tarea;
        
        tarea.WhatId = caso.id;
        
        Test.startTest();
        update tarea;
        Test.stopTest();
        
        tarea = [SELECT id, Paciente__c FROM task WHERE id =: tarea.id];
        
        System.assertEquals(pacienteTest1.id, tarea.Paciente__c);
    }
    
    @IsTest
    static void verifyFieldFechaUltimaActividad_AccountWithFirstTask(){
        
        Account cuentaTest = Build.anAccountPacienteBestCare()
            .withLastName('Paciente')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En Seguimiento')
            .withSubestadoDePaciente('Tramite iniciado')
            .build();
        insert cuentaTest;
        
        Task tareaTest1 = Build.aTask()
            .withWhatId(cuentaTest.Id)
            .build();
        
        Test.startTest();
        insert tareaTest1;		
        Test.stopTest();
        
        List<Account> accList = [
            SELECT Id, Fecha_de_ultima_actividad__c
            FROM Account
            WHERE Id =: cuentaTest.Id
        ];
        
        system.assertEquals(accList[0].Fecha_de_ultima_actividad__c, tareaTest1.CreatedDate);
        
    }
    
    @IsTest
    static void verifyFieldFechaUltimaActividad_DistintasFechasdeTarea(){
        
        Account cuentaTest = Build.anAccountPacienteBestCare()
            .withLastName('Paciente')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En Seguimiento')
            .withSubestadoDePaciente('Tramite iniciado')
            .build();
        insert cuentaTest;
        
        Task tareaTest1 = Build.aTask()
            .withWhatId(cuentaTest.Id)
            .build();
        insert tareaTest1;
        Test.setCreatedDate(tareaTest1.Id, DateTime.newInstance(2020,1,30));
        
        Task tareaTest2 = Build.aTask()
            .withWhatId(cuentaTest.Id)
            .build();
        
        Test.startTest();
        insert tareaTest2;
        Test.stopTest();
        
        List<Account> accList = [
            SELECT Id, Fecha_de_ultima_actividad__c
            FROM Account
            WHERE Id =: cuentaTest.Id
        ];
        
        system.assertEquals(accList[0].Fecha_de_ultima_actividad__c, tareaTest2.CreatedDate);
        
    }
    
    @IsTest
    static void verifyFieldFechaUltimaActividad_AfterUpdateATask_TheLastCreatedDateContinues(){
        
        Account cuentaTest = Build.anAccountPacienteBestCare()
            .withLastName('Paciente')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En Seguimiento')
            .withSubestadoDePaciente('Tramite iniciado')
            .build();
        insert cuentaTest;
        
        Task tareaTest1 = Build.aTask()
            .withWhatId(cuentaTest)
            .build();
        insert tareaTest1;
        Test.setCreatedDate(tareaTest1.Id, DateTime.newInstance(2020,1,30));
        
        Task tareaTest2 = Build.aTask()
            .withWhatId(cuentaTest)
            .build();
        insert tareaTest2;
        
        tareaTest1.Status='Trabajando';
        
        Test.startTest();
        update tareaTest1;
        Test.stopTest();
        
        List<Account> accList = [
            SELECT Id, Fecha_de_ultima_actividad__c
            FROM Account
            WHERE Id =: cuentaTest.Id
        ];
        
        system.assertEquals(accList[0].Fecha_de_ultima_actividad__c, tareaTest2.CreatedDate);
        
    }
    
    @IsTest
    static void verifyFieldFechaUltimaActividad_FirstTaskToModuloDePaciente(){
        
        Account cuentaTest = Build.anAccountPacienteBestCare()
            .withLastName('Paciente')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En Seguimiento')
            .withSubestadoDePaciente('Tramite iniciado')
            .build();
        insert cuentaTest;
        
        Modulo_de_paciente__c ModuloTest = Build.aModulodepaciente()
            .withCuenta(cuentaTest)
            .build();
        insert ModuloTest;
        
        Task tareaTest1 = Build.aTask()
            .withWhatId(ModuloTest)
            .build();
        
        Test.startTest();
        insert tareaTest1;
        Test.stopTest();
        
        List<Account> accList = [
            SELECT Id, Fecha_de_ultima_actividad__c
            FROM Account
            WHERE Modulo_activo__c =: ModuloTest.Id
        ];
        
        system.assertEquals(accList[0].Fecha_de_ultima_actividad__c, tareaTest1.CreatedDate);
        
    }
    
    @IsTest
    static void verifyFieldFechaUltimaActividad_DistintasFechasdeTareaDeModuloDePaciente(){
        
        Account cuentaTest = Build.anAccountPacienteBestCare()
            .withLastName('Paciente')
            .withAreaTerapeutica('Alergia')
            .withEstadoDePaciente('En Seguimiento')
            .withSubestadoDePaciente('Tramite iniciado')
            .build();
        insert cuentaTest;
        
        Modulo_de_paciente__c ModuloTest = Build.aModulodepaciente()
            .withCuenta(cuentaTest)
            .build();
        insert ModuloTest;
        
        Task tareaTest1 = Build.aTask()
            .withWhatId(ModuloTest)
            .build();
        insert tareaTest1;
        Test.setCreatedDate(tareaTest1.Id, DateTime.newInstance(2020,1,30));
        
        Task tareaTest2 = Build.aTask()
            .withWhatId(ModuloTest)
            .build();
        
        Test.startTest();
        insert tareaTest2;
        Test.stopTest();
        
        List<Account> accList = [
            SELECT Id, Fecha_de_ultima_actividad__c
            FROM Account
            WHERE Id =: cuentaTest.Id
        ];
        
        system.assertEquals(accList[0].Fecha_de_ultima_actividad__c, tareaTest2.CreatedDate);
        
    }

    @IsTest
    static void testSiHayUnCampoInvalidoSeDebeCorregir() {

        String campoDireccionInvalido = '  Fálsa  123  0 0 ';
        String campoReferenciaInvalido = ' "rejas" negras,  Árbol en  frente, áé  ';
        String campoTelefonoInvalido = ' 11   1234 5678 ';
        String campoNombreSAPInvalido = '112 "Ñómbré"  Ápúñllidó ';
        String campoCaracteresEspecialesInvalido = 'Ho¡%l#a|';

        Test.startTest();
            String campoDireccionValido = TareaTriggerHelper.eliminarCaracteresInvalidos(campoDireccionInvalido);
            String campoReferenciaValido = TareaTriggerHelper.eliminarCaracteresInvalidos(campoReferenciaInvalido);
            String campoTelefonoValido = TareaTriggerHelper.eliminarCaracteresInvalidos(campoTelefonoInvalido);
            String campoNombreSAPValido = TareaTriggerHelper.eliminarCaracteresInvalidos(campoNombreSAPInvalido);
            String campoCaracteresEspecialesValido = TareaTriggerHelper.eliminarCaracteresInvalidos(campoCaracteresEspecialesInvalido);
        Test.stopTest();

        System.assertEquals('Falsa 123 0 0', campoDireccionValido,
            'El campo inválido de dirección no se corrigió');
        System.assertEquals('rejas negras, Arbol en frente, ae', campoReferenciaValido,
            'El campo inválido de referencia no se corrigió');
        System.assertEquals('11 1234 5678', campoTelefonoValido,
            'El campo inválido de teléfono no se corrigió');
        System.assertEquals('112 Nombre Apunllido', campoNombreSAPValido,
            'El campo inválido de nombreSAP no se corrigió');
        System.assertEquals('Hola', campoCaracteresEspecialesValido,
            'El campo inválido de caracteres especiales no se corrigió');

    }
 
    @IsTest
    static void testSiCompletoUnaTareaDeAltaPacienteViaWebSeDebeDejarLaCuentaListaParaJitterbit() {

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nómbre')
            .withLastName('Ápellido')
            .withEmail('nombreapellido@testdanone.com')
            .withDireccion(' Calle   Falsa   123  0  0  ')
            .withReferencia('Réjas ñegrás')
            .withPhone(' 11  123456789 ')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        paciente.DNI__c = '12345678';
                
        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Unidades_de_Kit__c = 1;
        producto.Organizacion__c = 'AMN';
        insert producto;

        Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNE');

        List<Task> tareaPSP = [
            SELECT  Id, Status
            FROM    Task
            WHERE   WhatId =: idPaciente
        ];

        tareaPSP.get(0).Status = 'Completa';
    
        Test.startTest();
            update tareaPSP;
        Test.stopTest();

        Account pacienteDB = [
            SELECT  Id, Listo_para_Jitterbit__c, Phone, Referencia__c, Direccion__c, Name
            FROM    Account
            WHERE   Id =: idPaciente
        ];

        List<Task> tareaCuentaSAP = [
            SELECT  Id, Status, Subject
            FROM    Task
            WHERE   WhatId =: idPaciente
                AND Subject =: 'Cargar Paciente Regular / Best Care en SAP'
        ];

        System.assertEquals(true, pacienteDB.Listo_para_Jitterbit__c,
            'Luego de completar la tarea de Alta Paciente Via Web la cuenta no quedo listo para jitterbit');
        System.assertEquals('CALLE FALSA 123 0 0', pacienteDB.Direccion__c,
            'Luego de completar la tarea de Alta Paciente Via Web la cuenta no actualizo la direccion');
        System.assertEquals('REJAS NEGRAS', pacienteDB.Referencia__c,
            'Luego de completar la tarea de Alta Paciente Via Web la cuenta no actualizo la referencia');
        System.assertEquals('11 123456789', pacienteDB.Phone,
            'Luego de completar la tarea de Alta Paciente Via Web la cuenta no actualizo el telefono');
        System.assertEquals('Nombre Apellido', pacienteDB.Name,
            'Luego de completar la tarea de Alta Paciente Via Web la cuenta no actualizo el nombre');
        System.assertEquals(1, tareaCuentaSAP.size(),
            'No se generó la tarea de Cargar Paciente Regular / Best Care en SAP para el paciente');

    }

    @IsTest
    public static void testSiCierroUnaTareaDeAltaPacienteYTareaDeSAPElKitDebePasarAReservado() {

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nómbre')
            .withLastName('Ápellido')
            .withEmail('nombreapellido@testdanone.com')
            .withDireccion(' Calle   Falsa   123  0  0  ')
            .withReferencia('Réjas ñegrás')
            .withPhone(' 11  123456789 ')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        paciente.DNI__c = '12345678';
                
        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Unidades_de_Kit__c = 1;
        producto.Organizacion__c = 'AMN';
        insert producto;

        Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNE');

        List<Task> tareaPSP = [
            SELECT  Id, Status, WhatId
            FROM    Task
            WHERE   WhatId =: idPaciente
        ];

        paciente.N_SHIP_TO__c = '1237479';
        update paciente;

        tareaPSP.get(0).Status = 'Completa';
        update tareaPSP;

        List<Task> tareaCuentaSAP = [
            SELECT  Id, Status, Subject
            FROM    Task
            WHERE   WhatId =: idPaciente
                AND Subject =: 'Cargar Paciente Regular / Best Care en SAP'
        ];
        tareaCuentaSAP.get(0).Status = 'Completa';
        
        Test.startTest();
            update tareaCuentaSAP;
        Test.stopTest();

        List<Envio_sin_Cargo__c> kits = [
            SELECT  Id, Estado_del_envio__c, Xml_ya_generado__c, Fecha_de_despacho__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];
        
        System.assertEquals(1, kits.size(),
            'No se encontró el kit esperado');
        System.assertEquals('Reservado', kits.get(0).Estado_del_envio__c,
            'El kit no esta en estado Reservado');
        System.assertEquals(true, kits.get(0).Xml_ya_generado__c,
            'El kit no tiene el XML generado');
        System.assertEquals(System.today(), kits.get(0).Fecha_de_despacho__c,
            'El kit no tiene la fecha de despacho correcta');

    }

    @IsTest
    public static void testSiCierroTareaDeCargaDePacienteRegularEnSAPConPacienteCargadoAManoSeDebeCerrarSinChequearLosKits() {

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nómbre')
            .withLastName('Ápellido')
            .withEmail('nombreapellido@testdanone.com')
            .withDireccion(' Calle   Falsa   123  0  0  ')
            .withReferencia('Réjas ñegrás')
            .withPhone(' 11  123456789 ')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        paciente.DNI__c = '12345678';
        insert paciente;

        paciente.Listo_para_Jitterbit__c = true;
        paciente.N_SHIP_TO__c = '1237479';
        update paciente;
        
        List<Task> tareasCargaPacienteSAP = [
            SELECT  Id, Status
            FROM    Task
            WHERE   Subject =: 'Cargar Paciente Regular / Best Care en SAP'
                AND WhatId =: paciente.Id
        ];
        tareasCargaPacienteSAP.get(0).Status = 'Completa';

        Test.startTest();
            update tareasCargaPacienteSAP;
        Test.stopTest();

        List<Task> tareasCargaPacienteSAPDB = [
            SELECT  Id, Status
            FROM    Task
            WHERE   Subject =: 'Cargar Paciente Regular / Best Care en SAP'
                AND WhatId =: paciente.Id
        ];

        List<Envio_sin_Cargo__c> kits = [
            SELECT  Id
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: paciente.Id
        ];

        System.assertEquals('Completa', tareasCargaPacienteSAPDB.get(0).Status,
            'La tarea de carga de Paciente en SAP no se completó');
        System.assertEquals(0, kits.size(),
            'Se encontró un kit para el paciente');

    }

    @IsTest
    public static void testSiCierroTareaAltaPacienteViaWebBestCareSeDebeGenerarTareaCargaPacienteSAP() {
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nómbre')
            .withLastName('Ápellido')
            .withEmail('nombreapellido@testdanone.com')
            .withDireccion(' Calle   Falsa   123  0  0  ')
            .withReferencia('Réjas ñegrás')
            .withPhone(' 11  123456789 ')
            .build();
        paciente.DNI__c = '12345678';

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Area_Terapeutica__c = 'Alergia';
        producto.Unidades_de_Kit__c = 1;
        producto.Organizacion__c = 'AMN';
        insert producto;

        Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNE');

        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id;
        update paciente;

        List<Task> tareasAltaPacienteViaWeb = [
            SELECT  Id, Status
            FROM    Task
            WHERE   Subject =: 'Alta Paciente Via Web'
                AND WhatId =: idPaciente
        ];

        tareasAltaPacienteViaWeb.get(0).Status = 'Completa';

        Test.startTest();
            update tareasAltaPacienteViaWeb;
        Test.stopTest();

        List<Task> tareasCargaPacienteSAPDB = [
            SELECT  Id, Status
            FROM    Task
            WHERE   Subject =: 'Cargar Paciente Regular / Best Care en SAP'
                AND WhatId =: paciente.Id
        ];

        System.assertEquals('Completa', tareasAltaPacienteViaWeb.get(0).Status,
            'La tarea Alta Paciente Via Web no se completó para paciente Best Care');
        System.assertEquals(1, tareasCargaPacienteSAPDB.size(),
            'No se creo la tarea Cargar Paciente Regular / Best Care en SAP');
        System.assertEquals('Abierta', tareasCargaPacienteSAPDB.get(0).Status,
            'La tarea Cargar Paciente Regular / Best Care en SAP no está abierta');
    }

    @IsTest
    public static void testSiCierroTareaCargaPacienteSAPBestCareSeDebePasarKitAReservado() {
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nómbre')
            .withLastName('Ápellido')
            .withEmail('nombreapellido@testdanone.com')
            .withDireccion(' Calle   Falsa   123  0  0  ')
            .withReferencia('Réjas ñegrás')
            .withPhone(' 11  123456789 ')
            .build();
        paciente.DNI__c = '12345678';

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Area_Terapeutica__c = 'Alergia';
        producto.Unidades_de_Kit__c = 1;
        producto.Organizacion__c = 'AMN';
        insert producto;

        Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNE');

        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id;
        update paciente;

        List<Task> tareasAltaPacienteViaWeb = [
            SELECT  Id, Status
            FROM    Task
            WHERE   Subject =: 'Alta Paciente Via Web'
                AND WhatId =: idPaciente
        ];

        tareasAltaPacienteViaWeb.get(0).Status = 'Completa';
        update tareasAltaPacienteViaWeb;

        paciente.N_SHIP_TO__c = '1237479';
        update paciente;

        List<Task> tareasCargaPacienteSAPDB = [
            SELECT  Id, Status
            FROM    Task
            WHERE   Subject =: 'Cargar Paciente Regular / Best Care en SAP'
                AND WhatId =: idPaciente
        ];

        tareasCargaPacienteSAPDB.get(0).Status = 'Completa';

        Test.startTest();
            update tareasCargaPacienteSAPDB;
        Test.stopTest();

        List<Envio_sin_Cargo__c> kits = [
            SELECT  Id, Estado_del_envio__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];

        System.assertEquals('Completa', tareasCargaPacienteSAPDB.get(0).Status,
            'La tarea Cargar Paciente Regular / Best Care en SAP no se completó para paciente Best Care');
        System.assertEquals(1, kits.size(),
            'No se encontro el kit correspondiente al paciente Best Care');
        System.assertEquals('Reservado', kits.get(0).Estado_del_envio__c,
            'El kit no se encuentra en estado Reservado correspondiente al paciente Best Care');
        
    }

    @IsTest
    public static void testSiCierroUnaTareaDeAltaPacienteSAPHoyLaFechaDeDespachoDelKitDebeSerHoy() {

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nómbre')
            .withLastName('Ápellido')
            .withEmail('nombreapellido@testdanone.com')
            .withDireccion(' Calle   Falsa   123  0  0  ')
            .withReferencia('Réjas ñegrás')
            .withPhone(' 11  123456789 ')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        paciente.DNI__c = '12345678';
                
        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Unidades_de_Kit__c = 1;
        producto.Organizacion__c = 'AMN';
        insert producto;

        Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNE');

        List<Task> tareaPSP = [
            SELECT  Id, Status, WhatId
            FROM    Task
            WHERE   WhatId =: idPaciente
        ];
        tareaPSP.get(0).Status = 'Completa';
        update tareaPSP;

        paciente.N_SHIP_TO__c = '1237479';
        update paciente;

        List<Task> tareaCuentaSAP = [
            SELECT  Id, Status, Subject
            FROM    Task
            WHERE   WhatId =: idPaciente
                AND Subject =: 'Cargar Paciente Regular / Best Care en SAP'
        ];
        tareaCuentaSAP.get(0).Status = 'Completa';

        //Edito la fecha de despacho a ayer
        List<Envio_sin_Cargo__c> kitFechaDespacho = [
            SELECT  Id, Fecha_de_despacho__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];
        kitFechaDespacho.get(0).Fecha_de_despacho__c = System.today().addDays(-1);
        update kitFechaDespacho;

        Test.startTest();
            update tareaCuentaSAP;
        Test.stopTest();

        List<Envio_sin_Cargo__c> kits = [
            SELECT  Id, Fecha_de_despacho__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];
        
        System.assertEquals(System.today(), kits.get(0).Fecha_de_despacho__c,
            'El kit no tiene la fecha de despacho correcta');

    }
    @IsTest
    public static void siSeCierraUnaTareaDeEYNseDebePasarELKitAReservado(){
        Id recordTypeId = XappiaHelper.getRecordType('Envio_Sin_Cargo__c', 'EYN').id;

        Account testCuenta = Build.anAccountPacienteBestCare()
            .withLastName('Prueba Metab')	
            .withDNI('12365478')
            .withAreaTerapeutica('Metabólicos')
            .withEstadoDePaciente('En tratamiento')
            .withEmail('test@gmail.com')
            .build();

            insert testCuenta;

        Envio_sin_Cargo__c kitAMN = new Envio_sin_Cargo__c();
            kitAMN.recordTypeId =recordTypeId;
            kitAMN.Paciente__c = testCuenta.id;
            kitAMN.Razon_de_envio__c ='Kit de Inicio';
            kitAMN.Organizacion__c ='AMN';
            kitAMN.Autoriza_Envio__c = 'Adultos & Nicho';
            kitAMN.Estado_del_envio__c= 'Ingresado';

        insert kitAMN;

        Task tarea = Build.aTaskTarea()
        .withWhatId(testCuenta.Id)
        .build();
        tarea.Subject = Label.EYN_asunto;
        tarea.Status = 'Abierta';

        insert tarea;

        Test.startTest();
        tarea.Status = 'Completa';
        update tarea;

        Test.stopTest();    
        System.debug(tarea.WhatId);
        List<Envio_sin_Cargo__c> kitsDB = [
            SELECT  Id, Estado_del_envio__c
            FROM    Envio_sin_Cargo__c
            WHERE   id =: kitAMN.id
        ];

        System.assertEquals('Reservado', kitsDB[0].Estado_del_envio__c);
    }

    @IsTest
    static void testSiRechazoUnaTareaDeAltaPacienteViaWebSeDebePasarElKitDeInicioARechazado() {

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nómbre')
            .withLastName('Ápellido')
            .withEmail('nombreapellido@testdanone.com')
            .withDireccion(' Calle   Falsa   123  0  0  ')
            .withReferencia('Réjas ñegrás')
            .withPhone(' 11  123456789 ')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        paciente.DNI__c = '12345678';
                
        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Unidades_de_Kit__c = 1;
        producto.Organizacion__c = 'AMN';
        insert producto;

        Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNE');

        List<Task> tareaPSP = [
            SELECT  Id, Status, WhatId
            FROM    Task
            WHERE   WhatId =: idPaciente
        ];

        tareaPSP.get(0).Status = 'Rechazada';

        Test.startTest();
            update tareaPSP;
        Test.stopTest();

        List<Envio_sin_Cargo__c> kits = [
            SELECT  Id, Estado_del_envio__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];

        List<Case> casoDB = [
            SELECT  Id, Status
            FROM    Case
        ];
        
        System.assertEquals(1, kits.size(),
            'No se encontró el kit esperado');
        System.assertEquals('Rechazado', kits.get(0).Estado_del_envio__c,
            'El kit no esta en estado Rechazado luego de rechazar la tarea de Alta de paciente Via Web');
        System.assertEquals('Cerrado', casoDB.get(0).Status,
            'El caso del kit no esta en estado Cerrado luego de rechazar la tarea de Alta de paciente Via Web');

    }

    @IsTest
    public static void siSeRechazaUnaTareaDeEYNseDebePasarELKitARechazado(){
        Id recordTypeId = XappiaHelper.getRecordType('Envio_Sin_Cargo__c', 'EYN').id;

        Account testCuenta = Build.anAccountPacienteBestCare()
            .withLastName('Prueba Metab')	
            .withDNI('12365478')
            .withAreaTerapeutica('Metabólicos')
            .withEstadoDePaciente('En tratamiento')
            .withEmail('test@gmail.com')
            .build();

            insert testCuenta;

        Envio_sin_Cargo__c kitAMN = new Envio_sin_Cargo__c();
            kitAMN.recordTypeId =recordTypeId;
            kitAMN.Paciente__c = testCuenta.id;
            kitAMN.Razon_de_envio__c ='Kit de Inicio';
            kitAMN.Organizacion__c ='AMN';
            kitAMN.Autoriza_Envio__c = 'Adultos & Nicho';
            kitAMN.Estado_del_envio__c= 'Ingresado';

        insert kitAMN;

        Task tarea = Build.aTaskTarea()
        .withWhatId(testCuenta.Id)
        .build();
        tarea.Subject = Label.EYN_asunto;
        tarea.Status = 'Abierta';

        insert tarea;

        Test.startTest();
        tarea.Status = 'Rechazada';
        update tarea;

        Test.stopTest();    
        System.debug(tarea.WhatId);
        List<Envio_sin_Cargo__c> kitsDB = [
            SELECT  Id, Estado_del_envio__c
            FROM    Envio_sin_Cargo__c
            WHERE   id =: kitAMN.id
        ];

        System.assertEquals('Rechazado', kitsDB[0].Estado_del_envio__c);
    }

    @IsTest
    public static void testSiCierroUnaTareaDeCargaPacienteEnSAPSinShipToNoSeDebeCerrar() {

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nómbre')
            .withLastName('Ápellido')
            .withEmail('nombreapellido@testdanone.com')
            .withDireccion(' Calle   Falsa   123  0  0  ')
            .withReferencia('Réjas ñegrás')
            .withPhone(' 11  123456789 ')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        paciente.DNI__c = '12345678';
                
        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Unidades_de_Kit__c = 1;
        producto.Organizacion__c = 'AMN';
        insert producto;

        Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNE');

        List<Task> tareaPSP = [
            SELECT  Id, Status, WhatId
            FROM    Task
            WHERE   WhatId =: idPaciente
        ];

        tareaPSP.get(0).Status = 'Completa';
        update tareaPSP;
        
        try {
            List<Task> tareaCuentaSAP = [
                SELECT  Id, Status, Subject
                FROM    Task
                WHERE   WhatId =: idPaciente
                    AND Subject =: 'Cargar Paciente Regular / Best Care en SAP'
            ];
            tareaCuentaSAP.get(0).Status = 'Completa';
        
            update tareaCuentaSAP;    
        }
        catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('No se puede cerrar la tarea porque el paciente no tiene Ship To') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
    }
}