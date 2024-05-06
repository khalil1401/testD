public with sharing class customerSalesAreaPrices {
    @InvocableMethod(label='Get CustomerSalesArea Prices' description='Update/Create the prices of pricebookentries')
    public static void updateMaterialsFlow(List<String> customerSalesAreaIds){
        String customerSalesAreaId = customerSalesAreaIds[0];
        BatchCustomerSalesAreaPricebook customer = new BatchCustomerSalesAreaPricebook(customerSalesAreaId);
        ID batchId = Database.executeBatch(customer);
    }
}