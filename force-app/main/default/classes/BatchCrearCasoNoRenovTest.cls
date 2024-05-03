@isTest
private class BatchCrearCasoNoRenovTest {

    @TestSetup
    static void makeData(){
        
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
        
		User user2 = Build.aUser()
        .withUsername('testKAMAlert2@gmailK.com')
        .withEmail('testkam2@gmail.com')
        .withAlias('tKAM2')
        .withTimeZoneSidKey('GMT')
        .withLocaleSidKey('en_US')
        .withLastName('test KAM2')
        .withCommunityNickname('testKAM2')
        .withEmailEncodingKey('UTF-8')
        .withProfileId(profileIdTest.id)
        .withLanguageLocaleKey('en_US')
        .Build();
        insert user2;

        Account accObraSocial = Build.anAccountObrasocial()
        .withName('Prueba Obra social')
        .build();
        
		Account accObraSocial2 = Build.anAccountObrasocial()
        .withName('Prueba Obra social2')
        .build();
        
        accObraSocial.Usuario_KAM_obra_social__c = user1.id;
        accObraSocial2.Usuario_KAM_obra_social__c = user1.id;
        insert accObraSocial;
        insert accObraSocial2;

        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Paciente_Best_Care'];
        
		//Date fechaHace5Dias = date.newinstance(2024,3,30);
        Date fechaHace5Dias = Date.today().addDays(-5);
            
        Account cuenta = new Account(
            LastName = 'Pruebas 3',
            RecordTypeId = recordType.Id,
            DNI__c = '111111111111',
            Area_terapeutica__c = 'Dieta Cetogénica',
            Estado_de_paciente__c = 'En Seguimiento',
            Subestado_del_paciente__c = 'Modulo Inactivo',
            Phone = '111111111',
            Canal_para_Consumidor_Baby__c = 'Farmacias',
            //Dias_en_este_estado__c = 5,
            Tipo_de_Obra_Social__c = 'Prepaga',
            Obra_social__pc = accObraSocial.Id,
            Codigo_postal__c = 'B1228',
            Fecha_de_cambio_de_estado__c = fechaHace5Dias,
            Servicio_Activo_Aux__c = 'AUTOCUIDADO.'
        );
        
            Account cuenta2 = new Account(
            LastName = 'Pruebas 4',
            RecordTypeId = recordType.Id,
            DNI__c = '111111111112',
            Area_terapeutica__c = 'Dieta Cetogénica',
            Estado_de_paciente__c = 'En Seguimiento',
            Subestado_del_paciente__c = 'Modulo Inactivo',
            Phone = '111111112',
            Canal_para_Consumidor_Baby__c = 'Farmacias',
            //Dias_en_este_estado__c = 5,
            Tipo_de_Obra_Social__c = 'Prepaga',
            Obra_social__pc = accObraSocial2.Id,
            Codigo_postal__c = 'B1228',
            Fecha_de_cambio_de_estado__c = fechaHace5Dias,
            Servicio_Activo_Aux__c = 'AUTOCUIDADO.'
        );
        
        	INSERT cuenta;  
        	INSERT cuenta2;
        
        Case caso = new Case(
            Subject = 'Nuevo seguimiento no renovación',
            AccountId = cuenta2.Id
        );
            INSERT caso;
    }

    @isTest
    static void verificarQueSeCrearonLosCasos() {

        Date fechaHace5Dias = Date.today().addDays(-5);
        Account cuentaTest = [SELECT Id FROM Account Where LastName = 'Pruebas 3'];
        cuentaTest.Fecha_de_cambio_de_estado__c = fechaHace5Dias;
        update cuentaTest;

        Test.startTest();
            BatchCrearCasoNoRenovacion batch = new BatchCrearCasoNoRenovacion();
            Database.executeBatch(batch);
        Test.stopTest();
		
        List<Case> casogeneradoDeRelleno = [SELECT Id FROM Case WHERE Subject = 'Nuevo seguimiento no renovación' ORDER BY CreatedDate ASC LIMIT 1 ];
        delete casogeneradoDeRelleno;
        List<Case> casosGenerados = [SELECT Id FROM Case WHERE Subject = 'Nuevo seguimiento no renovación'];

        // System.assertEquals(expected, actual)
        System.assertEquals(1, casosGenerados.size(), 'Prueba 1');
    }
}