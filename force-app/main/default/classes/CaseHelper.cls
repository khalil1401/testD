public class CaseHelper  {
    
    public static Boolean isCaseToCountInAccount(Case newCase, Case oldCase) {
        Boolean isChanged = newCase.Status != oldCase.Status || newCase.Type != oldCase.Type || 
            newCase.Subtipo__c != oldCase.Subtipo__c || newCase.Motivo__c != oldCase.Motivo__c;
        
        return isChanged && isCaseToCountInAccount(newCase);
    }
    
    public static Boolean isCaseToCountInAccount(Case aCase) {
        Boolean isCaseToCountInAccount = aCase.IsClosed && aCase.Type == 'Gestión' && aCase.Subtipo__c == 'Retiro de Activos' && 
            (aCase.Motivo__c  == 'Alta/Fin de tratamiento' || aCase.Motivo__c == 'Fallecimiento' || aCase.Motivo__c == 'No renueva servicios');
        return isCaseToCountInAccount;
    }
    
    public static Boolean isCaseToCountInAccountDelete(Case aCase) {
        Boolean isCaseToCountInAccount = aCase.IsClosed && aCase.Type == 'Gestión' && aCase.Subtipo__c == 'Retiro de Activos' && 
            (aCase.Motivo__c  == 'Alta/Fin de tratamiento' || aCase.Motivo__c == 'Fallecimiento' || aCase.Motivo__c == 'No renueva servicios'
             || aCase.Motivo__c == 'Otro');
        return isCaseToCountInAccount;
    }
    
    public static Case getCaseWithAccount(Case newCase, Case oldCase) {
        if(newCase.AccountId != null) return newCase;
        return oldCase;
    }
    
    public static void countCasesInAccount(List<Case> caseList) {
        LREngine.Context contexto = new LREngine.Context(
            Account.SObjectType,
            Case.SObjectType,
            Schema.SObjectType.Case.fields.AccountId,
            '(Type = \'Gestión\' AND Subtipo__c = \'Retiro de Activos\''+
            ' AND (Motivo__c  = \'Alta/Fin de tratamiento\' OR Motivo__c = \'Fallecimiento\' OR Motivo__c = \'No renueva servicios\')'+
            ' AND Isclosed = true)'
        );
        
        contexto.add(new LREngine.RollupSummaryField(
            Schema.SObjectType.Account.fields.Cantidad_de_casos_de_retiro_de_activos__c,
            Schema.SObjectType.Case.fields.Id,
            LREngine.RollupOperation.Count
        ));
        
        List<Account> accountsToUpdate = (List<Account>) LREngine.rollUp(contexto, caseList);
        
        if(!accountsToUpdate.isEmpty()) update accountsToUpdate;
    }
    public static void validateFormularioDeCalidad(Case aCase) {
        
        List<Formulario_de_Calidad__c> formularioList = [
            SELECT ID, Caso__c 
            FROM Formulario_de_Calidad__c
            WHERE Caso__c = :aCase.id
        ];
        if(formularioList.isEmpty()){
            aCase.addError(Label.Error_en_formulario_de_calidad);
        }
    }
}