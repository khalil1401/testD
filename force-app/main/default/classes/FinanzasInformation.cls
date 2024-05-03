public class FinanzasInformation {
    public List<Informacion_de_finanzas__mdt> financesInfo { get; set; }
    
    public FinanzasInformation(ApexPages.StandardController controller) {
        financesInfo = [
            SELECT Condicion_de_pago__c, Cta_Que_Cobrar__c, Deposito__c, 
            Ingreso__c, Lista_de_Precios__c, M_todo_de_env_o__c, Tipo_de_Pedido__c, titulo__c
            FROM Informacion_de_finanzas__mdt
        ];
        
    }
}