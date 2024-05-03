trigger AccountTeamMemberTrigger on AccountTeamMember(after update, before update, after insert, before insert, before delete) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            AccountTeamMemberTriggerHelper.actualizaLosPropietariosDeLaCuenta(Trigger.new);
        }
    }

    /*
      Valida que desde la lista relacionada no se dupliquen los propietarios en los lookups de propietarios de la cuenta
     */

    if (Trigger.isBefore) {
        if (Trigger.IsInsert) {
            AccountTeamMemberTriggerHelper.validaQueNoHayaMasDe5Miembros(Trigger.New);
        }


        if (Trigger.isDelete) {
            AccountTeamMemberTriggerHelper.UpdateAccounts(Trigger.old);
        }
    }

    if (Trigger.isAfter) {

        //AccountTeamMemberTriggerHelper.insertaOactualizarPropietarios(Trigger.new, Trigger.oldMap);
    }


}