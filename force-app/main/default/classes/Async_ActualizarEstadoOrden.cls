public class Async_ActualizarEstadoOrden {

    // Metodo para ejecutar de forma asincrona la actualizacion de la orden a procesados
    @InvocableMethod(label='Async_ActualizarEstadoOrden')
    public static void Async_ActualizarEstadoOrden(List<String> orderId) {
        
        ID jobID = System.enqueueJob(new Async_ActualizarOrden_Helper(orderId[0]));

        System.debug('Se encolo la accion para actualizar el pedido > '+ orderId);
    }
}