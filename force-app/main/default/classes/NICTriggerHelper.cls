public without sharing class NICTriggerHelper {
    
    public static void relateNICWithAccount(List<NIC_Envio__c> nics){
        List<String> nicSAPIds = new List<String>();
        Map<String,Id> sapIdWhitAccounts = new Map<String,Id>();
        List<NIC_Envio__c> nicsToUpdate = new List<NIC_Envio__c>();
        
        for(NIC_Envio__c aNic : nics){
            if(aNic.Id_de_cuenta_SAP__c != null && aNic.Id_de_cuenta_SAP__c.length()>=8 && aNic.Id_de_cuenta_SAP__c.substring(0, 2) == 'P-'){
                String splitedId =aNic.Id_de_cuenta_SAP__c.substring(0, 8);
                nicSAPIds.add(splitedId);
            }
        }
        List<Account> accounts = [ 
            SELECT Id,ID_de_paciente__c
            FROM Account
            WHERE ID_de_paciente__c IN :nicSAPIds 
        ];
        
        for(Account anAccount : accounts){
            sapIdWhitAccounts.put(anAccount.ID_de_paciente__c, anAccount.id);
        }
        if(!accounts.isEmpty()){
            for(NIC_Envio__c aNic : nics){
                if(aNic.Id_de_cuenta_SAP__c.length()>=8 && aNic.Id_de_cuenta_SAP__c.substring(0, 2) == 'P-'){
                    String splitedId =aNic.Id_de_cuenta_SAP__c.substring(0, 8);
                    Id relatedAccountId = sapIdWhitAccounts.get(splitedId);
                    if(relatedAccountId!=null){
                        aNic.Cuenta__c= relatedAccountId;
                        nicsToUpdate.add(aNic);
                    }
                }
            }
        }
    }
}