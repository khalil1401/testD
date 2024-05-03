@isTest
public class GenerateCsvForPaciente_Test {
    
    @isTest
    static void siSeGeneraUnCsvConNSHIPTOCompletoSeActualizaLaCuenta(){
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Name Tes1t')
            .build();
        accObraSocial.SalesOffice_ObraSocial__c = '01234566';
        
        insert accObraSocial;
        
        Account accTest = Build.anAccountPacienteBestCare()
            .withLastName('Name Test')
            .withRegimenDeInternacionDomiciliaria('Sí')
            .withEmpresadeinternaciondomiciliaria('Best care')		
            .withDNI('12346789')
            .withCanalParaConsumidorBaby('Farmacias')
            .withReferencia('test referencia')
            .withDireccion('Test direccion')
            .withPhone('123456')
            .withShipTo('456789')
            .build();
        accTest.Obra_social__pc = accObraSocial.id;
        
        insert accTest;
        
        PageReference pageRef = Page.GenerarteCsvForPaciente;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(accTest.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(accTest);
        
        Test.startTest();
        GenerateCsvForPacienteController gCsv = new GenerateCsvForPacienteController(sc);
        gCsv.generateCsv();
        Test.stopTest();
        
        
        Account accDb = [
            SELECT id,Listo_para_Jitterbit__c 
            FROM Account 
            WHERE id =:accTest.Id 
            LIMIT 1
        ];
        
        System.assertEquals(true, accDb.Listo_para_Jitterbit__c);
    }
    @isTest
    static void siSeGeneraUnCsvConAlguncaracterIncorrectoDebeLanzarUnError(){
        
        Account accTest = Build.anAccountPacienteBestCare()
            .withLastName('Name Test')
            .withRegimenDeInternacionDomiciliaria('Sí')
            .withEmpresadeinternaciondomiciliaria('Best care')		
            .withDNI('12346789')
            .withCanalParaConsumidorBaby('Farmacias')
            .withReferencia('test  referencia')// doble espacio en la referencia
            .withDireccion('Test direccion') 
            .withPhone('123456')
            .withShipTo('456789')
            .build();
        
        insert accTest;
        
        PageReference pageRef = Page.GenerarteCsvForPaciente;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(accTest.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(accTest);
        
        Test.startTest();
        
        GenerateCsvForPacienteController gCsv = new GenerateCsvForPacienteController(sc);
        gCsv.generateCsv();
        boolean validatedChar = !gCsv.telephoneChar && !gCsv.referenciaChar && !gCsv.direccionChar;
        
        Test.stopTest();
        
        
        Account accDb = [
            SELECT id,Listo_para_Jitterbit__c 
            FROM Account 
            WHERE id =:accTest.Id 
            LIMIT 1
        ];
        
        System.assertEquals(false, validatedChar);
        System.assertEquals(false, accDb.Listo_para_Jitterbit__c);
    }
    
    @isTest
    static void siSeGeneraUnCsvYfaltanLosCamposDeObraSocialYLaCuentaEsBestCareDebeLanzarUnError(){
        
        Account accTest2 = Build.anAccountPacienteBestCare()
            .withLastName('Name Test')
            .withRegimenDeInternacionDomiciliaria('Sí')
            .withEmpresadeinternaciondomiciliaria('Best care')		
            .withDNI('12346789')
            .withCanalParaConsumidorBaby('Farmacias')
            .withReferencia('test referencia')
            .withDireccion('Test direccion') 
            .withPhone('123456')
            .withShipTo('456789')
            .build();
        
        insert accTest2;
        
        PageReference pageRef = Page.GenerarteCsvForPaciente;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(accTest2.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(accTest2);
        
        Test.startTest();
        
        GenerateCsvForPacienteController gCsv = new GenerateCsvForPacienteController(sc);
        gCsv.generateCsv();
        
        Test.stopTest();
        
        Account accDb = [
            SELECT id,Listo_para_Jitterbit__c,Obra_social__pc
            FROM Account 
            WHERE id =:accTest2.Id 
            LIMIT 1
        ];
        
        System.assertEquals(false, accDb.Listo_para_Jitterbit__c);
    }
    
    
    @isTest
    static void siSeQuiereGenerarUnCsvQueYaSeGeneroDebeLanzarUnErrorIndicandoElTiempoQueFaltaParaQueVuelvaAEstarDisponible(){
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Name Tes1t')
            .build();
        accObraSocial.SalesOffice_ObraSocial__c = '01234566';
        accObraSocial.SalesGroup__c = '4567';
        insert accObraSocial;
        
        Account accTest2 = Build.anAccountPacienteBestCare()
            .withLastName('Name Test')
            .withRegimenDeInternacionDomiciliaria('Sí')
            .withEmpresadeinternaciondomiciliaria('Best care')		
            .withDNI('12346789')
            .withCanalParaConsumidorBaby('Farmacias')
            .withReferencia('test referencia')
            .withDireccion('Test direccion') 
            .withPhone('123456')
            .withShipTo('456789')
            .build();
        accTest2.Obra_social__pc = accObraSocial.id;
        
        insert accTest2;
        
        PageReference pageRef = Page.GenerarteCsvForPaciente;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(accTest2.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(accTest2);
        
        Test.startTest();
        
        GenerateCsvForPacienteController gCsv = new GenerateCsvForPacienteController(sc);
        gCsv.generateCsv();
        
        Test.stopTest();
        
        Account accDb = [
            SELECT id,Listo_para_Jitterbit__c,Obra_social__pc,Horario_de_ultimo_CSV__c
            FROM Account 
            WHERE id =:accTest2.Id 
            LIMIT 1
        ];
        
        System.assertNotEquals(null, accDb.Horario_de_ultimo_CSV__c);
        
        gCsv.generateCsv();
        
        System.assertEquals(40, gCsv.timeRemaining);
    }
    
    @isTest
    static void siSeQuiereGenerarUnCsvQueYaSeGeneroYJitterBitNoActualizoDebeLanzarOtroError(){
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('Name Tes1t')
            .build();
        accObraSocial.SalesOffice_ObraSocial__c = '01234566';
        accObraSocial.SalesGroup__c = '4567';
        insert accObraSocial;
        
        Account accTest2 = Build.anAccountPacienteBestCare()
            .withLastName('Name Test')
            .withRegimenDeInternacionDomiciliaria('Sí')
            .withEmpresadeinternaciondomiciliaria('Best care')		
            .withDNI('12346789')
            .withCanalParaConsumidorBaby('Farmacias')
            .withReferencia('test referencia')
            .withDireccion('Test direccion') 
            .withPhone('123456')
            .withShipTo('456789')
            .build();
        accTest2.Obra_social__pc = accObraSocial.id;
        
        insert accTest2;
        
        PageReference pageRef = Page.GenerarteCsvForPaciente;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(accTest2.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(accTest2);
        
        Test.startTest();
        
        GenerateCsvForPacienteController gCsv = new GenerateCsvForPacienteController(sc);
        gCsv.generateCsv();
        Test.stopTest();
        
        Account accDb = [
            SELECT id,Listo_para_Jitterbit__c,Obra_social__pc,Horario_de_ultimo_CSV__c
            FROM Account 
            WHERE id =:accTest2.Id 
            LIMIT 1
        ]; 
        Long lastCsvTime = System.now().addHours(-2).getTime();
        gCsv.acc.Horario_de_ultimo_CSV__c = lastCsvTime;
        gCsv.generateCsv();
        System.assertNotEquals(null, accDb.Horario_de_ultimo_CSV__c);
        System.assertEquals(true,gCsv.addError);
    }
}