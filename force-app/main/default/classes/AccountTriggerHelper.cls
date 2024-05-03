public class AccountTriggerHelper {
    public static void validaQueEnLacuentaNoExistanDuplicados(List<Account> verifyDuplicated) {
        for (Account cuenta : verifyDuplicated) {
            List<Id> idsPropietarios = new List<Id> { cuenta.OwnerId };
                Boolean hasDuplicate = false;
            if (!idsPropietarios.contains(cuenta.Propietario_3__c)) {
                if (String.isNotBlank(cuenta.Propietario_3__c)) {
                    idsPropietarios.add(cuenta.Propietario_3__c);
                }
            }
            else {
                hasDuplicate = true;
            }
            
            if (!idsPropietarios.contains(cuenta.Propietario_4__c)) {
                if (String.isNotBlank(cuenta.Propietario_4__c)) {
                    idsPropietarios.add(cuenta.Propietario_4__c);
                }
            }
            else {
                
                hasDuplicate = true;
            }
            
            if (!idsPropietarios.contains(cuenta.Propietario_5__c)) {
                if (String.isNotBlank(cuenta.Propietario_5__c)) {
                    idsPropietarios.add(cuenta.Propietario_5__c);
                }
            }
            else {
                hasDuplicate = true;
            }
            
            if (!idsPropietarios.contains(cuenta.Propietario_Nicho__c)) {
                if (String.isNotBlank(cuenta.Propietario_Nicho__c)) {
                    idsPropietarios.add(cuenta.Propietario_Nicho__c);
                }
            }
            else {
                hasDuplicate = true;
            }
            
            if (!idsPropietarios.contains(cuenta.Propietario_adulto__c)) {
                if (String.isNotBlank(cuenta.Propietario_adulto__c)) {
                    idsPropietarios.add(cuenta.Propietario_adulto__c);
                }
            }
            else {
                hasDuplicate = true;
            }
            
            if (hasDuplicate) {
                cuenta.addError('Este propietario ya se encuentra asignado en la cuenta.');
            }
        }
    }
    
    public static void insertaOactualizarEquipo(List<Account> cuentas, Map<Id, Account> oldMap) {
        List<Id> cuentasUpdate = new List<Id> ();
        List<Id> allAccounts = new List<Id> ();
        List<Account> cuentasUpdated = new List<Account> ();
        for (Account cuenta : cuentas) {
            allAccounts.add(cuenta.id);
            Account oldAccount = new Account();
            
            if (!oldMap.isEmpty()) {
                if (oldMap.containsKey(cuenta.Id)) {
                    oldAccount = oldMap.get(cuenta.Id);
                }
                
            }
            
            
            if (
                cuenta.Propietario_3__c != oldAccount.Propietario_3__c ||
                cuenta.Propietario_4__c != oldAccount.Propietario_4__c ||
                cuenta.Propietario_5__c != oldAccount.Propietario_5__c ||
                cuenta.Propietario_Nicho__c != oldAccount.Propietario_Nicho__c ||
                cuenta.Propietario_adulto__c != oldAccount.Propietario_adulto__c
            ) {
                cuentasUpdate.add(cuenta.id);
                cuentasUpdated.add(cuenta);
            }
        }
        
        List<AccountTeamMember> miembrosDeEquipo = [
            SELECT Id, AccountId, UserId
            FROM AccountTeamMember
            WHERE AccountId IN :cuentasUpdate
        ];
        
        List<AccountTeamMember> toDelete = new List<AccountTeamMember> ();
        
        for (AccountTeamMember atm : miembrosDeEquipo) {
            List<Id> propietariosIds = new List<Id> ();
            for (Account cuenta : cuentasUpdated) {
                if (cuenta.Id == atm.AccountId) {
                    propietariosIds.add(cuenta.Propietario_3__c);
                    propietariosIds.add(cuenta.Propietario_4__c);
                    propietariosIds.add(cuenta.Propietario_5__c);
                    propietariosIds.add(cuenta.Propietario_Nicho__c);
                    propietariosIds.add(cuenta.Propietario_adulto__c);
                }
            }
            if (!propietariosIds.contains(atm.UserId)) {
                toDelete.add(atm);
            }
        }
        
        if (!toDelete.isEmpty()) {
            Database.delete(toDelete, false);
        }
        
        
        miembrosDeEquipo = [
            SELECT Id, AccountId, UserId
            FROM AccountTeamMember
            WHERE AccountId IN :allAccounts
        ];
        
        Map<Id, List<Id>> accountTeamMemebers = new Map<Id, List<Id>> ();
        
        for (AccountTeamMember atm : miembrosDeEquipo) {
            if (!accountTeamMemebers.containsKey(atm.AccountId)) {
                accountTeamMemebers.put(atm.AccountId, new List<Id> { atm.UserId });
            }
            else {
                accountTeamMemebers.get(atm.AccountId).add(atm.UserId);
            }
        }
        
        
        
        List<AccountTeamMember> accountTeamsMemberToInsert = new List<AccountTeamMember> ();
        for (Account cuenta : cuentas) {
            
            List<Id> membersTeam = new List<Id> ();
            if (accountTeamMemebers.containsKey(cuenta.Id)) {
                membersTeam = accountTeamMemebers.get(cuenta.Id);
            }
            if (!membersTeam.contains(cuenta.Propietario_3__c) && String.isNotBlank(cuenta.Propietario_3__c)) {
                AccountTeamMember atm = new AccountTeamMember();
                atm.UserId = cuenta.Propietario_3__c;
                atm.AccountId = cuenta.Id;
                accountTeamsMemberToInsert.add(atm);
            }
            if (!membersTeam.contains(cuenta.Propietario_4__c) && String.isNotBlank(cuenta.Propietario_4__c)) {
                AccountTeamMember atm = new AccountTeamMember();
                atm.UserId = cuenta.Propietario_4__c;
                atm.AccountId = cuenta.Id;
                accountTeamsMemberToInsert.add(atm);
            }
            if (!membersTeam.contains(cuenta.Propietario_5__c) && String.isNotBlank(cuenta.Propietario_5__c)) {
                AccountTeamMember atm = new AccountTeamMember();
                atm.UserId = cuenta.Propietario_5__c;
                atm.AccountId = cuenta.Id;
                accountTeamsMemberToInsert.add(atm);
            }
            if (!membersTeam.contains(cuenta.Propietario_adulto__c) && String.isNotBlank(cuenta.Propietario_adulto__c)) {
                AccountTeamMember atm = new AccountTeamMember();
                atm.UserId = cuenta.Propietario_adulto__c;
                atm.AccountId = cuenta.Id;
                accountTeamsMemberToInsert.add(atm);
            }
            if (!membersTeam.contains(cuenta.Propietario_Nicho__c) && String.isNotBlank(cuenta.Propietario_Nicho__c)) {
                AccountTeamMember atm = new AccountTeamMember();
                atm.UserId = cuenta.Propietario_Nicho__c;
                atm.AccountId = cuenta.Id;
                accountTeamsMemberToInsert.add(atm);
            }
        }
        
        if (!accountTeamsMemberToInsert.isEmpty()) {
            insert accountTeamsMemberToInsert;
        }
    }
   /* public static void validaOperadoresPartner(List<Account> accounts) { // Falta pruebas de usuarioes en UAT para pasar a Prod

        Id profileId=userinfo.getProfileId();
        String profileName=[
            SELECT Id,Name 
            FROM Profile 
            WHERE Id=:profileId].Name;
        if(profileName=='Operador Partner'){
            Id bestCare = XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id;
            Id regular = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
            Id profesional = XappiaHelper.getRecordType('Account', 'Profesional de la salud').Id;
            Id partner = XappiaHelper.getRecordType('Account', 'Paciente Partner').Id;
            Set<id> setAccounts = new Set<Id>();
            
            for(Account acc: accounts){
                setAccounts.add(acc.id);
            }
            List<Account> accountsDB = [
                SELECT ID,Obra_social__pr.Provincia_localidad__c,RecordTypeId,Obra_social__pc,Institucion__c,institucion__r.Provincia_localidad__c
                FROM account 
                WHERE id IN :setAccounts
            ];
            Map<id, Account> mapAccount = new Map<id, Account>(accountsDB);
            
            for(Account anAccount : accounts){
                Account acc = mapAccount.get(anAccount.id);
                if(anAccount.RecordTypeId== bestCare || anAccount.RecordTypeId==regular || anAccount.RecordTypeId==partner){
                    if( acc.Obra_social__pc!=null &&
                       acc.Obra_social__pr.Provincia_localidad__c!='Mendoza' &&
                       acc.Obra_social__pr.Provincia_localidad__c!=null)
                    {
                        anAccount.addError(Label.Error_en_usuario_operador_partner); 
                    }
                } 
                else if(anAccount.RecordTypeId== profesional){
                    if( acc.Institucion__c!=null &&
                       acc.Institucion__r.Provincia_localidad__c!='Mendoza' &&
                       acc.Institucion__r.Provincia_localidad__c!=null)
                    {
                        anAccount.addError(Label.Error_en_usuario_operador_partner); 
                    }
                }
            }       
        }
    }*/
     
    public static void ActualizarDomicilioObraSocialPaciente(List<Account> pacientesPartner){
      
        Map<String,String> mapPacienteObraSocial = new Map<String,String>();
        for(Account acc : pacientesPartner){
           if(!mapPacienteObraSocial.containsKey(acc.Id)){
                mapPacienteObraSocial.put(acc.id,acc.Obra_social__pc);
           }
        }
        Map<String, Account> mapIdObraSocial = new Map<String, Account>();
        for(Account obraSocial : [SELECT id, Codigo_postal__c, Direccion__c, Localidad_look__c, Pais__c, Referencia__c FROM Account WHERE Id IN : mapPacienteObraSocial.values()]){
            if(!mapIdObraSocial.containsKey(obraSocial.Id)){
                mapIdObraSocial.put(obraSocial.Id, obraSocial);
            }
        }

        for(Account paciente : pacientesPartner){
            Account obraSocial = mapIdObraSocial.get(paciente.Obra_social__pc);
            paciente.Codigo_postal__c = obraSocial.Codigo_postal__c;
            paciente.Direccion__c = obraSocial.Direccion__c;
            paciente.Localidad_look__c = obraSocial.Localidad_look__c;
            paciente.Pais__c = obraSocial.Pais__c;
            paciente.Referencia__c = obraSocial.Referencia__c;
        }
    }
}