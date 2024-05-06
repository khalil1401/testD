public class QueueableSendToSap implements Queueable {

    private String orderIdInfo;

    public void CreateCustomObject (String orderId) {
        this.orderIdInfo = orderId;
    }
    
    public void execute(QueueableContext context) {
        
        List<String> orderIds = new List<string>();
        
        orderIds.add( String.valueOf(orderIdInfo));

        if(!Test.isRunningTest()){
            sendOrderToSapController.sendOrderToSapFlow(orderIds);
        }

    }
}