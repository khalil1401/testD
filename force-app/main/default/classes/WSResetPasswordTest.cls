@IsTest
public class WSResetPasswordTest {
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
    public static void ValidateCorrectUpdateOfPass(){
       
        RestRequest req = new RestRequest();
        req.addHeader('newpassword','NewPassword');
        req.addHeader('username','owner@xappia.com');
        req.addHeader('currentpassword','TestOwner');
        
        req.requestURI = '/services/apexrest/resetUserPassword/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        WSResetPassword.Respuesta resp = WSResetPassword.resetPassword();
        Test.stopTest();

        List<user> userToChagePass = [
            SELECT Id,VisMed_ContrasenaApp__c
            FROM User
            WHERE CommunityNickname = 'prueba2.xappia'
        ];

        system.assertEquals(200, resp.status);
        system.assertEquals('Contraseña cambiada exitosamente', resp.message);
        system.assertEquals('NewPassword',userToChagePass.get(0).VisMed_ContrasenaApp__c);

    }

    @IsTest
    public static void ValidateErrorWhenUpdatePass(){
       
        RestRequest req = new RestRequest();
        req.addHeader('newpassword','NewPassword');
        req.addHeader('username','owner@xappia.com');
        req.addHeader('currentpassword','TestOwnerFailed');
        
        req.requestURI = '/services/apexrest/resetUserPassword/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        WSResetPassword.Respuesta resp = WSResetPassword.resetPassword();
        Test.stopTest();

        system.assertEquals(401, resp.status);
        system.assertEquals('El usuario y/o contraseña no existen.', resp.message);
    }
    
    @IsTest
    public static void ValidateCurrentPassNull(){
       
        RestRequest req = new RestRequest();
        req.addHeader('newpassword','NewPassword');
        req.addHeader('username','owner@xappia.com');
        req.addHeader('currentpassword','');
        
        req.requestURI = '/services/apexrest/resetUserPassword/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        WSResetPassword.Respuesta resp = WSResetPassword.resetPassword();
        Test.stopTest();

        List<Cambio_de_Contrasena_App_User__c> listChangePass = [
            SELECT Id,Estado__c,User__c,Pass__c,OwnerId
            FROM Cambio_de_Contrasena_App_User__c
        ];

        List<user> userToChagePass = [
            SELECT Id,VisMed_ContrasenaApp__c
            FROM User
            WHERE CommunityNickname = 'prueba2.xappia'
        ];

        system.assertEquals(200, resp.status);
        system.assertEquals('Solicitud de cambio enviada al correo electronico', resp.message);
        system.assertEquals('Pendiente',listChangePass.get(0).Estado__c);
        system.assertEquals(userToChagePass.get(0).Id,listChangePass.get(0).User__c);
        system.assertEquals('NewPassword',listChangePass.get(0).Pass__c);
        system.assertEquals(userToChagePass.get(0).Id,listChangePass.get(0).OwnerId);
    }
}