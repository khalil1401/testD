@isTest public class InteractionTriggerTest  {
    @isTest public static void siHoyEsFeriadoNoPuedoCrearVisitaMedica(){
        Account anAccount = Build.anAccountProfesionaldelasalud()
            .withLastName('Perez')
            .build();
        insert anAccount;
        
        Feriado__c feriado = Build.aFeriado()
            .withFecha(Date.newInstance(2018, 7, 9))
            .build();
        insert feriado;
        
        Date today = System.today();
        Ciclo__c ciclo = Build.aCiclo()
            .withFechaDeInicio(today.addDays(-20))
            .withFechaDeFin(today.addDays(20))
            .build();
        insert ciclo;
        Interaccion__c visitaMedica = Build.aInteraccion()
            .withFecha(Date.newInstance(2018, 7, 9))  // 9 de Julio
            .withTipoDeVisita('Presencial')
            .withCiclo(ciclo)
            .withProfesionalDeLaSalud(anAccount.Id)
            .build();
        
        Test.startTest();
        Boolean res;
        try{
            insert visitaMedica;
            res = true;
        }
        catch(DmlException e){
            res = false;
        }
        Test.stopTest();
        
        System.assertEquals(false, res);
    }
    
    @isTest public static void siHoyEsFinDeSemanaNoPuedoCrearVisitaMedica(){
        Account anAccount = Build.anAccountProfesionaldelasalud()
            .withLastName('Perez')
            .build();
        insert anAccount;
        
        Date today = System.today();
        Ciclo__c ciclo = Build.aCiclo()
            .withFechaDeInicio(today.addDays(-20))
            .withFechaDeFin(today.addDays(20))
            .build();
        insert ciclo;
        Interaccion__c visitaMedica = Build.aInteraccion()
            .withTipoDeVisita('Presencial')
            .withCiclo(ciclo)
            .withProfesionalDeLaSalud(anAccount.Id)
            .withFecha(Date.newInstance(2018, 7, 29))		// Domingo
            .build();
        
        Test.startTest();
        Boolean res;
        try{
            insert visitaMedica;
            res = true;
        }
        catch(DmlException e){
            res = false;
        }
        Test.stopTest();
        
        System.assertEquals(false, res);
    }
    
    @isTest public static void siNoSeSeleccionaUnaFechaNoSePuedeCrearVisitaMedica(){
        Account anAccount = Build.anAccountProfesionaldelasalud()
            .withLastName('Perez')
            .build();
        insert anAccount;
        
        Date today = System.today();
        Ciclo__c ciclo = Build.aCiclo()
            .withFechaDeInicio(today.addDays(-20))
            .withFechaDeFin(today.addDays(20))
            .build();
        insert ciclo;
        Interaccion__c visitaMedica = Build.aInteraccion()
            .withTipoDeVisita('Presencial')
            .withCiclo(ciclo)
            .withProfesionalDeLaSalud(anAccount.Id)
            .withFecha(null)
            .build();
        //Debido a que la fecha ya tiene un valor por default, para que el test tenga sentido, debo forzar a que el usuario no setee la fecha intencionalmente.
        
        Test.startTest();
        Boolean res;
        try{
            insert visitaMedica;
            res = true;
        }
        catch(DmlException e){
            res = false;
        }
        Test.stopTest();
        
        System.assertEquals(false, res);
    }
    
    @isTest 
    public static void siEsAPMadultoYElProfesionalYaFueIngresadoEnElMesDelCicloDebeLanzarUnError(){
        
        Account anAccount = new Account();
        anAccount.Name = 'APM Adultos';
        
        insert anAccount;
        
        Account prof1 = Build.anAccountProfesionaldelasalud()
            .build();
        prof1.lastName = 'test prof';
        insert prof1;
        
        
        Contact contactTest = Build.aContact()
            .withLastName('Test')
            .withFirstName('Contact')
            .forAccount(anAccount)
            .Build();
        
        insert contactTest;
        
        Date today = System.today();
        
        Ciclo__c ciclo = Build.aCiclo()
            .withFechaDeInicio(today.addDays(-14))
            .withFechaDeFin(today.addDays(10))
            .build();
        ciclo.ContactId__c = contactTest.id;
        insert ciclo;
        
        Interaccion__c visitaMedica = Build.aInteraccion()
            .withTipoDeVisita('Presencial')
            .withCiclo(ciclo)
            .withProfesionalDeLaSalud(prof1.Id)
            .withFecha(null)
            .build();
        visitaMedica.Fecha__c = System.today();
        
        insert visitaMedica;
        
        Interaccion__c visitaMedica2 = Build.aInteraccion()
            .withTipoDeVisita('Presencial')
            .withCiclo(ciclo)
            .withProfesionalDeLaSalud(prof1.Id)
            .withFecha(null)
            .build();
        visitaMedica2.Fecha__c = System.today();
        
        Profile p = [
            SELECT Id,Name,UserLicense.Name 
            FROM Profile 
            WHERE UserLicense.Name ='Partner Community'
        ].get(0);
        
        User u1 = new User(Alias = 'testU', Email='testU@danone.com',
                           EmailEncodingKey='UTF-8', LastName='TestingU', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='testU@danone.com' ,contactId=contactTest.id);
        
        System.runAs(u1) {
            Test.startTest();
            String res;
            boolean error = false;
            
            try{	
                insert visitaMedica2;
            }
            catch(Exception e){
                error = e.getMessage().contains('Error. No se puede cargar la interaccion, el profesional ya fue registrado en ese ciclo');
            }
            Test.stopTest();
            System.assertEquals(true, error);
        }
    }
}