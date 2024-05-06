@RestResource(urlMapping='/resetUserPassword/*')
global with sharing class WSResetPassword {

	@HttpPost
	global static Respuesta resetPassword() {
		
		RestRequest req = RestContext.request;
        Respuesta respuesta = new Respuesta();
        Map<String, String> headers = new Map<String, String>();
        
        for (String header : req.headers.keySet()) {
			System.debug(header);
			if(header == 'newpassword'){
				headers.put(header.toLowerCase(),req.headers.get(header));	
			} else {
				headers.put(header.toLowerCase(),req.headers.get(header).toLowerCase());
			}
            
        }
        String userName = headers.containsKey('username') ? headers.get('username') : null;
        String currentPassword = headers.containsKey('currentpassword') ? headers.get('currentpassword') : null;
        String newPassword = headers.containsKey('newpassword') ? headers.get('newpassword') : null;
		System.debug(userName);
		System.debug(newPassword);
		User userToUpdatePass = [SELECT Id, VisMed_ContrasenaApp__c FROM User WHERE Email = :userName AND VisMed_Es_un_Visitador_Medico__c = true];

		if (userToUpdatePass != null && userToUpdatePass.VisMed_ContrasenaApp__c == currentPassword) {
			userToUpdatePass.VisMed_ContrasenaApp__c = newPassword;
			Database.SaveResult sr = Database.update(userToUpdatePass);
			if (sr.isSuccess()) {
				respuesta.status = 200;
				respuesta.message = 'Contraseña cambiada exitosamente';
				return respuesta;
			} else {
				respuesta.status =  401;
				respuesta.message = 'Ocurrieron erróres durante la actualización de contraseña.';
				return respuesta;
			}
		} else if (currentPassword == null || currentPassword == '') { // Inicio un proceso de aprobacion para que el USER pueda decidir si aprobar o no desde el mail.
			Cambio_de_Contrasena_App_User__c changePass = new Cambio_de_Contrasena_App_User__c(
				Estado__c = 'Pendiente',
				User__c = userToUpdatePass.Id,
				Pass__c = newPassword,
				OwnerId = userToUpdatePass.Id
			);
			Database.SaveResult sr = Database.insert(changePass);
			if (sr.isSuccess()) {
				respuesta.status = 200;
				respuesta.message = 'Solicitud de cambio enviada al correo electronico';
				return respuesta;
			} else {
				respuesta.status =  401;
				respuesta.message = 'Ocurrieron erróres durante la actualización de contraseña.';
				return respuesta;
			}
		} else {
			respuesta.status = 401;
			respuesta.message = 'El usuario y/o contraseña no existen.';
			return respuesta;
		}

	}

	global class Respuesta {
		public Integer status {get; set;}
		public String message {get;set;}
		public User user {get; set;}
	}
}