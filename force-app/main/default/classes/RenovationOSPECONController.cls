public  class RenovationOSPECONController {
    
    @AuraEnabled
    public static List<Account> updateAccounts(String base64Data){

        String data  = JSON.deserializeUntyped(base64Data).toString();
        list<String> lstCSVLines = data.split('\n');      
        Set<String> DNIList = new Set<String>();
        Set<String> externalIdList = new Set<String>();
        
        for(Integer i = 1; i < lstCSVLines.size(); i++){
            String csvLine = lstCSVLines[i];
            List<String> csvRowData = new List<String>();

            for(String column : csvLine.split(',')){
                csvRowData.add(column);
            }
           
            String idPaciente = csvRowData[0].trim();
            String DNI = csvRowData[1].trim();

            externalIdList.add(idPaciente);
            DNIList.add(DNI);
        }

        List<Account> accountsToUpdate = [
            SELECT id,Modulo_hasta__c
            FROM Account
            WHERE (ID_de_paciente__c IN : externalIdList AND ID_de_paciente__c!=null)
            OR (DNI__c IN : DNIList AND DNI__c!=null)
        ]; 
        
        if(accountsToUpdate.size() >= 1000){
            return null;
        }

        return updateAccounts(accountsToUpdate);
    }
    
    public static List<Account> updateAccounts(List<Account> accounts){
        List<Account> updatedAccounts = new List<Account>();
        Set<String> updatedAccountsIds = new Set<String>();
        List<Account> accountsToUpdate = new List<Account>();

        for(Account anAcc : accounts){
            Integer daysToAdd;

            if( anAcc.Modulo_hasta__c!=null){
                daysToAdd = getDays(anAcc.Modulo_hasta__c.month());
                anAcc.Modulo_hasta__c  = anAcc.Modulo_hasta__c.addDays(daysToAdd);
            }else{
                daysToAdd = getDays(System.today().month());
                anAcc.Modulo_hasta__c  = System.today().addDays(daysToAdd);
            }
            system.debug( anAcc.Modulo_hasta__c);
            accountsToUpdate.add(anAcc);
        }
        
        Database.SaveResult[] srList = Database.update(accountsToUpdate,false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                updatedAccountsIds.add(sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        if(!updatedAccountsIds.isEmpty()){
            return [
                SELECT id,DNI__c,ID_de_paciente__c,Name,Modulo_hasta__c
                FROM Account
                WHERE id IN :updatedAccountsIds
            ];
        }
        
        return null;
    }

    public static Integer getDays(Integer monthNumber){
        Map<Integer,Integer>  monthNameMap = new Map<Integer, Integer> {
            1=>31, 2=>28, 3=>31, 4=>30, 5=>31, 6=>30,
                7=>31, 8=>31,9=>30,10=>31, 11=>30, 12=>31
                };
                    return monthNameMap.get(monthNumber);
    }

}