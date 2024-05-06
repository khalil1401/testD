public with sharing class AssingSalesdistrictInAccountHandler {
    public static void assingSalesDistrictAndDistributionChannel(List<Dan360_CustomerSalesArea__c> customerSalesAreaList) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        List<Account> accountList = new List<Account>();
        Map<String, String> salesDistrictMap = new Map<String, String>();
            salesDistrictMap.put('AR3DIS', 'Distribuidores');
            salesDistrictMap.put('AR3INS', 'Instituciones');
            salesDistrictMap.put('AR3TEN', 'Licitaciones');
            salesDistrictMap.put('AR3ACC', 'Acceso');
            salesDistrictMap.put('AR3DPF', 'Disprofarma');
            salesDistrictMap.put('AR3FAR', 'Farmacity');
            salesDistrictMap.put('AR3PHA', 'Farmacias');
            salesDistrictMap.put('AR3MTR', 'Modern Trade');
            salesDistrictMap.put('AR3PRO', 'Proximity');
            salesDistrictMap.put('AR3ECO', 'E-commerce');
            salesDistrictMap.put('AR3HOM', 'Home Care');
            salesDistrictMap.put('AR3INT', 'Intercompany');
            salesDistrictMap.put('AR3MAR', 'Marketing');
            salesDistrictMap.put('AR3OTH', 'Others');
        Account anAccount = new Account();
        for (Dan360_CustomerSalesArea__c customerSalesArea : customerSalesAreaList) {
            
            System.debug('CustomerSalesArea '+ customerSalesArea);
            if (!accountIds.contains(customerSalesArea.Dan360_Customer__c)) {
                anAccount = [
                    SELECT Dan360_DistributionChannel__c, Dan360_SalesDistric1__c, Dan360_SalesDistrictColaborationRule__c
                    FROM Account
                    WHERE Id = :customerSalesArea.Dan360_Customer__c
                ];                
            } else {
                anAccount = accountMap.get(customerSalesArea.Dan360_Customer__c);
            }
            System.debug('Cuenta '+ anAccount);
            Dan360_SalesArea__c salesArea = [
                SELECT Id, Dan360_DistributionChannel__c
                FROM Dan360_SalesArea__c
                WHERE Id = :customerSalesArea.Dan360_SalesArea__c
            ];
    
            String distributionChannel;
            System.debug('distribution channel '+ salesArea.Dan360_DistributionChannel__c);
            if (salesArea.Dan360_DistributionChannel__c == '00') {
                distributionChannel = 'Venta Estándar';
            } else {
                distributionChannel = 'Sin Cargo';
            }
    
            System.debug('Distribution channel '+distributionChannel);           
    
            system.debug('SalesDistrict '+ customerSalesArea.Dan360_District__c);
    
            String salesDistrict = salesDistrictMap.get(customerSalesArea.Dan360_District__c)  != null ? salesDistrictMap.get(customerSalesArea.Dan360_District__c) : '';        
            String salesDistrictAccount = anAccount.Dan360_SalesDistric1__c != null ? anAccount.Dan360_SalesDistric1__c : '';
            String distributionChannelAccount = anAccount.Dan360_DistributionChannel__c != null ? anAccount.Dan360_DistributionChannel__c : '';
            System.debug(salesDistrict);
            System.debug(salesDistrictAccount);
            System.debug(distributionChannelAccount);
            if (salesDistrictAccount.Contains(salesDistrict)) {
                if (!distributionChannelAccount.Contains(distributionChannel)) {
                    if (anAccount.Dan360_DistributionChannel__c != null) {                    
                        anAccount.Dan360_DistributionChannel__c += '; '+ distributionChannel;
                    }else {
                        anAccount.Dan360_DistributionChannel__c = distributionChannel;                    
                    }
                }
            }else {
                if (!distributionChannelAccount.Contains(distributionChannel)) {
                    if (anAccount.Dan360_DistributionChannel__c != null) {                    
                        anAccount.Dan360_DistributionChannel__c += '; '+ distributionChannel;
                    }else {
                        anAccount.Dan360_DistributionChannel__c = distributionChannel;                    
                    }
                }
                if (anAccount.Dan360_SalesDistric1__c != null) {
                    anAccount.Dan360_SalesDistric1__c += ';'+salesDistrict;
                    anAccount.Dan360_SalesDistrictColaborationRule__c = anAccount.Dan360_SalesDistric1__c;                
                }else {
                    anAccount.Dan360_SalesDistric1__c = salesDistrict;
                    anAccount.Dan360_SalesDistrictColaborationRule__c = anAccount.Dan360_SalesDistric1__c;            
                }
            }
            accountMap.put(customerSalesArea.Dan360_Customer__c, anAccount);
            accountIds.add(customerSalesArea.Dan360_Customer__c);
        }
        for (Id id : accountIds) {
            Account account = accountMap.get(id);
            accountList.add(account);
        }
        System.debug(accountList);
        update accountList;
    }
}