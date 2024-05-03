public class TratamientoTriggerHelper {
    
    public static void updateAccountsAndTratamientos(List<Tratamiento__c> tratamientoList){
        
        List<id> accountsId = new List<id>();
        List<Account> accountsList = new List<Account>();   
        Map<id, Tratamiento__c> mapTratamiento= new Map<id, Tratamiento__c>();
        List<Tratamiento__c> tratListDb = new List<Tratamiento__c>();   
        
        for(Tratamiento__c trat : tratamientoList){
            
            if(trat.Obra_social__c!=null && trat.Activo__c){
                
                mapTratamiento.put(trat.Cuenta__c, trat);
                accountsId.add(trat.Cuenta__c);
                
            }
        }
        
        List<Account> accList = [
            SELECT id, Obra_social__pc
            FROM Account
            WHERE id IN :accountsId
        ];
        
        List<Tratamiento__c> tratListInAccount = [
            SELECT id, cuenta__c,Activo__c,Name
            FROM Tratamiento__c
            WHERE cuenta__c IN :accList
        ];
        
        if(tratListInAccount.size()>0){          
            for(Tratamiento__c tr: tratListInAccount){
                
                tratListDb.add(tr);
                tr.Activo__c =false;
                
            }
        }        
        
        for(Account acc: accList){
            
            Tratamiento__c trat = mapTratamiento.get(acc.id);
            
            acc.Obra_social__pc = trat.Obra_social__c;
            
            accountsList.add(acc);
        }
        if(tratListInAccount.size()>0){
            update tratListInAccount;
        }
        if(accountsList.size()>0){
            update accountsList;
        }
        
    }
    
      public static void updateAccount(List<Tratamiento__c> tratamientoList){
        
        List<id> accountsId = new List<id>();
        List<Account> accountsList = new List<Account>();   
        Map<id, Tratamiento__c> mapTratamiento= new Map<id, Tratamiento__c>();
        List<Tratamiento__c> tratListDb = new List<Tratamiento__c>();   
        
        for(Tratamiento__c trat : tratamientoList){           
            if(trat.Obra_social__c!=null && trat.Activo__c){
                mapTratamiento.put(trat.Cuenta__c,trat);
                accountsId.add(trat.Cuenta__c);
            }
        }
        
        List<Account> accList = [
            SELECT id, Obra_social__pc
            FROM Account
            WHERE id IN :accountsId
        ];
              
        for(Account acc: accList){           
            Tratamiento__c trat = mapTratamiento.get(acc.id);
            if(trat!=null){  
                acc.Obra_social__pc = trat.Obra_social__c;
            }
            accountsList.add(acc);
        }
        if(accountsList.size()>0){
            update accountsList;
        }
        
    }
    
}