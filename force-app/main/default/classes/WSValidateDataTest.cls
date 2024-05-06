@IsTest
public class WSValidateDataTest {
    @TestSetup
    static void makeData(){
        List<Account> accToInsert = new List<Account>();
        Id recordTypeInstitucion = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Institucion').getRecordTypeId();
        Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId(); 
        Id recordTypeOtroProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Otro_Profesional').getRecordTypeId(); 

        Account accInstitucion = Build.anAccount()
            .withName('Institucion Test')
            .withRecordTypeId(recordTypeInstitucion)
            .build();
        accInstitucion.BillingStreet = 'Inst BillingStreet';
        accInstitucion.BillingCity = 'Buenos Aires';
        accInstitucion.BillingPostalCode = '1100';
        accInstitucion.BillingState = 'Buenos Aires';
        accToInsert.add(accInstitucion);

        Account acProfesional = Build.anAccount()
            .withRecordTypeId(recordTypeProfesional)
            .build();
        acProfesional.Firstname = 'Profesional';
        acProfesional.LastName = 'Test';  
        acProfesional.Primera_especialidad__c = 'Alergista';
        acProfesional.Segunda_especialidad__c = 'Nutricionista';
        acProfesional.Tercera_especialidad__c = 'Alergista';
        accToInsert.add(acProfesional);

        Account acOtroProfesional = Build.anAccount()
            .withRecordTypeId(recordTypeOtroProfesional)
            .build();
        acOtroProfesional.Firstname = 'Otro';
        acOtroProfesional.LastName = 'Test';  
        acOtroProfesional.DNI__c = '12456798';
        acOtroProfesional.Primera_especialidad__c = 'Alergista';
        acOtroProfesional.Segunda_especialidad__c = 'Nutricionista';
        acOtroProfesional.Tercera_especialidad__c = 'Alergista';
        accToInsert.add(acOtroProfesional);

        insert accToInsert;

        Dan360_Matricula__c matr = Build.aDan360MatriculaNacional()
            .withNumerodematricula('12345')
            .withProfesional(acProfesional)
            .build();
        insert matr;
    }   

    @IsTest
    public static void ValidateInstitucionSuccess(){
        Id recordTypeInstitucion = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Institucion').getRecordTypeId();
        
        RestRequest req = new RestRequest();
        req.addHeader('Objeto', 'Institucion');
        req.addHeader('Name', 'Institucion Test');
        req.addHeader('Calle', 'Inst BillingStreet');
        req.addHeader('Localidad', 'Buenos Aires');
        req.addHeader('CodigoPostal', '1100');
        req.addHeader('Provincia', 'Buenos Aires');

        req.requestURI = '/services/apexrest/info/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        
        Test.startTest();
        WSValidateData.Respuesta resp = WSValidateData.doGet();
        Test.stopTest();

        Account accFromRespone = (Account)resp.rObject;
        System.assertEquals(200,resp.status, 'Error en el consumo del WS');
        System.assertEquals('Institucion Test',accFromRespone.Name, 'Error en los datos');
        System.assertEquals(recordTypeInstitucion,accFromRespone.RecordTypeId, 'Error en los datos');
        System.assertEquals('Inst BillingStreet',accFromRespone.BillingStreet, 'Error en los datos');
        System.assertEquals('Buenos Aires',accFromRespone.BillingCity, 'Error en los datos');
        System.assertEquals('1100',accFromRespone.BillingPostalCode, 'Error en los datos');
        System.assertEquals('Buenos Aires',accFromRespone.BillingState, 'Error en los datos');
    }

    @IsTest
    public static void ValidateInstitucionFail(){
        
        RestRequest req = new RestRequest();
        req.addHeader('Objeto', 'Institucion');
        req.addHeader('Name', 'Institucion No Existe');
        req.addHeader('Calle', 'Inst BillingStreet');
        req.addHeader('Localidad', 'Buenos Aires');
        req.addHeader('CodigoPostal', '1100');
        req.addHeader('Provincia', 'Buenos Aires');

        req.requestURI = '/services/apexrest/info/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        
        Test.startTest();
        WSValidateData.Respuesta resp = WSValidateData.doGet();
        Test.stopTest();

        Account accFromRespone = (Account)resp.rObject;
        System.assertEquals(401,resp.status, 'Error en el consumo del WS');
        System.assertEquals(null,resp.rObject, 'Error en los datos');
    }

    @IsTest
    public static void ValidateProfesionalDelaSaludSuccess(){        
        RestRequest req = new RestRequest();
        req.addHeader('Objeto', 'profesional de la salud');
        req.addHeader('matricula', '12345');

        req.requestURI = '/services/apexrest/info/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        
        Test.startTest();
        WSValidateData.Respuesta resp = WSValidateData.doGet();
        Test.stopTest();

        Dan360_Matricula__c matriculaFromRespone = (Dan360_Matricula__c)resp.rObject;
        System.assertEquals(200,resp.status, 'Error en el consumo del WS');
        System.assertEquals('Test',matriculaFromRespone.Profesional__r.LastName, 'Error en los datos');
        System.assertEquals('Profesional',matriculaFromRespone.Profesional__r.FirstName, 'Error en los datos');
        System.assertEquals('Alergista',matriculaFromRespone.Profesional__r.Primera_especialidad__c, 'Error en los datos');
        System.assertEquals('Nutricionista',matriculaFromRespone.Profesional__r.Segunda_especialidad__c, 'Error en los datos');
        System.assertEquals('Alergista',matriculaFromRespone.Profesional__r.Tercera_especialidad__c, 'Error en los datos');
    }

    @IsTest
    public static void ValidateProfesionalDelaSaludFail(){        
        RestRequest req = new RestRequest();
        req.addHeader('Objeto', 'profesional de la salud');
        req.addHeader('matricula', '789465');

        req.requestURI = '/services/apexrest/info/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        
        Test.startTest();
        WSValidateData.Respuesta resp = WSValidateData.doGet();
        Test.stopTest();

        System.assertEquals(401,resp.status, 'Error en el consumo del WS');
        System.assertEquals(null,resp.rObject, 'Error en los datos');
    }

    @IsTest
    public static void ValidateOtroProfesionalSuccess(){        
        RestRequest req = new RestRequest();
        req.addHeader('Objeto', 'otro profesional');
        req.addHeader('DNI', '12456798');

        req.requestURI = '/services/apexrest/info/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        
        Test.startTest();
        WSValidateData.Respuesta resp = WSValidateData.doGet();
        Test.stopTest();

        Account accountFromRespone = (Account)resp.rObject;
        System.assertEquals(200,resp.status, 'Error en el consumo del WS');
        System.assertEquals('Test',accountFromRespone.LastName, 'Error en los datos');
        System.assertEquals('Otro',accountFromRespone.FirstName, 'Error en los datos');
        System.assertEquals('Alergista',accountFromRespone.Primera_especialidad__c, 'Error en los datos');
        System.assertEquals('Nutricionista',accountFromRespone.Segunda_especialidad__c, 'Error en los datos');
        System.assertEquals('Alergista',accountFromRespone.Tercera_especialidad__c, 'Error en los datos');
    }

    @IsTest
    public static void ValidateOtroProfesionalFail(){        
        RestRequest req = new RestRequest();
        req.addHeader('Objeto', 'otro profesional');
        req.addHeader('DNI', '99999999');

        req.requestURI = '/services/apexrest/info/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        
        Test.startTest();
        WSValidateData.Respuesta resp = WSValidateData.doGet();
        Test.stopTest();

        System.assertEquals(401,resp.status, 'Error en el consumo del WS');
        System.assertEquals(null,resp.rObject, 'Error en los datos');
    }
}