public class Async_ActualizarOrden_Helper implements Queueable {

    public String orderId {get;set;}

    public Async_ActualizarOrden_Helper(String OrderId){
        this.orderId = OrderId;
    } 

    public void execute(QueueableContext context) {

        actualizarEstado();

    }

    public void actualizarEstado(){
        
        Order a = new Order(
            Id = orderId,
            Status = 'Confirmado',
            Dan360_PedidoConfirmado__c = true,
            Dan360_FechasConfirmado__c = Date.today()
        );

        UPDATE a;

        System.debug('Se actualizo el registro >>> '+ a);
    }

}