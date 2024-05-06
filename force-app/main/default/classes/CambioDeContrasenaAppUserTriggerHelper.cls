public with sharing class CambioDeContrasenaAppUserTriggerHelper {
    
    public static void updateUserPass (List<Cambio_de_Contrasena_App_User__c> procesos) {
        Map<Id, String> usuariosXPass = new Map<Id, String>();
        for (Cambio_de_Contrasena_App_User__c proceso : procesos){
            usuariosXPass.put(proceso.User__c, proceso.Pass__c);
        }
        List<User> usuariosToUpdatePass = [
            SELECT Id, VisMed_ContrasenaApp__c
            FROM User
            WHERE Id IN :usuariosXPass.keySet()
        ];

        for (User usuario : usuariosToUpdatePass) {
            usuario.VisMed_ContrasenaApp__c = usuariosXPass.get(usuario.Id);
        }

        if(!usuariosToUpdatePass.isEmpty()){
            UpdateUser(JSON.serialize(usuariosToUpdatePass));
        }
    }

    @Future
    public static void UpdateUser(String usersToUpdate){
        List<User> usuarios = (List<User>)Json.deserialize(usersToUpdate, List<User>.Class);

        update usuarios;
    }
}