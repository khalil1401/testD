@IsTest
public class WSLoginAppTest {
    @TestSetup
    static void makeData(){
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
        userOwner.VisMed_Es_un_Visitador_Medico__c = true;
        userOwner.VisMed_ContrasenaApp__c = 'TestOwner';
        insert userOwner;
    }

    @IsTest
    public static void ValidateLoginSuccess(){
        
        List<User> userCreated = [
            SELECT Id,UserName,VisMed_ContrasenaApp__c
            FROM User
            WHERE Email = 'owner@xappia.com'
            AND Alias = 'owner'
            AND CommunityNickname = 'prueba2.xappia'
        ];

        RestRequest req = new RestRequest();
        req.addHeader('username', userCreated.get(0).UserName);
        req.addHeader('token', userCreated.get(0).VisMed_ContrasenaApp__c);
        req.addHeader('lastSyncString', 'lastSyncString');

        req.requestURI = '/services/apexrest/login/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        
        Test.startTest();
        WSLoginApp.Respuesta resp = WSLoginApp.doGet();
        Test.stopTest();

        System.assertEquals(200,resp.status, 'Error en el consumo del WS');
        System.assertEquals('Usuario y Password Correctos',resp.message, 'Error en los datos');
    }

    @IsTest
    public static void ValidateLoginError(){
        
        List<User> userCreated = [
            SELECT Id,UserName,VisMed_ContrasenaApp__c
            FROM User
            WHERE Email = 'owner@xappia.com'
            AND Alias = 'owner'
            AND CommunityNickname = 'prueba2.xappia'
        ];

        RestRequest req = new RestRequest();
        req.addHeader('username', userCreated.get(0).UserName);
        req.addHeader('token', 'error');
        req.addHeader('lastSyncString', 'lastSyncString');

        req.requestURI = '/services/apexrest/login/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        
        Test.startTest();
        WSLoginApp.Respuesta resp = WSLoginApp.doGet();
        Test.stopTest();

        System.assertEquals(401,resp.status, 'Error en el consumo del WS');
        System.assertEquals('Usuario o Password Incorrectos',resp.message, 'Error en los datos');
    }
}