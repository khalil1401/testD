public class TratamientoDeProfesionalTriggerHelper {
    
    public static void actualizarCantidadDeTratamientos(List<Tratamiento_de_profesional__c> tratList){
        
        Set<Id> idsAcc = new Set<Id>();
        List<Account> accListToUpdate = new List<Account>();

        for(Tratamiento_de_profesional__c trat : tratList){
            if(trat.Profesional__c!=null){
                idsAcc.add(trat.Profesional__c);
            }
        }
        
        
          List<Account> accList = [
            SELECT id
            FROM Account
            WHERE id IN :idsAcc
        ];
        
      if(!accList.isEmpty()){
            
            List<Tratamiento_de_profesional__c> tratListDb = [
                SELECT id,profesional__c,Tratamiento__r.Activo__c
                FROM Tratamiento_de_profesional__c
                WHERE profesional__c IN :idsAcc
                AND Tratamiento__r.Activo__c = true
            ];
            
            if(!tratListDb.isEmpty()){

                for(Account acc : accList){
                    acc.Cantidad_de_tratamientos_Profesional__c = String.valueOf(tratListDb.size());
                    accListToUpdate.add(acc);
                }
                
                if(!accListToUpdate.isEmpty()){
                    update accListToUpdate;
                }
            }
        }
    }
    public static void actualizarCantidadDeTratamientosSiSeEliminaUnTratamiento(List<Tratamiento_de_profesional__c> tratList){
        
        Set<Id> idsAcc = new Set<Id>();
        List<Account> accListToUpdate = new List<Account>();
        
        for(Tratamiento_de_profesional__c trat : tratList){
            if(trat.Profesional__c!=null){
                idsAcc.add(trat.Profesional__c);
            }
        }
        
        List<Account> accList = [
            SELECT id
            FROM Account
            WHERE id IN :idsAcc
        ];
        
        if(!accList.isEmpty()){
            
            List<Tratamiento_de_profesional__c> tratListDb = [
                SELECT id,profesional__c
                FROM Tratamiento_de_profesional__c
                WHERE profesional__c IN :accList
                AND Tratamiento__r.Activo__c = true
            ];
            
            if(!tratListDb.isEmpty()){
                
                for(Account acc : accList){
                    acc.Cantidad_de_tratamientos_Profesional__c = String.valueOf(tratListDb.size());
                    accListToUpdate.add(acc);
                }
                
                if(!accListToUpdate.isEmpty()){
                    update accListToUpdate;
                }
            }
        }
    }
}