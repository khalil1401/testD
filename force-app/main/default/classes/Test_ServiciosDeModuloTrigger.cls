@IsTest
public class Test_ServiciosDeModuloTrigger {
    public static Tratamiento__c Tratamiento;
    public static Modulo_de_paciente__c testModulo;
    public static Profile psp = [
        SELECT Id 
        FROM Profile 
        WHERE Name
        LIKE '%PSP%'
        LIMIT 1
    ]; 

    public static User userPSP = new User(Alias = 'psptest', Email='psptest@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='psptest', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = psp.Id, Title='Kinesiologo',
        TimeZoneSidKey='America/Los_Angeles', UserName='psptest@testorg.com');

    public static User userPSPNutricion = new User(Alias = 'psptest', Email='Nutritest@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='pspNutri', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = psp.Id, Title='Nutricionista',
        TimeZoneSidKey='America/Los_Angeles', UserName='Nutritest@testorg.com');

    public static Account testCuenta = Build.anAccountPacienteBestCare()
        .withLastName('Name Test')
        .withRegimenDeInternacionDomiciliaria('Sí')
        .withEmpresadeinternaciondomiciliaria('Best care')		
        .withDNI('123467894')
        .withCanalParaConsumidorBaby('Farmacias')
        .build();

    public static Account accObraSocial = Build.anAccountObrasocial()
        .withName('Name Test3')
        .withDNI('1234678911')           
        .withCanalParaConsumidorBaby('Farmacias')
        .build();
   
    static{
        insert userPSP;
        insert userPSPNutricion;
        testCuenta.Kinesiologo_asignado__c = userPSP.id;
        testCuenta.Nutricionista_Asignado__c = userPSPNutricion.id;
        insert testCuenta;
        insert accObraSocial;
        Tratamiento = Build.aTratamientoTratamientoBestCare()
            .withObraSocial(accObraSocial)
            .withAccount(testCuenta)
            .build();
        testModulo = Build.aModulodepaciente()
            .withCuenta(testCuenta)
            .withObrasocialTratamiento(tratamiento.id)
            .Build();
        insert tratamiento;  
        insert testModulo;
    }
    
    @IsTest
    static void siSeInsertaUnNuevoServicioDeModuloSeDebeCompletarElCampoModuloTipoDeServicioDelObjetoModuloDePaciente() {
        
        Servicios_del_Modulo__c testServicio0 = Build.aServicio()
            .withModuloDePaciente(testModulo.id)
            .withServiciosDisponible('Rehabilitacion_Motora_Intermedio')
            .Build();
        
            
        Test.startTest();
            insert testServicio0;
            
        Test.stopTest();
        
        Modulo_de_paciente__c mdpDb = [
            SELECT Modulo_tipo_de_servicio__c,Tipo__c
            FROM Modulo_de_paciente__c
            WHERE id= :testModulo.id
            
        ];
        /*List<Task> tareas = [
            SELECT id, ownerId, Subject,WhatId, paciente__c,owner.name,ActivityDate
            FROM Task
            WHERE createdDate = today
            AND Subject LIKE : '%Visita de%'
            ORDER BY Subject ASC
        ];

        DateTime currDate = DateTime.newInstance(tareas[0].ActivityDate.year(), tareas[0].ActivityDate.month(), tareas[0].ActivityDate.day());  
        String day = currDate.format('EEEE');  

        System.assertEquals(13, tareas.size());
        System.assertEquals('Visita de Kinesiologo', tareas[0].subject);
        System.assertEquals('Visita de Nutricionista', tareas[12].subject);
        System.assertEquals('Friday', day);*/
        System.assertEquals('REHABILITACION MOTORA - INTERMEDIO', mdpDb.Tipo__c);
       
    }
    
       
    @IsTest
    static void siNoSeDefineUNServicioDeModuloConValorNingunoSeDebeCompletarElCampoModuloTipoDeServicioConAUtocuidado() {
        
        Servicios_del_Modulo__c testServicio4 = new Servicios_del_Modulo__c();
        testServicio4.Modulo_de_paciente__c = testModulo.id;

        insert testServicio4;
        
        Test.startTest();
        
        Test.stopTest();
        
        Modulo_de_paciente__c mdpDb = [
            SELECT Modulo_tipo_de_servicio__c,Tipo__c
            FROM Modulo_de_paciente__c
            WHERE id= :testModulo.id           
        ];
       // System.assertEquals('AUTOCUIDADO', mdpDb.Tipo__c);
        
    }


    @IsTest
    static void siSeInsertaUnNuevoServicioDeModuloDuplicadoSeDebeLanzarUnError() {
        
        Servicios_del_Modulo__c testServicio6 = new Servicios_del_Modulo__c();
        testServicio6.Modulo_de_paciente__c = testModulo.id;
        testServicio6.Servicios_disponibles__c = 'Rehabilitación_Motora_Plus';
        
        insert testServicio6;

        Servicios_del_Modulo__c testServicio7 = new Servicios_del_Modulo__c();
        testServicio7.Modulo_de_paciente__c = testModulo.id;
        testServicio7.Servicios_disponibles__c = 'Rehabilitacion_Motora_Intermedio';

        Boolean excepcionEsperada =false;
        try{
            insert testServicio7;
        }
        catch (Exception ex){                
            excepcionEsperada = ex.getMessage().contains('No se pueden ingresar servicios duplicados');           
        }                
        System.assertEquals(true, excepcionEsperada);
    
    }
    
    @IsTest
    static void siSeEliminaUnServicioDeModuloSeDebeCompletarElCampoModuloTipoDeServicioDelObjetoModuloDePaciente() {

        Servicios_del_Modulo__c testServicio66 = new Servicios_del_Modulo__c();
        testServicio66.Modulo_de_paciente__c = testModulo.id;
        testServicio66.Servicios_disponibles__c = 'Servicio visita nutricional';

        Servicios_del_Modulo__c testServicio8 = new Servicios_del_Modulo__c();
        testServicio8.Modulo_de_paciente__c = testModulo.id;
        testServicio8.Servicios_disponibles__c = 'Rehabilitacion_Motora_Intermedio';
        
        insert  new List<Servicios_del_Modulo__c> {testServicio66, testServicio8};

        Test.startTest();
        
        delete testServicio8;
        
        Test.stopTest();
        
        Modulo_de_paciente__c mdpDb = [
            SELECT Modulo_tipo_de_servicio__c,Tipo__c
            FROM Modulo_de_paciente__c
            WHERE id= :testModulo.id           
        ];

        System.assertEquals('CUIDADO PERSONALIZADO', mdpDb.Tipo__c);
        
    }
    

   /* @IsTest
    static void siSeInsertanServiciosSeDebenGenerarSusTresTareasCorrespondientes() {

        Servicios_del_Modulo__c testServicio14 = new Servicios_del_Modulo__c();
        testServicio14.Modulo_de_paciente__c = testModulo.id;
        testServicio14.Servicios_disponibles__c = 'Rehabilitación_Motora_Plus';
        insert testServicio14;

        Servicios_del_Modulo__c testServicio15 = new Servicios_del_Modulo__c();
        testServicio15.Modulo_de_paciente__c = testModulo.id;
        testServicio15.Servicios_disponibles__c = 'Servicio visita enfermería';
        insert testServicio15;

        Servicios_del_Modulo__c testServicio16 = new Servicios_del_Modulo__c();
        testServicio16.Modulo_de_paciente__c = testModulo.id;
        testServicio16.Servicios_disponibles__c = 'Servicio visita nutricional';
        testServicio16.Cantidad__c = 3;
        
        insert testServicio16;

        Modulo_de_paciente__c mdpDb = [
            SELECT Modulo_tipo_de_servicio__c,Tipo__c
            FROM Modulo_de_paciente__c
            WHERE id= :testModulo.id  
        ];
        List<Task> tareas = [
            SELECT id, ownerId, Subject,WhatId, paciente__c,owner.name
            FROM Task
            WHERE createdDate = today
            AND Subject LIKE : '%Visita de%'
            ORDER BY Subject ASC
        ];

        System.assertEquals(20, tareas.size());
        System.assertEquals('Visita de Enfermero', tareas[0].Subject);
        System.assertEquals( 'REHABILITACIÓN MOTORA PLUS', mdpDb.Tipo__c);      
    }    */
    @IsTest
    static void siSeEliminaElunicoServicioSeDebeCompletarElCampoModuloTipoDeServicioConAutocuidado() {
        
        Servicios_del_Modulo__c testServicio17 = new Servicios_del_Modulo__c();
        testServicio17.Modulo_de_paciente__c = testModulo.id;
        testServicio17.Servicios_disponibles__c = 'Servicio visita medica';

        insert testServicio17;
        
        Test.startTest();
        delete testServicio17;
        Test.stopTest();
        
        Modulo_de_paciente__c mdpDb = [
            SELECT Modulo_tipo_de_servicio__c,Tipo__c
            FROM Modulo_de_paciente__c
            WHERE id= :testModulo.id          
        ];
       /* List<Task> tareas = [
            SELECT id, ownerId, Subject,WhatId, paciente__c
            FROM Task
            WHERE createdDate = today
            AND Subject LIKE : '%Visita de%'
        ];

        System.assertEquals(1, tareas.size());
        System.assertEquals('AUTOCUIDADO', mdpDb.Tipo__c);   */
    }
}