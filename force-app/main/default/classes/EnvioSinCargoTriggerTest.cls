@IsTest
public class EnvioSinCargoTriggerTest {

    @IsTest
    public static void testSiPasoElKitDeInicioDePortalAReservadoSeDebeCrearUsuarioParaElPaciente() {

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
        producto.Area_Terapeutica__c = 'Oncología';
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

        Test.startTest();
            update tareaCuentaSAP;
        Test.stopTest();

        List<Account> pacientesDB = [
            SELECT  Id, PersonContactId
            FROM    Account
            WHERE   Id =: paciente.Id
        ];

        Profile perfilUsuarioDB = [
            SELECT  Id
            FROM    Profile
            WHERE   Name =: 'Paciente Oncología'
            LIMIT 1
        ];

        List<User> usuariosDB = [
            SELECT  Id, ProfileId, Username
            FROM    User
            WHERE   ContactId =: pacientesDB.get(0).PersonContactId
        ];

        System.assertEquals(1, usuariosDB.size(),
            'No se encontró el usuario esperado');
        System.assertEquals(perfilUsuarioDB.Id, usuariosDB.get(0).ProfileId,
            'El usuario no tiene el perfil correspondiente');
        System.assert(usuariosDB.get(0).Username.contains(paciente.DNI__c),
            'El usuario no tiene el username correspondiente');

    }

    @IsTest
    public static void testSiPasoKitDeInicioQueNoEsDelPortalAReservadoSeDebeCrearUsuarioParaElPaciente() {

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withDireccion(' Calle   Falsa   123  0  0  ')
            .withReferencia('Rejas negras')
            .withPhone(' 11  123456789 ')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        paciente.DNI__c = '12345678';
        paciente.Area_Terapeutica__c = 'Oncología';
        insert paciente;

        Envio_sin_Cargo__c kitDeInicio = new Envio_sin_Cargo__c();
        kitDeInicio.Paciente__c = paciente.Id;
        kitDeInicio.Estado_del_envio__c = 'Ingresado';
        kitDeInicio.Razon_de_envio__c = 'Kit de Inicio';
        insert kitDeInicio;

        kitDeInicio.Estado_del_envio__c = 'Reservado';

        Test.startTest();
            update kitDeInicio;
        Test.stopTest();

        List<Account> pacientesDB = [
            SELECT  Id, PersonContactId
            FROM    Account
            WHERE   Id =: paciente.Id
        ];

        Profile perfilUsuarioDB = [
            SELECT  Id
            FROM    Profile
            WHERE   Name =: 'Paciente Oncología'
            LIMIT 1
        ];

        List<User> usuariosDB = [
            SELECT  Id, ProfileId
            FROM    User
            WHERE   ContactId =: pacientesDB.get(0).PersonContactId
        ];

        System.assertEquals(1, usuariosDB.size(),
            'No se encontró el usuario esperado');
        System.assertEquals(perfilUsuarioDB.Id, usuariosDB.get(0).ProfileId,
            'El usuario no tiene el perfil correspondiente');

    }

    @IsTest
    public static void testSiPasoSegundoKitQueNoEsDelPortalAReservadoNoSeDebeCrearUsuarioParaElPaciente() {

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withDireccion(' Calle   Falsa   123  0  0  ')
            .withReferencia('Rejas negras')
            .withPhone(' 11  123456789 ')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        paciente.DNI__c = '12345678';
        paciente.Area_Terapeutica__c = 'Oncología';
        insert paciente;

        Envio_sin_Cargo__c kitDeInicio = new Envio_sin_Cargo__c();
        kitDeInicio.Paciente__c = paciente.Id;
        kitDeInicio.Estado_del_envio__c = 'Ingresado';
        kitDeInicio.Razon_de_envio__c = 'Kit de Inicio';
        insert kitDeInicio;

        kitDeInicio.Estado_del_envio__c = 'Reservado';
        update kitDeInicio;

        Envio_sin_Cargo__c segundokit = new Envio_sin_Cargo__c();
        segundokit.Paciente__c = paciente.Id;
        segundokit.Estado_del_envio__c = 'Ingresado';
        segundokit.Razon_de_envio__c = 'Kit de Inicio';
        insert segundokit;

        segundokit.Estado_del_envio__c = 'Reservado';

        Test.startTest();
            update segundokit;
        Test.stopTest();

        List<Account> pacientesDB = [
            SELECT  Id, PersonContactId
            FROM    Account
            WHERE   Id =: paciente.Id
        ];

        Profile perfilUsuarioDB = [
            SELECT  Id
            FROM    Profile
            WHERE   Name =: 'Paciente Oncología'
            LIMIT 1
        ];

        List<User> usuariosDB = [
            SELECT  Id, ProfileId
            FROM    User
            WHERE   ContactId =: pacientesDB.get(0).PersonContactId
        ];

        System.assertEquals(1, usuariosDB.size(),
            'No se encontró el usuario esperado');
        System.assertEquals(perfilUsuarioDB.Id, usuariosDB.get(0).ProfileId,
            'El usuario no tiene el perfil correspondiente');

    }

    @IsTest
    public static void testSiSePasaKitDelPortalMetabolicosAReservadoSeDebeCrearUsuarioParaElPaciente() {
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
        producto.Area_Terapeutica__c = 'Metabólicos';
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

        Test.startTest();
            update tareaCuentaSAP;
        Test.stopTest();

        List<Account> pacientesDB = [
            SELECT  Id, PersonContactId
            FROM    Account
            WHERE   Id =: paciente.Id
        ];

        List<User> usuariosDB = [
            SELECT  Id, ProfileId, Username
            FROM    User
            WHERE   ContactId =: pacientesDB.get(0).PersonContactId
        ];

        System.assertEquals(1, usuariosDB.size(),
            'No se encontró el usuario para metabolicos');
    }

    @IsTest
    public static void testSiPasoElKitDeInicioDePortalPacienteBestCareAReservadoSeDebeCrearUsuarioParaElPaciente() {
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
        producto.Area_Terapeutica__c = 'Oncología';
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
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id;
        update paciente;

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

        List<Account> pacientesDB = [
            SELECT  Id, PersonContactId
            FROM    Account
            WHERE   Id =: paciente.Id
        ];

        Profile perfilUsuarioDB = [
            SELECT  Id
            FROM    Profile
            WHERE   Name =: 'Paciente Oncología'
            LIMIT 1
        ];

        List<User> usuariosDB = [
            SELECT  Id, ProfileId, Username
            FROM    User
            WHERE   ContactId =: pacientesDB.get(0).PersonContactId
        ];

        System.assertEquals(1, usuariosDB.size(),
            'No se encontró el usuario esperado para el paciente best care');
        System.assertEquals(perfilUsuarioDB.Id, usuariosDB.get(0).ProfileId,
            'El usuario no tiene el perfil correspondiente para el paciente best care');
    }


    //comentar arriba


    @IsTest
    public static void siElEnvioPasaAProcesadoSeDebenSetearLosCamposDeTratamientoProductoYProfesional() {

        List<Envio_Sin_Cargo__c> kits = crearEscenarioMultiple();

        Test.startTest();

        for(Envio_Sin_Cargo__c aKit : kits){
           aKit.Estado_del_envio__c = 'Reservado';
        }
        update kits;
        
        Test.stopTest();
        
        List<Envio_Sin_Cargo__c> kitDb = [
            SELECT id, Formula_de_producto_de_envio__c,Centro_de_tratamiento_activo__c,Profesional_de_tratamiento_activo__c,
            Paciente__r.Obra_social__pr.Usuario_KAM_obra_social__r.Email
            FROM Envio_Sin_Cargo__c
            ORDER By createdDate desc
            ];

        System.assertEquals('Profesional prueba', kitDb[0].Profesional_de_tratamiento_activo__c);
        System.assertEquals('Segunda formula - Formula', kitDb[1].Formula_de_producto_de_envio__c);
        System.assertEquals('Institucion', kitDb[2].Centro_de_tratamiento_activo__c);
        System.assertEquals('testkam@gmail.com', kitDb[2].Paciente__r.Obra_social__pr.Usuario_KAM_obra_social__r.Email);

        
    }
    public static List<Envio_Sin_Cargo__c> crearEscenarioMultiple() {
        
        List<Account> pacientes = new List<Account>();
        List<Tratamiento__c> tratamientos = new List<Tratamiento__c>();
        List<Envio_sin_Cargo__c> kits = new List<Envio_sin_Cargo__c>();
        List<Tratamiento_de_profesional__c> profesionalesDeTratamiento = new List<Tratamiento_de_profesional__c>();
        List<Producto_de_envio__c> productosDeEnvio = new List<Producto_de_envio__c>();

        Profile profileIdTest = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'Gerente Best Care/Calidad' 
            LIMIT 1
            ];
        
        User user1 = Build.aUser()
            .withUsername('testKAMAlert@gmailK.com')
            .withEmail('testkam@gmail.com')
            .withAlias('tKAM')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('test KAM')
            .withCommunityNickname('testKAM')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profileIdTest.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        
        insert user1;

        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Prueba Obra social')			   
            .build();
        accObraSocial.Usuario_KAM_obra_social__c =user1.id;
        insert accObraSocial;
        
        Account institucion = Build.anAccountInstitucion()
            .withName('Institucion')			   
            .build();
        
        insert institucion;
        
        Account profesional = Build.anAccountProfesionaldelasalud()
            .withLastName('Profesional prueba')
            .build();
        
        insert profesional;
        
        Product2 producto = new Product2();
        producto.name = 'Formula';
        producto.Producto_SAP__c =true;

        insert producto;
        
        Product2 producto2 = new Product2();
        producto2.name = 'Segunda formula';
        producto2.Producto_SAP__c =true;

        insert producto2;
        
        Product2 producto3 = new Product2();
        producto3.name = 'Tercera formula';
        producto3.Producto_SAP__c =true;

        insert producto3;
        
        for(integer i=0; i<3 ; i++){
            
            Account paciente = Build.anAccountPacienteBestCare()
                .withLastName('Name Test ' + i)	   
                .build();
            paciente.obra_social__pc = accObraSocial.id;
            
            pacientes.add(paciente);
        }
        insert pacientes;
        
        for(Account anAccount : pacientes){
            
            Tratamiento__c Tratamiento = Build.aTratamientoTratamientoBestCare()
                .withObraSocial(accObraSocial)
                .withAccount(anAccount)
                .build();
            Tratamiento.Centro_de_tratamiento__c = institucion.id;
            Tratamiento.Area_terapeutica__c = 'Alergia';
            
            Envio_sin_Cargo__c kitDeInicio = new Envio_sin_Cargo__c();
            kitDeInicio.Paciente__c = anAccount.Id;
            kitDeInicio.Estado_del_envio__c = 'Ingresado';
            kitDeInicio.Razon_de_envio__c = 'Kit de Inicio';
            
            kits.add(kitDeInicio);
            tratamientos.add(tratamiento);
        }
        
        insert tratamientos;
        insert kits;
        
        for(Tratamiento__c atrat : tratamientos){
            
            Tratamiento_de_profesional__c profesionalTratamiento = new Tratamiento_de_profesional__c();
            profesionalTratamiento.Tratamiento__c = atrat.id;
            profesionalTratamiento.Profesional__c= profesional.id;          
            profesionalesDeTratamiento.add(profesionalTratamiento);
            
        }       
        insert profesionalesDeTratamiento;       
        integer count=0;
        for(Envio_Sin_Cargo__c aKit : kits){

            Producto_de_envio__c productoEnv = new Producto_de_envio__c();
            productoEnv.Envio_Sin_Cargo__c = aKit.id;
            
            if(count== 0){
                productoEnv.Formula__c = producto.id;
            }else if(count==1){
                productoEnv.Formula__c = producto2.id;

                Producto_de_envio__c productoEnv2 = new Producto_de_envio__c();
                productoEnv2.Envio_Sin_Cargo__c = aKit.id;
                productoEnv2.Formula__c = producto.id;
                productosDeEnvio.add(productoEnv2);

            }else{
                productoEnv.Formula__c = producto3.id;
            }
            count++;
            productosDeEnvio.add(productoEnv);
        }

        insert productosDeEnvio;
        
        return kits;
    }
    
    @IsTest
    static void testSiRechazoUnEnvioSinCargoElCasoRelacionadoSeTieneQueCerrar() {

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

        List<Envio_sin_Cargo__c> kits = [
            SELECT  Id, Estado_del_envio__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];

        kits.get(0).Estado_del_envio__c = 'Rechazado';

        Test.startTest();
            update kits;
        Test.stopTest();

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

}