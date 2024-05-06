@IsTest
public class CambioDeContrasenaAppUserTriggerTest {
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
    public static void ValidateTrigger(){
        List<User> usuario = [
            SELECT Id,VisMed_ContrasenaApp__c
            FROM User
            WHERE Email = 'owner@xappia.com'
        ];

        Cambio_de_Contrasena_App_User__c cambio = new Cambio_de_Contrasena_App_User__c();
        cambio.User__c = usuario.get(0).Id;
        cambio.Pass__c = 'NewPass';
        insert cambio;

        Test.startTest();
        cambio.Estado__c = 'Aprobada';
        update cambio;
        Test.stopTest();

        usuario = [
            SELECT Id,VisMed_ContrasenaApp__c
            FROM User
            WHERE Id = :usuario.get(0).Id
        ];

        system.assertEquals('NewPass', usuario.get(0).VisMed_ContrasenaApp__c, 'Error en trigger');
    }
}