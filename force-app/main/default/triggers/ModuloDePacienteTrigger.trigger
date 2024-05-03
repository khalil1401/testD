trigger ModuloDePacienteTrigger on Modulo_de_paciente__c(after insert, after update, after delete, after undelete,before update) {

    Set<Id> setOfAccountsToUpdate = new Set<Id> ();
    Set<Id> setOfAccountsToChangeStatus = new Set<Id> ();
    List<Modulo_de_paciente__c> accountsToUpdateMDP = new List<Modulo_de_paciente__c> ();

    if (Trigger.isAfter) {
        if(Trigger.isInsert){
            for (Modulo_de_paciente__c mdp : Trigger.new) {
                setOfAccountsToChangeStatus.add(mdp.Cuenta__c);
                if(mdp.Estado__c== 'Activo'){
                    accountsToUpdateMDP.add(mdp);
                }
            }
            if(!accountsToUpdateMDP.isEmpty()){
                ModuloDePacienteHelper.completaCamposDeCuentaConUltimoMDP(accountsToUpdateMDP);
            }
        }

        if (Trigger.isUpdate) {
            for (Modulo_de_paciente__c mdp : Trigger.new) {

                if(mdp.Estado__c != trigger.oldMap.get(mdp.id).Estado__c){
                    setOfAccountsToUpdate.add(mdp.Cuenta__c);
                }
                if(mdp.Tipo__c != trigger.oldMap.get(mdp.id).Tipo__c || mdp.Estado__c != trigger.oldMap.get(mdp.id).Estado__c){
                    setOfAccountsToChangeStatus.add(mdp.Cuenta__c);
                }
                if(mdp.Estado__c== 'Activo' && 
                (mdp.Modulo__c != trigger.oldMap.get(mdp.id).Modulo__c ||
                 mdp.Estado_de_modulo__c != trigger.oldMap.get(mdp.id).Estado_de_modulo__c ||
                 mdp.Tipo__c != trigger.oldMap.get(mdp.id).Tipo__c ||
                 mdp.Modulo_hasta__c != trigger.oldMap.get(mdp.id).Modulo_hasta__c || 
                 mdp.Estado__c != trigger.oldMap.get(mdp.id).Estado__c))
                {
                    accountsToUpdateMDP.add(mdp);
                }
            }

            if(!accountsToUpdateMDP.isEmpty()){
                ModuloDePacienteHelper.completaCamposDeCuentaConUltimoMDP(accountsToUpdateMDP);
            }

        } else if (Trigger.isUndelete) {
            for (Modulo_de_paciente__c mdp : Trigger.new) {
                setOfAccountsToUpdate.add(mdp.Cuenta__c);
            }

        } else if (Trigger.isDelete) {
            for (Modulo_de_paciente__c mdp : Trigger.old) {
                setOfAccountsToUpdate.add(mdp.Cuenta__c);
            }
        }
    }
    if (!setOfAccountsToChangeStatus.isEmpty()) {
        ModuloDePacienteHelper.statusAndTypeUpdate(setOfAccountsToChangeStatus);
    }
    
    if (!setOfAccountsToUpdate.isEmpty()) {
        ProductoModuloHelper.UpdateFormulasActualesFromSetOfAccounts(setOfAccountsToUpdate);
    }

}