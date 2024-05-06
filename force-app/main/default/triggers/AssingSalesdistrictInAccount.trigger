trigger AssingSalesdistrictInAccount on Dan360_CustomerSalesArea__c (after insert) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            List<Dan360_CustomerSalesArea__c> customerSalesAreaList = new List<Dan360_CustomerSalesArea__c>();

            for (Dan360_CustomerSalesArea__c csa : Trigger.new) {
                customerSalesAreaList.add(csa);
            }
            if (!customerSalesAreaList.isEmpty()) {
               
               AssingSalesdistrictInAccountHandler.assingSalesDistrictAndDistributionChannel(customerSalesAreaList);                
                
            }
        }
    }
}