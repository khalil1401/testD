@isTest
public class AccountTest {
    
    @isTest
    Public static void creoCuentaTipoShipTo() {
        
        Account cuenta = Build.anAccountSucursaldeenvio()
            .withIdSucursalOracle('idTest')
            .withName('Name Test')
            .withTipoDeSucursal('SHIP_TO')
            .build();
        cuenta.Canal_para_Consumidor_Baby__c = 'Farmacias';
        test.startTest();
        insert cuenta;
        test.stopTest();
        
        Id sucursalEnvioRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal de envío').getRecordTypeId();
        
        Account nuevaCuenta = [SELECT RecordTypeId FROM Account WHERE Id = :cuenta.Id];
        
        System.assertEquals(sucursalEnvioRecTypeId, nuevaCuenta.RecordTypeId);
        
        
    }
    
    @isTest
    Public static void creoCuentaTipoBillTo() {
        
        Account cuenta = Build.anAccountSucursaldefacturacion()
            .withIdSucursalOracle('idTest')
            .withName('Name Test')
            .withTipoDeSucursal('BILL_TO')
            .build();
        cuenta.Canal_para_Consumidor_Baby__c = 'Farmacias';
        test.startTest();
        insert cuenta;
        test.stopTest();
        
        Id sucursalFactRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal de facturación').getRecordTypeId();
        
        Account nuevaCuenta = [SELECT RecordTypeId FROM Account WHERE Id = :cuenta.Id];
        
        System.assertEquals(sucursalFactRecTypeId, nuevaCuenta.RecordTypeId);
        
        
    }
    
    @isTest
    Public static void creoCuentaTipoCustomer() {
        
        Account cuenta = New Account();
        cuenta.Name = 'Prueba cuenta pedido';
        cuenta.Id_customer_oracle__c = 'aaa';
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sucursal de envío').getRecordTypeId();
        cuenta.Canal_para_Consumidor_Baby__c = 'Farmacias';
        
        test.startTest();
        
        insert cuenta;
        
        test.stopTest();
        
        Id clienteRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
        Account nuevaCuenta = [SELECT RecordTypeId FROM Account WHERE Id = :cuenta.Id];
        
        System.assertEquals(clienteRecTypeId, nuevaCuenta.RecordTypeId);
        
        
    }
    
    
    
    @isTest
    Public static void noDebeHaberDuplicadosEnLosPropietariosDeLaCUenta() {
        String status;
        Profile profileIdTest = [SELECT Id FROM Profile WHERE Name = 'Usuario de Platform estándar' LIMIT 1];
        
        User user1 = Build.aUser()
            .withUsername('test1test1@gmail.com')
            .withEmail('test1test1@gmail.com')
            .withAlias('Ts')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('test apellido')
            .withCommunityNickname('test123')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profileIdTest.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        
        insert user1;
        
        User user2 = Build.aUser()
            .withUsername('test2test2@gmail.com')
            .withEmail('test2test2@gmail.com')
            .withAlias('Ts2')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('test apellido2')
            .withCommunityNickname('test1232')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profileIdTest.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        insert user2;
        
        User user3 = Build.aUser()
            .withUsername('test3test2@gmail.com')
            .withEmail('test2te33t2@gmail.com')
            .withAlias('Ts3332')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('te3st apellido2')
            .withCommunityNickname('te3st1232')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profileIdTest.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        
        insert user3;
        
        Account testAcc1 = new Account();
        testAcc1.Name = 'cuenta 1';
        testAcc1.Canal_para_Consumidor_Baby__c = 'Farmacias';
        testAcc1.Propietario_Nicho__c = user1.id;
        testAcc1.Propietario_adulto__c = null;
        testAcc1.Propietario_3__c = null;
        insert testAcc1;
        
        test.startTest();
        
        testAcc1.Propietario_adulto__c = user2.Id;
        testAcc1.Propietario_3__c = user3.Id;
        
        Database.SaveResult result = Database.update(testAcc1, false);
        
        
        test.stopTest();
        
        System.assert(result.isSuccess() == true);
    }
    @isTest
    Public static void siAgregoUnPropietarioTieneQueaparecerEnLaRelacionadaTambien() {
        String status;
        
        Profile profileIdTest = [SELECT Id FROM Profile WHERE Name = 'Usuario de Platform estándar' LIMIT 1];
        
        User user1 = Build.aUser()
            .withUsername('test1test1@gmail.com')
            .withEmail('test1test1@gmail.com')
            .withAlias('Ts')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('test apellido')
            .withCommunityNickname('test123')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profileIdTest.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        
        insert user1;
        
        
        Account testAcc3 = new Account();
        testAcc3.Name = 'cuenta 3';
        testAcc3.Canal_para_Consumidor_Baby__c = 'Farmacias';
        
        
        insert testAcc3;
        
        test.startTest();
        
        testAcc3.Propietario_Nicho__c = user1.id;
        update testAcc3;
        
        
        test.stopTest();
        
        AccountTeamMember accountteamDb = [SELECT userID FROM AccountTeamMember where accountId = :testAcc3.id];
        
        
        System.assertEquals(testAcc3.Propietario_Nicho__c, accountteamDb.userId);
        
    }
    
    @isTest
    Public static void siEliminoUnPropietarioTieneQueeliminarseEnLaRelacionadaTambien() {
        String status;
        
        Profile profileIdTest = [SELECT Id FROM Profile WHERE Name = 'Usuario de Platform estándar' LIMIT 1];
        
        User user1 = Build.aUser()
            .withUsername('test1test1@gmail.com')
            .withEmail('test1test1@gmail.com')
            .withAlias('Ts')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('test apellido')
            .withCommunityNickname('test123')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profileIdTest.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        
        insert user1;
        
        Account testAcc3 = new Account();
        testAcc3.Name = 'cuenta 3';
        testAcc3.Canal_para_Consumidor_Baby__c = 'Farmacias';
        testAcc3.Propietario_Nicho__c = user1.id;
        insert testAcc3;
        
        
        test.startTest();
        
        testAcc3.Propietario_Nicho__c = null;
        update testAcc3;
        
        test.stopTest();
        
        List<AccountTeamMember> accountteamDb = [SELECT userID FROM AccountTeamMember where accountId = :testAcc3.id];
        
        System.assertEquals(0, accountteamDb.size());
        
    }
    
    @isTest
    Public static void cargarUnPropietarioyDespuesCambiarlo() {
        List<User> usuarios = [
            SELECT Id
            FROM User
            WHERE Username LIKE '%testaccount@gmail.com'
        ];
        
        Account testAcc = new Account();
        testAcc.Name = 'cuenta actualizada';
        testAcc.Canal_para_Consumidor_Baby__c = 'Farmacias';
        testAcc.Propietario_Nicho__c = usuarios.get(0).id;
        insert testAcc;
        
        Test.startTest();
        testAcc.Propietario_Nicho__c = usuarios.get(1).id;
        update testAcc;
        Test.stopTest();
        
        
        List<AccountTeamMember> accountteamDb = [SELECT Id, userID FROM AccountTeamMember where accountId = :testAcc.id];
        List<Account> cuenta = [
            SELECT Id, Propietario_Nicho__c
            FROM Account
            WHERE Id = :testAcc.Id
        ];
        
        System.assertEquals(1, accountteamDb.size());
        
        System.assertEquals(usuarios.get(1).Id, cuenta.get(0).Propietario_Nicho__c);
        
    }
    
    /*@isTest
    Public static void siUnOperadorPartnerIntentaCargarUnaObraSocialQueNoEsDeMendozaDebeLanzarUnError() {
        String status;
        Municipio__c municipio = new Municipio__c();
        municipio.Descripcion_Provincia__c = 'MISIONES';
        Municipio.Name = 'MISIONES';
        insert municipio;
        
        Localidad__c localidad = new Localidad__c();
        Localidad.name='MISIONES';
        localidad.Municipio__c = municipio.id;
        insert localidad;

        Contact contacto = new Contact();
        contacto.LastName = 'Contacto';
        
        insert contacto;
        
        Account accObraSocial = Build.anAccountObrasocial()
            .withName('OB prueba')
            .withDNI('333')
            .withCanalParaConsumidorBaby('Farmacias')
            .build();
        accObraSocial.Localidad_look__c = localidad.id;
        
        insert accObraSocial;
        
        Profile profile = [
            SELECT Id,Name 
            FROM Profile 
            WHERE Name = 'Operador Partner'
        ].get(0);

        Id userRole = [
            SELECT Id, DeveloperName 
            FROM UserRole 
            WHERE DeveloperName = 'Operador_PSP' 
            LIMIT 1
            ].id;

        User partnerUser = new User(Alias = 'testU', Email='testU@danone.com',
                                    EmailEncodingKey='UTF-8', LastName='TestingU', LanguageLocaleKey='en_US',
                                    LocaleSidKey='en_US', ProfileId = profile.Id, UserRoleId = userRole,                                   
                                    TimeZoneSidKey='America/Los_Angeles', UserName='testU@danone.com', contactId=contacto.id);
        insert partnerUser;
        
        integer counter=0;
        List<Account> accList = new List<Account>();
        for(integer i =0;i<30;i++){
            Account testCuenta = Build.anAccountPacienteBestCare()
                .withLastName('Name Test prueba'+counter)
                .withRegimenDeInternacionDomiciliaria('Sí')
                .withEmpresadeinternaciondomiciliaria('Best care')		
                .withDNI('425452222'+counter)
                .withCanalParaConsumidorBaby('Farmacias')
                .build();
            testcuenta.OwnerId = partnerUser.id;
            testCuenta.Obra_social__pc = accObraSocial.id;
            
            accList.add(testCuenta);
            counter++;
        }
        
        insert accList;
        System.runAs(partnerUser){
            test.startTest();
            try{
                for(Account acc: accList){
                    acc.Obra_social__pc = accObraSocial.id;
                }
                update accList;
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('El operador partner solo puede cargar') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        }
        test.stopTest(); 
    }*/
    @isTest
    Public static void SiElEynPasaAtrueYcumpleLasCOndicionesSeDebenGenerarLosKits() {
        List<Product2> productos = new List<Product2>();
        
        for(integer i=0;i<5 ;i++){
            Product2 product = Build.aProduct2()
                .withProductoPara('Best Care')
                .withName('AMNoNUBA ' + i)
                .withDescription('Producto'+ i)
                .build();
                
            productos.add(product);
        }
        productos[0].ProductCode = '11593222';
        productos[1].ProductCode = '11265822';    
        productos[2].ProductCode = '11266022';    
        productos[3].ProductCode = '11265622';    
        productos[4].ProductCode = '11415722';    
        productos[4].Name = 'LP Drink';
        
        insert productos;
        
        Account testCuenta = Build.anAccountPacienteBestCare()
            .withLastName('Prueba Met')	
            .withDNI('425452222')
            .withAreaTerapeutica('Metabólicos')
            .withEstadoDePaciente('En tratamiento')
            .build();
        
        insert testCuenta;
        
        Test.startTest();
        testCuenta.EYN__c = true;
        update testCuenta;
        Test.stopTest();
        
        List<Envio_Sin_Cargo__c> kits = [
            SELECT id,Paciente__c
            FROM Envio_Sin_Cargo__c
            WHERE  Paciente__c = :testCuenta.id
        ];
        Set<Id> kitsID = new Set<Id>();
        for(Envio_Sin_Cargo__c aKit: kits){
            kitsID.add(aKit.id);
        }
        List<Producto_de_envio__c> productosDB = [
            SELECT id, Envio_sin_cargo__c,Formula__r.Name
            FROM Producto_de_envio__c
            WHERE Formula__r.Name LIKE '%AMNoNUBA%'
        ];
        List<Task> tareasEYN = [
            SELECT id,What.id
            FROM Task
            WHERE What.id IN :kitsID
        ];

        for(Producto_de_envio__c p : productosDB){
            System.debug(p.Formula__r.Name );
        }
        System.assertEquals(2, kits.size());
        System.assertEquals(4, productosDB.size()); 
        System.assertEquals(2, tareasEYN.size());
        
    }
    
    /*@isTest
    Public static void siUnOperadorPartnerIntentaCargarUnaInstitucionQueNoEsDeMendozaEnUNProfesionalDebeLanzarUnError() {
        String status;
        
        Profile profile = [
            SELECT Id,Name 
            FROM Profile 
            WHERE Name = 'Operador Partner'
        ];
        Municipio__c municipio = new Municipio__c();
        municipio.Descripcion_Provincia__c = 'MISIONES';
        Municipio.Name = 'MISIONES';
        insert municipio;
        
        Localidad__c localidad = new Localidad__c();
        Localidad.name='MISIONES';
        localidad.Municipio__c = municipio.id;
        insert localidad;
        
        Contact contacto = new Contact();
        contacto.LastName = 'Contacto';
        
        insert contacto;
        
        User user1 = Build.aUser()
            .withUsername('test1test7@gmail.com')
            .withEmail('test1test7@gmail.com')
            .withAlias('Ts')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('test apellido 3')
            .withCommunityNickname('test12345')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profile.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        user1.ContactId = contacto.id;
        insert user1;
        
        integer counter=0;
        List<Account> accList = new List<Account>();
        for(integer i =0;i<30;i++){
            Account testCuenta = Build.anAccountProfesionaldelasalud()
                .withLastName('Name Test prueba'+counter)
                .withRegimenDeInternacionDomiciliaria('Sí')
                .withEmpresadeinternaciondomiciliaria('Best care')		
                .withDNI('425452222'+counter)
                .withCanalParaConsumidorBaby('Farmacias')
                .build();
            testCuenta.OwnerId = user1.id;
            accList.add(testCuenta);
            counter++;
        }
        
        insert accList;
        
        Account institucion = Build.anAccountInstitucion()
            .withDNI('425452222')
            .build();
        institucion.Name='institucion';
        institucion.Localidad_look__c = localidad.id;
        institucion.OwnerId = user1.id;
        insert institucion;
        
        System.runAs(user1){
            test.startTest();
            try{
                for(Account acc: accList){
                    acc.Institucion__c = institucion.id;
                }
                update accList;
                
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('El operador') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            
            test.stopTest();
        }
    }*/
    @TestSetup
    public static void SetupMethod() {
        
        Profile profileIdTest = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'Usuario de Platform estándar' 
            LIMIT 1
        ];
        
        List<User> usersToInsert = new List<User> ();
        
        User user1 = Build.aUser()
            .withUsername('usuario1testaccount@gmail.com')
            .withEmail('usuario1testaccount@gmail.com')
            .withAlias('u1ta')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('test apellido')
            .withCommunityNickname('usuario1testaccount')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profileIdTest.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        
        usersToInsert.add(user1);
        
        User user2 = Build.aUser()
            .withUsername('usuario2testaccount@gmail.com')
            .withEmail('usuario2testaccount@gmail.com')
            .withAlias('u2ta')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('test apellido')
            .withCommunityNickname('usuario2testaccount')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profileIdTest.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        
        usersToInsert.add(user2);
        
        User user3 = Build.aUser()
            .withUsername('usuario3testaccount@gmail.com')
            .withEmail('usuario3testaccount@gmail.com')
            .withAlias('u3ta')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('test apellido')
            .withCommunityNickname('usuario3testaccount')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profileIdTest.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        
        usersToInsert.add(user3);
        
        User user4 = Build.aUser()
            .withUsername('usuario4testaccount@gmail.com')
            .withEmail('usuario4testaccount@gmail.com')
            .withAlias('u4ta')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('test apellido')
            .withCommunityNickname('usuario4testaccount')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profileIdTest.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        
        usersToInsert.add(user4);
        
        User user5 = Build.aUser()
            .withUsername('usuario5testaccount@gmail.com')
            .withEmail('usuario5testaccount@gmail.com')
            .withAlias('u5ta')
            .withTimeZoneSidKey('GMT')
            .withLocaleSidKey('en_US')
            .withLastName('test apellido')
            .withCommunityNickname('usuario5testaccount')
            .withEmailEncodingKey('UTF-8')
            .withProfileId(profileIdTest.id)
            .withLanguageLocaleKey('en_US')
            .Build();
        
        usersToInsert.add(user5);
        
        
        insert usersToInsert;
    }
    
    
}