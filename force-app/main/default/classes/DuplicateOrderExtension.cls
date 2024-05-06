public class DuplicateOrderExtension {
    private Order orderToCreate;
    private sObject orderComplete;

    public DuplicateOrderExtension(ApexPages.StandardController stdController) {
        this.orderComplete = stdController.getRecord();
    }

    public PageReference duplicateOrder(){
        Order completeOrder = (Order)orderComplete;
        String oderId = completeOrder.id;
        String objectApiName = 'Order';
        String objectApiNameProduct = 'OrderItem';

        String queryFields =  getAllApiNameFields(objectApiName);
        String queryFieldsProduct = getAllApiNameFields(objectApiNameProduct);

        String soqlQuery = 'SELECT '+ queryFields +' FROM Order WHERE id = :oderId';
        String soqlQueryProduct = 'SELECT '+ queryFieldsProduct +' FROM OrderItem WHERE OrderId = :oderId';
        
        Order orderObjectToDuplicate = database.query(soqlQuery);
        List<OrderItem> orderProductToDuplicate = database.query(soqlQueryProduct);
        
        orderToCreate = orderObjectToDuplicate.clone(false,true,false,false);
        orderToCreate.Status = 'Borrador';
        orderToCreate.EffectiveDate = Date.today();
        
        Database.SaveResult orderInsertResult = Database.insert(orderToCreate, true);
        if(orderinsertResult.isSuccess()) {
            System.debug('Se inserto la orden: ' + orderObjectToDuplicate.OrderNumber);
        } else {
            For (Database.Error orderError : orderInsertResult.getErrors()){
                System.debug(orderError.getStatusCode() + ': ' + orderError.getMessage());
                System.debug('Campo de la Orden con error:' + orderError.getFields());
            }
        }

        if (!orderProductToDuplicate.isEmpty()) {

            List<Orderitem> orderProductToInsert = new List<Orderitem>();

            List<Orderitem> orderItemDuplicated = orderProductToDuplicate.deepClone();
            for(OrderItem orderItemToModify : orderItemDuplicated){
                orderItemToModify.OrderId = orderToCreate.Id;
                orderProductToInsert.add(orderItemToModify);
            }
            
            
            List<Database.SaveResult> orderProductInsertResults = Database.insert(orderProductToInsert,true);
            for(Database.SaveResult orderProductInsertResult : orderProductInsertResults){
                if(orderProductInsertResult.isSuccess()){
                    System.debug('Se inserto el Producto de la Orden: '+ orderProductInsertResult.getId());
                } else {
                    for(Database.Error orderProductError: orderProductInsertResult.getErrors()){
                        System.debug(orderProductError.getStatusCode() + ': ' + orderProductError.getMessage());
                        System.debug('Campo del Producto de la Orden con error:' + orderProductError.getFields());
                    }
                }
            }
        }
        
        PageReference pg = new PageReference('/' + completeOrder.Id);
        pg.setRedirect(true);
        return pg;
    }

    public static String getAllApiNameFields (String ObjectName) {
        
        String queryFields;

        Map<String, Schema.SObjectField> objectsSchemaField = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap();
        List<String> listStrings = new List<String>(objectsSchemaField.keySet());
        
        return String.join(listStrings,','); 
    }
}