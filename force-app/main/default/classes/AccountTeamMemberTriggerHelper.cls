public class AccountTeamMemberTriggerHelper {


    public static void actualizaLosPropietariosDeLaCuenta(List<AccountTeamMember> listAccountTeamMembers) {
        List<Id> idsCuentas = new List<Id> ();
        for (AccountTeamMember atm : listAccountTeamMembers) {
            idsCuentas.add(atm.AccountId);
        }


        Map<id, Account> mapCuentas = new Map<Id, Account> ([
                                                            SELECT id, OwnerId,Propietario_Nicho__c, Propietario_adulto__c, Propietario_3__c, Propietario_4__c, Propietario_5__c
                                                            FROM Account
                                                            WHERE Id IN :idsCuentas
                                                            ]);

        List<Account> cuentasToUpdate = new List<Account> ();
        for (AccountTeamMember atm : listAccountTeamMembers) {
            if (mapCuentas.containsKey(atm.AccountId)) {
                system.debug(mapCuentas);
                Account accId = mapCuentas.get(atm.AccountId);
                List<Id> idsPropietarios = new List<Id> { accId.OwnerId,
                    accId.Propietario_Nicho__c,
                    accId.Propietario_Adulto__c,
                    accId.Propietario_3__c,
                    accId.Propietario_4__c,
                    accId.Propietario_5__c
                };

				system.debug(idsPropietarios);
                if (!idsPropietarios.contains(atm.UserId)) {
                    if (accId.Propietario_Nicho__c == null) {
                        accId.Propietario_Nicho__c = atm.UserId;
                    }
                    else if (accId.Propietario_adulto__c == null) {
                        accId.Propietario_adulto__c = atm.UserId;
                    }
                    else if (accId.Propietario_3__c == null) {
                        accId.Propietario_3__c = atm.UserId;
                    }
                    else if (accId.Propietario_4__c == null) {
                        accId.Propietario_4__c = atm.UserId;
                    }
                    else if (accId.Propietario_5__c == null) {
                        accId.Propietario_5__c = atm.UserId;
                    }
                    else {
                        System.debug('Todos los propietarios completos');
                    }
                    cuentasToUpdate.add(accId);

                }

            }
        }

        if (!cuentasToUpdate.isEmpty()) {
            update cuentasToUpdate;
        }
    }

    public static void validaQueNoHayaMasDe5Miembros(List<AccountTeamMember> listAccountTeamMembers) {
        List<Id> idsCuentas = new List<Id> ();
        for (AccountTeamMember atm : listAccountTeamMembers) {
            idsCuentas.add(atm.AccountId);
        }


        List<AccountTeamMember> miembrosDeCuenta = [
                                                    SELECT Id, AccountId
                                                    FROM AccountTeamMember
                                                    WHERE Id IN :idsCuentas
                                                   ];

        Map<Id, List<AccountTeamMember>> mapCuentaMiembros = new Map<Id, List<AccountTeamMember>> ();

        for (AccountTeamMember miembro : miembrosDeCuenta) {
            if (!mapCuentaMiembros.containsKey(miembro.AccountId)) {
                mapCuentaMiembros.put(miembro.AccountId, new List<AccountTeamMember> { miembro });
            }
            else {
                mapCuentaMiembros.get(miembro.AccountId).add(miembro);
            }
        }

        for (AccountTeamMember atm : listAccountTeamMembers) {
            if (mapCuentaMiembros.containsKey(atm.AccountId)) {
                if (mapCuentaMiembros.get(atm.AccountId).size() > 4) {
                    atm.addError('Solo puede asignar 5 propietarios por cuenta.');
                }
            }
        }

    }



    public static void UpdateAccounts(List<AccountTeamMember> listAccountTeamsMember) {
        List<Id> accountsIds = new List<Id> ();

        for (AccountTeamMember atm : listAccountTeamsMember) {
            accountsIds.add(atm.AccountId);
        }

        Map<Id, Account> mapaccountsToUpdate = new Map<Id, Account> ([
                                                                     SELECT Id, Propietario_3__c, Propietario_4__c, Propietario_5__c,
                                                                     Propietario_adulto__c, Propietario_Nicho__c
                                                                     FROM Account
                                                                     WHERE Id IN :accountsIds
                                                                     ]);

        List<Account> accountsToUpdate = new List<Account> ();
        for (AccountTeamMember atm : listAccountTeamsMember) {
            if (mapaccountsToUpdate.containsKey(atm.AccountId)) {
                Account cuenta = mapaccountsToUpdate.get(atm.AccountId);
                if (atm.UserId == cuenta.Propietario_3__c) {
                    cuenta.Propietario_3__c = null;
                }
                if (atm.UserId == cuenta.Propietario_4__c) {
                    cuenta.Propietario_4__c = null;
                }
                if (atm.UserId == cuenta.Propietario_5__c) {
                    cuenta.Propietario_5__c = null;
                }
                if (atm.UserId == cuenta.Propietario_adulto__c) {
                    cuenta.Propietario_adulto__c = null;
                }
                if (atm.UserId == cuenta.Propietario_Nicho__c) {
                    cuenta.Propietario_Nicho__c = null;
                }
                accountsToUpdate.add(cuenta);
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}