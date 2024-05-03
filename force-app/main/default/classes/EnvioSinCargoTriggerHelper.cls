public class EnvioSinCargoTriggerHelper {

    public static void createUsersForPacientesRegularesYBestCare(Set<Id> idPacientes) {
        List<User> newUsers = new List<User>();
        Map<String,String> mapAreaPerfil = getMapAreasYPerfiles();
        Map<String,Id> mapNombreIdPerfil = getMapPerfilesIds(mapAreaPerfil);
        Set<Id> setIdsProductosDeEnvio = new Set<Id>();
        
        List<Account> pacientes = [
            SELECT  Id, FirstName, LastName, PersonEmail, PersonContactId, Area_terapeutica__c, DNI__c
            FROM    Account
            WHERE   Id IN: idPacientes
        ];

        Set<String> areas = new Set<String>();
        Schema.DescribeFieldResult campo = Product2.Area_Terapeutica__c.getDescribe();
        List<Schema.PicklistEntry> valores = campo.getPicklistValues();
        for ( Schema.PicklistEntry valor : valores) {
            areas.add(valor.getLabel());
        }

        for (Account paciente : pacientes) {
            if(areas.contains(paciente.Area_terapeutica__c) && mapAreaPerfil.containsKey(paciente.Area_terapeutica__c)){
                String tiempo = '' + System.now().getTime();
                User newUser = new User();
                newUser.ProfileId = mapNombreIdPerfil.get(mapAreaPerfil.get(paciente.Area_terapeutica__c));
                newUser.Username = paciente.DNI__c + '-' + tiempo.substring(0,4) + '@danone.com';
                newUser.Alias = paciente.DNI__c;
                newUser.Email = paciente.PersonEmail;
                newUser.EmailEncodingKey = 'UTF-8';
                newUser.FirstName = paciente.FirstName;
                newUser.Lastname = paciente.LastName;
                newUser.LanguageLocaleKey = 'es';
                newUser.LocaleSidKey = 'es';
                newUser.TimeZoneSidKey = 'America/Argentina/Buenos_Aires';
                newUser.ContactId = paciente.PersonContactId;
                
                newUsers.add(newUser);
            }
        }
        
        insert newUsers;
    }
    
    public static Map<String,String> getMapAreasYPerfiles() {
        Map<String,String> mapAreaPerfil = new Map<String,String>();
        List<Dependencia_Area_Perfil__mdt> dependencias = [
            SELECT  Area_Terapeutica__c, Perfil_de_Paciente_Regular__c 
            FROM    Dependencia_Area_Perfil__mdt
        ];
        
        for (Dependencia_Area_Perfil__mdt areaPerfil : dependencias) {
            mapAreaPerfil.put(areaPerfil.Area_Terapeutica__c, areaPerfil.Perfil_de_Paciente_Regular__c);
        }
        
        return mapAreaPerfil;   
    }

    public static Map<String,Id> getMapPerfilesIds(Map<String,String> mapAreaPerfil) {
        Map<String,Id> mapPerfilId = new Map<String,Id>();
        List<Profile> perfiles = [
            SELECT  Id, Name
            FROM    Profile
            WHERE   Name IN: mapAreaPerfil.values()
        ];
        
        for (Profile perfil : perfiles) {
            mapPerfilId.put(perfil.Name, perfil.Id);
        }
        
        return mapPerfilId;
    }
    
    public static void revisarPacientesConUsuarios(Set<Id> idPacientes) {
        Map<Id,Id> mapIdContactoIdPaciente = new Map<Id,Id>();
        Map<Id,Id> mapIdContactoPacienteIdUsuario = new Map<Id,Id>();
        Set<Id> idPacientesParaCrearUsuario = new Set<Id>();
        //Obtengo contactos de pacientes regulares
        List<Account> pacientesRegularesYBestCare = [
            SELECT  Id, PersonContactId, Area_terapeutica__c
            FROM    Account
            WHERE   Id IN:idPacientes
                AND (RecordTypeId =: XappiaHelper.getRecordType('Account', 'Paciente Regular').Id
                    OR RecordTypeId =: XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id)
        ];
        
        for (Account paciente : pacientesRegularesYBestCare) {
            mapIdContactoIdPaciente.put(paciente.PersonContactId, paciente.Id);
        }
        
        List<User> usuarios = [
            SELECT  Id, ContactId
            FROM    User
            WHERE   ContactId IN: mapIdContactoIdPaciente.keySet()
        ];
        
        for (User user : usuarios) {
            mapIdContactoPacienteIdUsuario.put(user.ContactId, user.Id);
        }
        
        //Si el paciente regular no tiene usuario se lo creo
        for (Account paciente : pacientesRegularesYBestCare) {
            if (!mapIdContactoPacienteIdUsuario.containsKey(paciente.PersonContactId)) {
                idPacientesParaCrearUsuario.add(paciente.Id);
            }
        }
        
        if (!idPacientesParaCrearUsuario.isEmpty()) {
            createUsersForPacientesRegularesYBestCare(idPacientesParaCrearUsuario);
        }
    }

    public static void updateFieldsToKamAlert(List<Envio_sin_Cargo__c> kits) {
        Set<Id> enviosIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> tratamientosIds = new Set<Id>();
        Map<id, Tratamiento__c> accountsTratamientosMap = new Map<id, Tratamiento__c>();
        Map<id, Tratamiento_de_profesional__c> tratamientoAndProfesionalMap = new Map<id, Tratamiento_de_profesional__c>();
        Map<id, String> kitAndProductList = new Map<id, String>();
        
        for(Envio_sin_Cargo__c aKit: kits){
            accountIds.add(aKit.Paciente__c);
            enviosIds.add(aKit.id);
        }
        
        List<Producto_de_envio__c> productos = [
            SELECT id,Formula__r.Name,Envio_sin_Cargo__c, Name
            FROM Producto_de_envio__c
            WHERE Envio_sin_Cargo__c IN :enviosIds
            ORDER BY Formula__r.Name DESC
            ];

        for (Producto_de_envio__c aProd : productos) {
            if(kitAndProductList.containsKey(aProd.Envio_sin_Cargo__c)){
                String nombresConcatenados= kitAndProductList.get(aProd.Envio_sin_Cargo__c);
                //Se puso esta logica pra cortar el string asi no sobrepasa los caracteres maximos de 255, ya que quisieron ir por este camino
                //Recomendacion: Cambiar a text Area o Ver de utilizar otro campo.
                if(nombresConcatenados.length() + aProd.Formula__r.Name.length() > 255){
                    break;
                }
                kitAndProductList.put(aProd.Envio_sin_Cargo__c, nombresConcatenados + ' - ' + aProd.formula__r.Name);
            }else{
                kitAndProductList.put(aProd.Envio_sin_Cargo__c, aProd.formula__r.Name);
            }
        }
       
        List<Tratamiento__c> tratamientos = [
            SELECT id,Centro_de_tratamiento__r.Name,cuenta__c
            FROM Tratamiento__c
            WHERE Cuenta__c IN : accountIds
            AND Activo__c= true
        ];
        
        for(Tratamiento__c aTratamiento : tratamientos){
            accountsTratamientosMap.put(aTratamiento.cuenta__c, aTratamiento);
            tratamientosIds.add(aTratamiento.id);
        }
        
        List<Tratamiento_de_profesional__c> tratamientosProfesional =[
            SELECT Tratamiento__c,profesional__r.Name
            FROM Tratamiento_de_profesional__c
            WHERE Tratamiento__c IN : tratamientosIds
        ];
        
        for(Tratamiento_de_profesional__c aTratProf : tratamientosProfesional){
            tratamientoAndProfesionalMap.put(aTratProf.tratamiento__c, aTratProf);
        }
        
        for(Envio_sin_Cargo__c aKit : kits){
            Tratamiento__c aTratamiento = accountsTratamientosMap.get(aKit.Paciente__c);
            Tratamiento_de_profesional__c aTratamientoProfesional = aTratamiento!= null ? tratamientoAndProfesionalMap.get(aTratamiento.id) : null;
            String productListName = kitAndProductList.get(aKit.id);
            if(productListName!=null){
                aKit.Formula_de_producto_de_envio__c = productListName;
            }
            if(aTratamiento!=null){
                aKit.Centro_de_tratamiento_activo__c = aTratamiento.Centro_de_tratamiento__r.Name;
            }
            if(aTratamientoProfesional!=null){
                aKit.Profesional_de_tratamiento_activo__c = aTratamientoProfesional.profesional__r.Name;
            }
            
        }
    }

    public static void cerrarCasosKitDeInicio(Set<Id> idKitsCancelados) {

        List<Case> casosDeKit = [
            SELECT  Id
            FROM    Case
            WHERE   Env_o_sin_cargo__c IN: idKitsCancelados
        ];

        for(Case caso : casosDeKit) {
            caso.Status = 'Cerrado';
        }

        if (!casosDeKit.isEmpty()) {
            update casosDeKit;
        }

    }

}